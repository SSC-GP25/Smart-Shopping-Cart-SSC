const axios = require('axios');

const FASTAPI_ENDPOINT = 'http://127.0.0.1:8080/recommendations/json';

/**
 * Call the FastAPI recommendations endpoint
 * @param {string} user_id - The ID of the user for whom to get recommendations.
 * @param {Number} topK - Number of recommendations to retrieve.
 * @returns {Promise<Object>} - The JSON response containing recommendations.
 */
async function fetchRecommendationsFromFastAPI(user_id, topK = 30) {
  try {
    const formData = new URLSearchParams();
    formData.append('user_id', user_id);
    formData.append('top_k', topK);

    const response = await axios.post(FASTAPI_ENDPOINT, formData, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    });
    console.log(response);
    return response.data;
  } catch (error) {
    console.error('Error fetching recommendations from FastAPI:', error.response ? error.response.data : error.message);
    throw error;
  }
}


/**
 * Call the FastAPI recommendations endpoint using userId and likedCategories.
 * @param {string} userId - The ID of the user for whom to get recommendations.
 * @param {Array} likedCategories - List of liked categories by the user.
 * @param {Number} topK - Number of recommendations to retrieve.
 * @returns {Promise<Object>} - The JSON response containing recommendations.
 */
async function fetchCategoryRecommendations(userId, topK = 30, likedCategories = []) {
  try {
    const requestData = new URLSearchParams();
    requestData.append("user_id", userId);
    requestData.append("top_k", topK);

    // if (typeof likedCategories === 'string') {
    //   likedCategories = likedCategories.split(',');
    // }

    // Ensure likedCategories is an array
    if (Array.isArray(likedCategories)) {
      likedCategories.forEach(category => {
        requestData.append("likedCategories", category);
      });
    }

    const response = await axios.post(FASTAPI_ENDPOINT, requestData, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    });

    return response.data;
  } catch (error) {
    console.error('Error fetching category-based recommendations:', error.response ? error.response.data : error.message);
    throw error;
  }
}

module.exports = { fetchRecommendationsFromFastAPI, fetchCategoryRecommendations };
