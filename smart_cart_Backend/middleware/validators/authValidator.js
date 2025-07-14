const Joi = require('joi');

// Password Validation Helpers
const containsUppercase = /[A-Z]/;
const containsSpecialChars = /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~]/;

const authSignupSchema = Joi.object({
  name: Joi.string()
    .min(3)
    .pattern(/^[^\d]/, { name: "cannot start with a number" })
    .pattern(/^\D+$/, { name: "cannot be all numbers" })
    .required()
    .messages({
      "string.empty": "Name is required.",
      "string.min": "Name must be at least 3 characters.",
      "string.pattern.name": "Name cannot start with a number or be all numbers.",
    }),

  email: Joi.string()
    .email({ tlds: { allow: true } })
    .required()
    .messages({
      "string.empty": "Email is required.",
      "string.email": "Please enter a valid email address.",
    }),

  password: Joi.string()
    .min(8)
    .pattern(containsUppercase, { name: "uppercase" })
    .pattern(containsSpecialChars, { name: "special character" })
    .required()
    .messages({
      "string.empty": "Password is required.",
      "string.min": "Password must be at least 8 characters.",
      "string.pattern.name": "Password must include an uppercase letter and a special character.",
    }),
  gender: Joi.string()
    .valid('Male', 'Female')
    .default('Male')
  ,
  birthDate: Joi.date()
    .required()
    .custom((value, helpers) => {
      const birthDate = new Date(value);
      const currentDate = new Date();
      let age = currentDate.getFullYear() - birthDate.getFullYear();
      const monthDiff = currentDate.getMonth() - birthDate.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && currentDate.getDate() < birthDate.getDate())) {
        age--;
      }
      if (age < 13) return helpers.message("Your age must be 13 or older.");
      return value;
    })
    .messages({
      "date.base": "Birthdate must be a valid date.",
      "any.required": "Birthdate is required.",
    }),
    country: Joi.string()
    .min(2),

    profilePic: Joi.string()
    .optional()
});

const authLoginSchema = Joi.object({
  email: Joi.string()
    .email({ tlds: { allow: true } })
    .required()
    .messages({
      "string.empty": "Email is required.",
      "string.email": "Please enter a valid email address.",
    }),

  password: Joi.string()
    .min(8)
    .required()
    .messages({
      "string.empty": "Password is required.",
    }),

});

const authResetPassword = Joi.object({
  password: Joi.string()
    .min(8)
    .required()
    .messages({
      "string.empty": "Password is required.",
    }),

});

function validateUserSignup(req, res, next) {
  const { error } = authSignupSchema.validate(req.body);

  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
    });
  }

  next(); // Proceed if validation passes
}

function validateUserLogin(req, res, next) {
  const { error } = authLoginSchema.validate(req.body);

  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
    });
  }

  next(); // Proceed if validation passes
}
function validatePassword(req, res, next) {
  const { error } = authResetPassword.validate(req.body);

  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
    });
  }

  next(); // Proceed if validation passes
}
module.exports = { validateUserSignup, validateUserLogin, validatePassword };
