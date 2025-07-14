const express = require('express');
const router = express.Router();
const { findPath } = require('../controllers/indoorMappingController');

// Indoor mapping routes
router.post('/find-path', findPath);

module.exports = router;