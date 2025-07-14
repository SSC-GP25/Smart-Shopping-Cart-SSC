const express = require('express');
const adminController = require('../controllers/adminController');
const dashboardController = require('../controllers/dashboardController');

const {protectRoute,adminRoute } = require('../middleware/auth.middleware');
const router = express.Router();



router.route('/customers').get(protectRoute,adminController.getAllCustomers);
router.route('/transactions').get(protectRoute, adminController.getTransactions);
router.route('/transaction/:id').get( protectRoute,adminController.getTransactionByID);
router.route('/cart/alerts').get(adminController.getCartAlerts);
router.route('/cart/alerts:id').delete(adminController.deleteCartAlert);
router.route('/revenue').get(dashboardController.getRevenueStats);
router.route('/lastweekorders').get(dashboardController.lastWeekOrders);
router.route('/recenttransactions').get(dashboardController.getRecentTransactions);
router.route('/topsoldproducts').get(dashboardController.getTopSoldProducts);
// router.route("/today_revenue").get(dashboardController.getTodayRevenue);
router.route("/users_count").get(dashboardController.getUsersCount);
// router.route("/todays_orders_and_products").get(dashboardController.getTodaysOrders);
router.route("/today_stats").get(dashboardController.getTodayStats);
router.route("/get_products_sold").get(dashboardController.getProductsSoldCount);




module.exports = router;