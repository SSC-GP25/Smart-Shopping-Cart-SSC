const User = require("../models/userModel"); 
const Transaction = require("../models/transactionModel");
const APIFeatures = require("../utils/apiFeatures");
const Cart = require("../models/cartModel");
exports.getCustomerByID = async (req, res) => {
    try {
        const { userId } = req.body;
        
        const user = await User.findById(userId);

        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        res.status(200).json({
            status:"success",
            message: "User successfully found",
            data: {
                user: user
            }
        });
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
};



exports.getAllCustomers= async (req, res) => {
    try {
        const features = new APIFeatures(User.find(), req.query);
        features.filter().sort().limitFields();
        
        if (req.query.search) {
            const searchRegex = new RegExp(req.query.search, 'i');
            features.query = features.query.find({
                $or: [
                    { name: { $regex: searchRegex } },
                    { country: { $regex: searchRegex } },
                    { gender: { $regex: searchRegex } },
                    { email: { $regex: searchRegex } },
                ]
            });
        }
        features.pagination();
        const customers = await features.query;

        const totalCount = await User.countDocuments();
        const currentCount= customers.length;
        res.status(200).json({
            status:"success",
            message: "customers successfully found",
            totalCount,
            currentCount,
            data: {
                customers
            }
            
        });
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
};


exports.getTransactions = async (req, res) => {
    try {
        // Count all transactions before any filters
        const totalTransactions = await Transaction.countDocuments();

        // Apply filters but don't apply pagination yet
        let filteredQuery = Transaction.find()
            .populate({ 
                path: "user", 
                select: "name" 
            });

        const features = new APIFeatures(filteredQuery, req.query);
        features.filter(); // Apply filtering

        // Count transactions after filtering but before pagination
        const filteredCount = await features.query.clone().countDocuments();

        // Now apply pagination and sorting
        features.limitFields().pagination().sort();

        let transactions = await features.query.exec();

        if (req.query.search) {
            const searchRegex = new RegExp(req.query.search, 'i');

            transactions = transactions.filter(t =>
                searchRegex.test(String(t.transactionId)) || 
                (t.user && searchRegex.test(t.user.name))
            );
        }

        let modifiedTransactions = transactions.map(transaction => {
            const totalProducts = transaction.products.reduce((sum, product) => sum + product.quantity, 0);

            return {
                ...transaction.toObject(),
                totalProducts
            };
        });

        if (req.query.sort) {
            const sortFields = req.query.sort.split(','); 
            modifiedTransactions = modifiedTransactions.sort((a, b) => {
                for (const field of sortFields) {
                    let sortOrder = 1;
                    let sortField = field;

                    if (field.startsWith('-')) {
                        sortOrder = -1;
                        sortField = field.substring(1);
                    }

                    if (sortField === "totalProducts") {
                        return (a.totalProducts - b.totalProducts) * sortOrder;
                    }
                }
                return 0;
            });
        }

        return res.status(200).json({
            status: 'success',
            totalTransactions: totalTransactions, // Total transactions before any filtering
            totalFilteredTransactions: filteredCount, // Transactions after filtering but before pagination
            results: modifiedTransactions.length, // Transactions returned after pagination
            data: {
                transactions: modifiedTransactions
            }
        });
    } catch (error) {
        console.error('Error in getTransactions controller:', error.message);
        return res.status(500).json({ message: error.message });
    }
};


exports.getTransactionByID = async (req, res) => {
    try {
        const  {id}  = req.params;
        const transactionId = id;
        if (!transactionId) {
            return res.status(400).json({ message: "Transaction ID is required" });
        }
        
        const transaction = await Transaction.findOne({ transactionId })
        .populate({ 
            path: "user", 
            select: "name email country user_id profilePic gender totalSpent totalTransactions createdAt" 
        }) 
        .populate({ 
            path: "products.productID", 
            select: "title item_id category barcode image" 
        });

        if (!transaction) {
            return res.status(404).json({ message: "transaction not found" });
        }

        res.status(200).json({
            status:"success",
            message: "transaction successfully found",
            data: {
                transaction: transaction
            }
        });
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
};


exports.getAllCustomers= async (req, res) => {
    try {
        const features = new APIFeatures(User.find(), req.query);
        features.filter().sort().limitFields();
        
        if (req.query.search) {
            const searchRegex = new RegExp(req.query.search, 'i');
            features.query = features.query.find({
                $or: [
                    { name: { $regex: searchRegex } },
                    { country: { $regex: searchRegex } },
                    { gender: { $regex: searchRegex } },
                    { email: { $regex: searchRegex } },
                ]
            });
        }
        features.pagination();
        const customers = await features.query;

        const totalCount = await User.countDocuments();
        const currentCount= customers.length;
        res.status(200).json({
            status:"success",
            message: "customers successfully found",
            totalCount,
            currentCount,
            data: {
                customers
            }
            
        });
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
};

exports.getCartAlerts = async (req, res) => {
  try {
    const carts = await Cart.find({}, 'cartID alerts');

    if (!carts || carts.length === 0) {
      return res.status(404).json({ message: 'No carts found' });
    }

    const allAlerts = carts.flatMap(cart =>
      cart.alerts.map(alert => ({
        ...alert.toObject(), 
        cartID: cart.cartID 
      }))
    );

    res.status(200).json({
      status: 'All cart alerts fetched successfully.',
      alerts: allAlerts
    });

  } catch (error) {
    console.error('Error fetching all cart alerts:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};


exports.deleteCartAlert = async (req, res) => {
  try {
    const { id } = req.params;

    const cart = await Cart.findOne({ "alerts._id": id });

    if (!cart) {
      return res.status(404).json({ message: 'Alert not found in any cart.' });
    }

    cart.alerts = cart.alerts.filter(alert => alert._id.toString() !== id);
    
    await cart.save();

    res.status(200).json({
      status: 'Alert deleted successfully.',
      deletedAlertId: id
    });

  } catch (error) {
    console.error('Error deleting alert:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};


