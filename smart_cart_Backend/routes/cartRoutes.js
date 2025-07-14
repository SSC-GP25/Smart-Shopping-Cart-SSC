const express = require('express');

const cartController = require('../controllers/cartController');

const router = express.Router();

//Admin Routes
    router.post('/', cartController.createCart);
    router.get('/allCarts', cartController.getAllCarts);
    router.route('/:cartID').get(cartController.getCartByID).patch(cartController.updateCart);


//IOT & User Part to Add Product (For Barcode Scanner);
    router.route("/:cartID/addProduct").patch((req, res) => cartController.addProductToCart(req, res, req.app.get('io')));


//User Routes
    router.route("/:cartID/recProduct").patch(cartController.addRecProductToCart);
    router.route('/:cartID/addUser').patch((req, res) => cartController.addUserToCart(req, res, req.app.get('io')));
    router.route('/:cartID/removeUser').patch((req, res) => cartController.removeUserFromCart(req, res, req.app.get('io')));
    router.route('/:cartID/products').get(cartController.getProducts);
    router.route("/:cartID/deleteProduct").delete((req, res) => cartController.removeProductFromCart(req, res, req.app.get('io')));

//Camera Routes (AI)
    router.route("/:cartID/cameraResponse").post((req, res) => cartController.sendCameraResponse(req, res, req.app.get('io')));
    router.route("/:cartID/weightResponse").post((req, res) => cartController.sendWeightResponse(req, res, req.app.get('io')));

module.exports = router;
