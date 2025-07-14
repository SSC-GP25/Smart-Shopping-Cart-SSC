const express = require('express');
const categoryController = require('../controllers/categoryController');
const {protectRoute,adminRoute } = require('../middleware/auth.middleware');
const router = express.Router();
// const upload = require('../middleware/multer');  





router.route('/').get(protectRoute,categoryController.getAllCategories).post(protectRoute,categoryController.createCategory);
router.route('/:id').get(protectRoute,categoryController.getCategory).patch(protectRoute,categoryController.updateCategory).delete(protectRoute,categoryController.deleteCategory);
// router.route('/products').get(protectRoute,categoryController.getCategoryProducts)
module.exports = router;