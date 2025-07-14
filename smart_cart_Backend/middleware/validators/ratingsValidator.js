const Joi = require("joi");

const ratingSchema = Joi.object({
    productID: Joi.string()
        .length(24) // MongoDB ObjectId is 24 chars
        .hex() // Ensure it’s a valid hex string
        .required()
        .messages({
            'string.length': 'productID must be a 24-character ObjectId',
            'string.hex': 'productID must be a valid hexadecimal string',
            'any.required': 'productID is required',
        }),
    userRating: Joi.number()
        .integer()
        .min(1)
        .max(5)
        .required()
        .messages({
            'number.base': 'userRating must be a number',
            'number.integer': 'userRating must be an integer',
            'number.min': 'userRating must be at least 1',
            'number.max': 'userRating must not exceed 5',
            'any.required': 'userRating is required',
        }),
});

const ratingsArraySchema = Joi.array()
    .items(ratingSchema)
    .min(1)
    .required()
    .messages({
        'array.min': 'Ratings array must contain at least one rating',
        'any.required': 'Ratings array is required',
    });

const paramsSchema = Joi.object({
    orderId: Joi.string()
        .length(24)
        .hex()
        .required()
        .messages({
            'string.length': 'orderId must be a 24-character ObjectId',
            'string.hex': 'orderId must be a valid hexadecimal string',
            'any.required': 'orderId is required',
        }),
});

function ratingsValidation(req, res, next) {
    // Flatten req.body if nested (e.g., [[{...}]] → [{...}])
    let ratings = req.body;
    if (Array.isArray(ratings) && Array.isArray(ratings[0])) {
        ratings = ratings.flat();
    }

    // Validate req.params
    const { error: paramsError } = paramsSchema.validate(req.params);
    if (paramsError) {
        return res.status(400).json({
            success: false,
            message: paramsError.details[0].message,
        });
    }

    // Validate req.body
    const { error: bodyError } = ratingsArraySchema.validate(ratings);
    if (bodyError) {
        return res.status(400).json({
            success: false,
            message: bodyError.details[0].message,
        });
    }

    next();
};

module.exports = { ratingsValidation }; 