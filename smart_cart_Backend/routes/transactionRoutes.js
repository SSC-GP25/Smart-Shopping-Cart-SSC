const express = require('express');
const { protectRoute, adminRoute } = require("../middleware/auth.middleware");
const transactionsController = require("../controllers/transactionController");

const router = express.Router();

// http://localhost:3000/api/transaction/save_transactions
router.post('/save_transactions', protectRoute, transactionsController.saveTransactions);

// http://localhost:3000/api/transaction/get_orders
router.get('/get_orders', protectRoute, transactionsController.getUserOrders);

// http://localhost:3000/api/transaction/generate_csv
router.get('/generate_csv', transactionsController.generateCsv);

router.post("/generate_json", transactionsController.generateJsonForHF);

router.get("/get_json", transactionsController.getTransactionJson)

router.get("/json", transactionsController.transactionJson)

module.exports = router;