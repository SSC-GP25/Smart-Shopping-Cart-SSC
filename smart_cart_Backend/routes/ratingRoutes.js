const express = require('express');
const router = express.Router();

const ratingsController = require("../controllers/ratingsController");
const { protectRoute } = require('../middleware/auth.middleware');
const { ratingsValidation } = require('../middleware/validators/ratingsValidator');

// http://localhost:3000/api/ratings/add_rating/:orderId
router.post('/add_rating/:orderId', protectRoute, ratingsValidation, ratingsController.addRating);

module.exports = router;