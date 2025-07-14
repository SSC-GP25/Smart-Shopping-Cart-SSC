const express = require("express");

const {protectRoute,adminRoute } = require('../middleware/auth.middleware');

const router = express.Router();

const userController = require("../controllers/userController");

router.route('/:userId/recommended-products').get(userController.getRecommendedProducts)

router.route('/categories').get(userController.getCategoriesNames);

router.post('/likedCategories', protectRoute, userController.saveLikedCategories);

router.route('/updateAccount/:id').patch(protectRoute,userController.updateUser);

router.route('/deleteAccount/:id').delete(protectRoute,userController.deleteUser);

module.exports = router;
