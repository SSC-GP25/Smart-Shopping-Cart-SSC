const axios = require('axios');

const SPACE_API_URL = "https://FarahMohsenSamy1-debug.hf.space/recommend";

async function fetchRecommendationsHF(customerId, numItems, categories) {
  try {
      // Prepare query parameters for the GET request
      const params = {
          user_id: customerId,
          top_k: numItems,
          liked_categories: categories
      };

      const response = await axios.get(SPACE_API_URL, {
          params,
          headers: { 'Accept': 'application/json' }
      });
      console.log('Hugging Face Response:', response.data);
      return response.data; // Return the raw JSON response
  } catch (error) {
      console.error('Error fetching recommendations:', error.response ? error.response.data : error.message);
      throw error; // Let the controller handle the error
  }
}



// For dedicated Inference Endpoint (replace SPACE_ENDPOINT accordingly):
async function fetchRecommendationsEndpoint(inputs) {
  const hf = client.endpoint(SPACE_ENDPOINT);
  const result = await hf.textGeneration({ inputs });
  return result;
}

module.exports= {
    fetchRecommendationsHF,
    fetchRecommendationsEndpoint
}