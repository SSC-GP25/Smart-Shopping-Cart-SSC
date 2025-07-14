const { fetchRecommendationsFromFastAPI, fetchCategoryRecommendations } = require('../services/fastApiService');
const User = require("../models/userModel");
const Product = require("../models/productModel");
const { fetchRecommendationsHF } = require("../services/huggingFaceService");

const mongoose = require("mongoose");

// exports.getRecommendations = async (req, res) => {
//     const { user_id } = req.body;
//   console.log(typeof(user_id));
//     if (!user_id) {
//         return res.status(400).json({ message: 'user_id is required' });
//     }
//     const user = await User.findOne({ user_id: user_id });
//     if (!user) {
//       console.log(user);
//         return res.status(400).json({ message: 'user not found!' });
//     }
//     if (!user.likedCategories || user.likedCategories.length === 0) {
//         return res.status(400).json({ message: 'likedCategories are required' });
//     }
//     console.log(user.likedCategories);
//     try {
//         // Call FastAPI to get recommendations
//         const recommendations = await fetchCategoryRecommendations(user_id, 30, user.likedCategories.join(','));
//         const recommendedItems = recommendations.recommended_items;
//         // console.log(recommendedItems);

//         if (!recommendedItems || recommendedItems.length === 0) {
//             return res.status(404).json({ message: 'No recommendations found!' });
//         }
//         const itemIds = recommendedItems.map(item => item.item_id);

//         // Fetch matching products from the database
//         const products = await Product.find({ item_id: { $in: itemIds } });
//         // console.log(products);
//         let arrayOfIds = [];

//         products.forEach(product => {
//             // console.log( new mongoose.Types.ObjectId(product._id));
//             arrayOfIds.push(new mongoose.Types.ObjectId(product._id));
//         });
//         user.recProducts = arrayOfIds;

//         const recommendation = await Product.find({ _id: { $in: arrayOfIds } });
//         // console.log('Retrieved products:', rec);
//         await user.save();

//         return res.status(200).json({
//             status: 'success',
//             results: recommendation.length,
//             recommendedItems: recommendation,
//             message: 'recommendations retrieved successfully.',
//         });
//     } catch (error) {
//         console.error('Error in Node.js recommendations controller:', error.message);
//         return res.status(500).json({ message: 'Error retrieving recommendations from FastAPI.' });
//     }
// }
exports.getRecommendationsHuggingFace = async (req, res) => {
    const { customerId, numItems, categories } = req.query;

    // console.log(typeof (customerId));

    if (!customerId) {
      return res.status(400).json({ message: 'customerId is required' });
    }

    const user = await User.findOne({ user_id: customerId });
    if (!user) {
      console.log(user);
      return res.status(400).json({ message: 'user not found!' });
    }

    if ((!user.likedCategories || user.likedCategories.length === 0) && !categories) {
      return res.status(400).json({ message: 'likedCategories are required' });
  }
    console.log(user.likedCategories); 
    try {
      // Call Hugging Face to get recommendations
      const parsedNumItems = parseInt(numItems, 10) || 30; // Default to 30 if numItems is invalid or missing
      const parsedCategories = categories ? categories.split(',').filter(cat => cat.trim()).join(',') : user.likedCategories.join(',');

      const recommendations = await fetchRecommendationsHF(customerId, parsedNumItems, parsedCategories);
      const recommendedItems = recommendations; // Adjust based on actual response structure

      if (!recommendedItems || recommendedItems.length === 0) {
        return res.status(404).json({ message: 'No recommendations found!' });
      }

      const itemIds = recommendedItems.map(item => item.item_id);

      // Fetch matching products from the database
      const products = await Product.find({ item_id: { $in: itemIds } });
      let arrayOfIds = [];

      products.forEach(product => {
        arrayOfIds.push(new mongoose.Types.ObjectId(product._id));
      });

      user.recProducts = arrayOfIds;
      const recommendation = await Product.find({ _id: { $in: arrayOfIds } });
      await user.save();

      return res.status(200).json({
        status: 'success',
        results: recommendation.length,
        recommendedItems: recommendation,
        message: 'recommendations retrieved successfully.',
      });
    } catch (error) {
      console.error('Error in Node.js recommendations controller:', error.message);
      return res.status(500).json({ message: 'Error retrieving recommendations from Hugging Face Space.' });
    }
  }

