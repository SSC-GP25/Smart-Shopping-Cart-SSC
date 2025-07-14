// routes/recommendations.js
const express = require('express');
const router = express.Router();

const recommendationsController = require("../controllers/recommendationsController")

// router.post('/fastapi', recommendationsController.getRecommendations);

router.get('/huggingface', recommendationsController.getRecommendationsHuggingFace);



module.exports = router;
