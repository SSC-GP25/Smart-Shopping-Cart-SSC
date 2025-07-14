const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const {protectRoute,adminRoute } = require('../middleware/auth.middleware');
const validateProduct = require('../middleware/productMiddleWare/validation');

router.route('/updateRate').patch(productController.updateProductRating);
router.route('/').get(protectRoute,productController.getAllProducts).post(protectRoute,validateProduct,productController.createProduct).delete(protectRoute,productController.deleteProduct);
router.route('/:id').get(protectRoute,productController.getProduct).patch(protectRoute,productController.updateProduct).delete(protectRoute,productController.deleteProduct);


// //http://localhost:5000/api/products/createProduct
// router.post("/create_product",productController.createProduct);

// //http://localhost:5000/api/products/delete_product/:id
// router.delete("/delete_product/:id", protectRoute, adminRoute, productController.deleteProduct);

// delete(productController.deleteAllProduct);


module.exports = router;