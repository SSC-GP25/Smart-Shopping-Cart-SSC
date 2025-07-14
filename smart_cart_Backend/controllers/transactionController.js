const { mongoose } = require("mongoose");
const Transaction = require("../models/transactionModel");
const APIFeatures = require('../utils/apiFeatures');
const Product = require("../models/productModel");
const User = require("../models/userModel");
const fs = require("fs-extra");
const path = require("path");
const { parse } = require("csv-parse/sync");
const { stringify } = require("csv-stringify/sync");


// CSV file paths
const NEW_TRANSACTIONS_CSV = path.join(__dirname, "../AIModel/newTransactions.csv");
const RATING_UPDATES_CSV = path.join(__dirname, "../AIModel/ratingUpdates.csv");
const LAST_UPDATE_FILE = path.join(__dirname, "../AIModel/lastUpdateTime.txt");

// Ensure directories exist
fs.ensureDirSync(path.dirname(NEW_TRANSACTIONS_CSV));
fs.ensureDirSync(path.dirname(RATING_UPDATES_CSV));

function generateTransactionId() {
  const randomDigits = Math.floor(10000 + Math.random() * 90000); // Generates a 5-digit number (10000 to 99999)
  return `TRANS${randomDigits.toString().padStart(5, '0')}`; // Ensures 5 digits with leading zeros
}

function saveDateAsTimestamp() {
  const now = new Date();
  return Math.floor(now.getTime() / 1000); // Returns just the timestamp in seconds
}

exports.saveTransactions = async (req, res, next) => {
  try {
    const io = req.app.get("io");
    const { products, stripeSessionId, totalAmount, paymentMethod, visa } = req.body;
    const user = req.user;

    // Validate if products array exists and is not empty
    if (!products || !Array.isArray(products) || products.length === 0) {
      return res.status(400).json({
        status: 'fail',
        message: 'No products found in the transaction'
      });
    }

    // Validate required fields
    if (!totalAmount || !paymentMethod) {
      return res.status(400).json({
        status: 'fail',
        message: 'Missing required fields: totalAmount or paymentMethod'
      });
    }

    // Validate payment method and visa number
    if (paymentMethod === 'Visa' && !visa) {
      return res.status(400).json({
        status: 'fail',
        message: 'Visa number is required for Visa payment method'
      });
    }

    let transactionId;
    let existingTransaction;

    do {
      transactionId = generateTransactionId();
      existingTransaction = await Transaction.findOne({ transactionId });
    } while (existingTransaction);

    // Validate and update products with their prices
    const updatedProducts = await Promise.all(products.map(async (product) => {
      if (!product.productID || !product.quantity) {
        throw new Error('Invalid product data: productID and quantity are required');
      }

      const productDetails = await Product.findById(product.productID);
      if (!productDetails) {
        throw new Error(`Product not found: ${product.productID}`);
      }

      if (product.quantity <= 0) {
        throw new Error(`Invalid quantity for product: ${product.productID}`);
      }

      if (product.quantity > productDetails.inventory) {
        throw new Error(`Not enough inventory for product: ${product.productID}`);
      }

      productDetails.inventory -= product.quantity;
      productDetails.sales += product.quantity;
      await productDetails.save();
      return {
        ...product,
        price: product.quantity * productDetails.price,
      };
    }));

    // Update user statistics
    user.totalSpent += totalAmount;
    user.totalTransactions += 1;
    await user.save();

    // Create the transaction
    const newTransaction = await Transaction.create({
      user: new mongoose.Types.ObjectId(user._id),
      products: updatedProducts,
      stripeSessionId,
      totalAmount,
      paymentMethod,
      visa,
      transactionId,
      date: saveDateAsTimestamp(),
    });

    if (!newTransaction) {
      throw new Error('Failed to create transaction');
    }
    // const formattedDate = newTransaction.date.toISOString().split('T')[0];

    const userName = await User.findOne({ _id: newTransaction.user }).select("name");

    // emit to admin dashboard:
    io.emit("transaction_created", {
      message: "New transaction created",
      transaction: {
        user: {
          name: userName.name
        },
        totalAmount: newTransaction.totalAmount,
        paymentMethod: newTransaction.paymentMethod,
        transactionId: newTransaction.transactionId,
        date: newTransaction.date,
      },
    });

    return res.status(200).json({
      status: 'success',
      data: {
        newTransaction,
      }
    });

  } catch (error) {
    console.error('Error in saveTransactions controller:', error.message);
    return res.status(500).json({
      status: 'fail',
      message: error.message
    });
  }
}

exports.getUserOrders = async (req, res, next) => {
  try {
    const user = req.user;
    const userOrders = await Transaction
      .find({
        user: new mongoose.Types.ObjectId(user._id),
      })
      .populate({ path: "products.productID", select: "title image" });

    return res.status(200).json({
      status: 'success',
      data: {
        userOrders: userOrders.map((order) => ({
          orderID: order._id,
          date: order.date,
          totalPrice: order.totalAmount,
          products: order.products.map((product) => ({
            productID: product.productID?._id,
            title: product.productID?.title,
            image: product.productID?.image,
            quantity: product.quantity,
            price: product.price,
          })),
        })),
      }
    });
  } catch (error) {
    console.error('Error in getUserOrders controller:', error.message);
    return res.status(500).json({ message: error.message });
  }
};

exports.generateCsv = async (req, res) => {
  try {
    // Read last update time (or set to epoch if not exists)
    let lastUpdateTime;
    if (fs.existsSync(LAST_UPDATE_FILE)) {
      lastUpdateTime = new Date(fs.readFileSync(LAST_UPDATE_FILE, "utf8"));
    } else {
      lastUpdateTime = new Date(0);
    }

    // Fetch new transactions since last update
    const newTransactions = await Transaction.find({
      createdAt: { $gt: lastUpdateTime }
    })
      .populate("user", "gender user_id")
      .populate("products.productID", "title item_id category section price rating");

    // Fetch transactions with rating updates since last update
    const ratingUpdates = await Transaction.find({
      "products.rating_time": { $gt: lastUpdateTime },
      "products.is_rated": true
    })
      .populate("user", "gender user_id")
      .populate("products.productID", "title item_id category section price rating");

    // Define CSV headers
    const headers = [
      "Transaction_ID",
      "Customer_ID",
      "Item_ID",
      "Product_Name",
      "Product_Category",
      "Product_Brand",
      "Price",
      "rating",
      "Timestamp",
      "Quantity",
      "Gender_Category",
      "Customer_Gender",
    ];

    // Create empty CSV with headers for new transactions
    let newTransactionsCsv;
    if (newTransactions.length > 0) {
      const newTransactionRows = newTransactions.flatMap((tx) =>
        tx.products
          .filter(product => product.productID && tx.user)
          .map((product) => ({
            Transaction_ID: tx.transactionId || 'N/A',
            Customer_ID: tx.user?.user_id || 'N/A',
            Item_ID: product.productID?.item_id || 'N/A',
            Product_Name: product.productID?.title || 'N/A',
            Product_Category: product.productID?.category || 'N/A',
            Product_Brand: product.productID?.section || 'N/A',
            Price: product.price || 0,
            rating: product.user_rating || "5",
            Timestamp: tx.date,
            Quantity: product.quantity || 0,
            Gender_Category: tx.user?.gender || 'N/A',
            Customer_Gender: tx.user?.gender || 'N/A',
          }))
      );
      newTransactionsCsv = stringify(newTransactionRows, {
        header: true,
        columns: headers
      });
    } else {
      // Create empty CSV with just headers
      newTransactionsCsv = stringify([], {
        header: true,
        columns: headers
      });
    }
    fs.writeFileSync(NEW_TRANSACTIONS_CSV, newTransactionsCsv);

    // Create empty CSV with headers for rating updates
    let ratingUpdatesCsv;
    if (ratingUpdates.length > 0) {
      const ratingUpdateRows = ratingUpdates.flatMap((tx) =>
        tx.products
          .filter(product =>
            product.productID &&
            tx.user &&
            product.rating_time &&
            product.rating_time > lastUpdateTime
          )
          .map((product) => ({
            Transaction_ID: tx.transactionId || 'N/A',
            Customer_ID: tx.user?.user_id || 'N/A',
            Item_ID: product.productID?.item_id || 'N/A',
            Product_Name: product.productID?.title || 'N/A',
            Product_Category: product.productID?.category || 'N/A',
            Product_Brand: product.productID?.section || 'N/A',
            Price: product.price || 0,
            rating: product.user_rating || "5",
            Timestamp: tx.date,
            Quantity: product.quantity || 0,
            Gender_Category: tx.user?.gender || 'N/A',
            Customer_Gender: tx.user?.gender || 'N/A',
          }))
      );
      ratingUpdatesCsv = stringify(ratingUpdateRows, {
        header: true,
        columns: headers
      });
    } else {
      // Create empty CSV with just headers
      ratingUpdatesCsv = stringify([], {
        header: true,
        columns: headers
      });
    }
    fs.writeFileSync(RATING_UPDATES_CSV, ratingUpdatesCsv);

    // Update last update time
    fs.writeFileSync(LAST_UPDATE_FILE, new Date().toISOString());

    return res.status(200).json({
      status: "success",
      message: `CSV files updated - New transactions: ${newTransactions.length}, Rating updates: ${ratingUpdates.length}`,
      newTransactionsPath: NEW_TRANSACTIONS_CSV,
      ratingUpdatesPath: RATING_UPDATES_CSV
    });
  } catch (error) {
    console.error("Error generating CSV:", error.message);
    return res.status(500).json({
      status: "error",
      message: error.message || "Failed to generate CSV",
    });
  }
};



const axios = require("axios");
const logger = require("pino")();
// const LAST_UPDATE_FILE = "last_transaction_update.txt";
const NEW_TRANSACTIONS_JSON = "new_transactions.json";
const RATING_UPDATES_JSON = "rating_updates.json";
// @route   POST /api/transaction/generate_json
exports.generateJsonForHF = (async (req, res) => {
  logger.info("Request received", { url: req.url, body: req.body });
  try {
    let lastUpdateTime;
    if (fs.existsSync(LAST_UPDATE_FILE)) {
      lastUpdateTime = new Date(fs.readFileSync(LAST_UPDATE_FILE, "utf8"));
      logger.info("Last update time loaded", { lastUpdateTime });
    } else {
      lastUpdateTime = new Date(0);
      logger.info("No last update file, using epoch time");
    }

    const newTransactions = await Transaction.find({
      createdAt: { $gt: lastUpdateTime }
    })
      .populate("user", "gender user_id")
      .populate("products.productID", "title item_id category section price rating");

    const ratingUpdates = await Transaction.find({
      "products.rating_time": { $gt: lastUpdateTime },
      "products.is_rated": true
    })
      .populate("user", "gender user_id")
      .populate("products.productID", "title item_id category section price rating");

    logger.info("New transactions fetched", { count: newTransactions.length });
    logger.info("Rating updates fetched", { count: ratingUpdates.length });

    const formatTransactionData = (tx, product) => ({
      Transaction_ID: tx.transactionId || "N/A",
      Customer_ID: tx.user?.user_id || "N/A",
      Item_ID: product.productID?.item_id || "N/A",
      Product_Name: product.productID?.title || "N/A",
      Product_Category: product.productID?.category || "N/A",
      Product_Brand: product.productID?.section || "N/A",
      Price: product.price || 0,
      rating: product.user_rating || 5,
      Timestamp: tx.date,
      Quantity: product.quantity || 0,
      Gender_Category: tx.user?.gender || "N/A",
      Customer_Gender: tx.user?.gender || "N/A",
      // Payment_Method: tx.paymentMethod || "N/A",
      // Total_Amount: tx.totalAmount || 0
    });

    let newTransactionsJsonData = [];
    if (newTransactions.length > 0) {
      newTransactionsJsonData = newTransactions.flatMap((tx) =>
        tx.products
          .filter((product) => product.productID && tx.user)
          .map((product) => formatTransactionData(tx, product))
      );
      logger.info("New transactions JSON data prepared", { count: newTransactionsJsonData.length });
    }

    let ratingUpdatesJsonData = [];
    if (ratingUpdates.length > 0) {
      ratingUpdatesJsonData = ratingUpdates.flatMap((tx) =>
        tx.products
          .filter(
            (product) =>
              product.productID &&
              tx.user &&
              product.rating_time &&
              product.rating_time > lastUpdateTime
          )
          .map((product) => formatTransactionData(tx, product))
      );
      logger.info("Rating updates JSON data prepared", { count: ratingUpdatesJsonData.length });
    }

    if (newTransactionsJsonData.length > 0) {
      fs.writeFileSync(NEW_TRANSACTIONS_JSON, JSON.stringify(newTransactionsJsonData, null, 2));
      logger.info("New transactions JSON file written");
    }
    if (ratingUpdatesJsonData.length > 0) {
      fs.writeFileSync(RATING_UPDATES_JSON, JSON.stringify(ratingUpdatesJsonData, null, 2));
      logger.info("Rating updates JSON file written");
    }

    // Remove the Hugging Face push logic since Spaces handles it
    fs.writeFileSync(LAST_UPDATE_FILE, new Date().toISOString());
    logger.info("Last update time written");

    const responseData = {
      status: "success",
      message: `JSON files updated - New transactions: ${newTransactions.length}, Rating updates: ${ratingUpdates.length}`,
      newTransactionsPath: newTransactions.length > 0 ? NEW_TRANSACTIONS_JSON : null,
      ratingUpdatesPath: ratingUpdates.length > 0 ? RATING_UPDATES_JSON : null,
      data: { newTransactions: newTransactionsJsonData, ratingUpdates: ratingUpdatesJsonData }
    };
    logger.info("Sending response", { response: responseData });
    return res.status(200).json(responseData);
  } catch (error) {
    logger.error("Error in generateJsonForHF", { error: error.message, stack: error.stack });
    throw error;
  }
});

// @route   GET /api/transaction/get_json
exports.getTransactionJson = (async (req, res) => {
  logger.info("Request received for JSON data", { url: req.url });
  try {
    const newTransactions = fs.existsSync(NEW_TRANSACTIONS_JSON)
      ? JSON.parse(fs.readFileSync(NEW_TRANSACTIONS_JSON, "utf8"))
      : [];
    const ratingUpdates = fs.existsSync(RATING_UPDATES_JSON)
      ? JSON.parse(fs.readFileSync(RATING_UPDATES_JSON, "utf8"))
      : [];

    logger.info("JSON data retrieved", { newTransactionsCount: newTransactions.length, ratingUpdatesCount: ratingUpdates.length });
    return res.status(200).json({
      status: "success",
      newTransactions: newTransactions,
      ratingUpdates: ratingUpdates
    });
  } catch (error) {
    logger.error("Error retrieving JSON data", { error: error.message, stack: error.stack });
    throw error;
  }
});

// @route   GET /api/transaction/json
// @desc    Generate new JSON data from database and retrieve it
exports.transactionJson = (async (req, res) => {
  logger.info("Request received for transaction JSON", { url: req.url, method: req.method });

  try {
    let lastUpdateTime;
    if (fs.existsSync(LAST_UPDATE_FILE)) {
      lastUpdateTime = new Date(fs.readFileSync(LAST_UPDATE_FILE, "utf8"));
      logger.info("Last update time loaded", { lastUpdateTime });
    } else {
      lastUpdateTime = new Date(0);
      logger.info("No last update file, using epoch time");
    }

    const newTransactions = await Transaction.find({
      createdAt: { $gt: lastUpdateTime }
    })
      .populate("user", "gender user_id")
      .populate("products.productID", "title item_id category section price rating");

    const ratingUpdates = await Transaction.find({
      "products.rating_time": { $gt: lastUpdateTime },
      "products.is_rated": true
    })
      .populate("user", "gender user_id")
      .populate("products.productID", "title item_id category section price rating");

    logger.info("New transactions fetched", { count: newTransactions.length });
    logger.info("Rating updates fetched", { count: ratingUpdates.length });

    const formatTransactionData = (tx, product) => ({
      Transaction_ID: tx.transactionId || "N/A",
      Customer_ID: tx.user?.user_id || "N/A",
      Item_ID: product.productID?.item_id || "N/A",
      Product_Name: product.productID?.title || "N/A",
      Product_Category: product.productID?.category || "N/A",
      Product_Brand: product.productID?.section || "N/A",
      Price: product.price || 0,
      rating: product.user_rating || 5,
      Timestamp: tx.date,
      Quantity: product.quantity || 0,
      Gender_Category: tx.user?.gender || "N/A",
      Customer_Gender: tx.user?.gender || "N/A",
    });

    let newTransactionsJsonData = [];
    if (newTransactions.length > 0) {
      newTransactionsJsonData = newTransactions.flatMap((tx) =>
        tx.products
          .filter((product) => product.productID && tx.user)
          .map((product) => formatTransactionData(tx, product))
      );
      logger.info("New transactions JSON data prepared", { count: newTransactionsJsonData.length });
      fs.writeFileSync(NEW_TRANSACTIONS_JSON, JSON.stringify(newTransactionsJsonData, null, 2));
      logger.info("New transactions JSON file written");
    }

    let ratingUpdatesJsonData = [];
    if (ratingUpdates.length > 0) {
      ratingUpdatesJsonData = ratingUpdates.flatMap((tx) =>
        tx.products
          .filter(
            (product) =>
              product.productID &&
              tx.user &&
              product.rating_time &&
              product.rating_time > lastUpdateTime
          )
          .map((product) => formatTransactionData(tx, product))
      );
      logger.info("Rating updates JSON data prepared", { count: ratingUpdatesJsonData.length });
      fs.writeFileSync(RATING_UPDATES_JSON, JSON.stringify(ratingUpdatesJsonData, null, 2));
      logger.info("Rating updates JSON file written");
    }

    fs.writeFileSync(LAST_UPDATE_FILE, new Date().toISOString());
    logger.info("Last update time written");

    const responseData = {
      status: "success",
      message: `JSON data generated - New transactions: ${newTransactionsJsonData.length}, Rating updates: ${ratingUpdatesJsonData.length}`,
      newTransactionsPath: newTransactions.length > 0 ? NEW_TRANSACTIONS_JSON : null,
      ratingUpdatesPath: ratingUpdates.length > 0 ? RATING_UPDATES_JSON : null,
      data: {
        newTransactions: newTransactionsJsonData,
        ratingUpdates: ratingUpdatesJsonData
      }
    };
    logger.info("Sending response", { response: responseData });
    return res.status(200).json(responseData);
  } catch (error) {
    logger.error("Error in transactionJson", { error: error.message, stack: error.stack });
    return res.status(500).json({
      status: "error",
      message: "Failed to process transaction JSON",
      error: error.message
    });
  }
});