const express = require("express");

const router = express.Router();

const authController = require("../controllers/authController");

const { protectRoute } = require("../middleware/auth.middleware");

const { validateUserLogin, validateUserSignup, validatePassword } = require("../middleware/validators/authValidator");


/**
 * @swagger
 * /auth/signup:
 *   post:
 *     summary: Create a new user account
 *     description: Sign up a new user with name, email, password, country, profilePic, and admin status. Also sends a verification email.
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - password
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               country:
 *                 type: string
 *               profilePic:
 *                 type: string
 *               isAdmin:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: User created successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 newUser:
 *                   type: object
 *                   properties:
 *                     _id:
 *                       type: string
 *                     name:
 *                       type: string
 *                     email:
 *                       type: string
 *                     isAdmin:
 *                       type: boolean
 *                     lastLogin:
 *                       type: string
 *                       format: date-time
 *       400:
 *         description: User already exists or bad request.
 *       500:
 *         description: Server error.
 */

// http://localhost:5000/api/auth/signup
router.post("/signup", validateUserSignup, authController.Signup);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Authenticate a user
 *     description: Logs in a user by validating the email and password. It also manages failed attempts and account lockouts.
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful, returns user details.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 _id:
 *                   type: string
 *                 name:
 *                   type: string
 *                 email:
 *                   type: string
 *                 isAdmin:
 *                   type: boolean
 *                 lastLogin:
 *                   type: string
 *                   format: date-time
 *       401:
 *         description: Invalid email or password.
 *       403:
 *         description: Account is locked.
 *       500:
 *         description: Server error.
 */

// http://localhost:5000/api/auth/login
router.post("/login", validateUserLogin, authController.Login);


/**
 * @swagger
 * /auth/logout:
 *   post:
 *     summary: Logout a user
 *     description: Clears the access and refresh token cookies and removes the refresh token from the store.
 *     tags:
 *       - Authentication
 *     responses:
 *       200:
 *         description: Logged out successfully.
 *       500:
 *         description: Server error.
 */

// http://localhost:5000/api/auth/logout
router.post("/logout", protectRoute, authController.Logout);

/**
 * @swagger
 * /auth/refresh-token:
 *   post:
 *     summary: Refresh access token
 *     description: Generates a new access token based on the valid refresh token.
 *     tags:
 *       - Authentication
 *     responses:
 *       200:
 *         description: Access token refreshed successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 accessToken:
 *                   type: string
 *                 message:
 *                   type: string
 *       401:
 *         description: Missing or invalid refresh token.
 *       403:
 *         description: Refresh token expired, please log in again.
 *       500:
 *         description: Server error.
 */

// http://localhost:5000/api/auth/refresh-token
router.post("/refresh-token", authController.refreshToken);

/**
 * @swagger
 * /auth/profile:
 *   get:
 *     summary: Retrieve user profile
 *     description: Returns the profile of the authenticated user.
 *     tags:
 *       - Authentication
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile retrieved successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               example:
 *                 _id: "userId"
 *                 name: "User Name"
 *                 email: "user@example.com"
 *                 isAdmin: false
 *       401:
 *         description: Unauthorized access.
 *       500:
 *         description: Server error.
 */

// http://localhost:5000/api/auth/profile
router.get("/profile", protectRoute, authController.getProfile)

/**
 * @swagger
 * /auth/verifyEmail:
 *   post:
 *     summary: Verify user email
 *     description: Verifies the user's email using a provided verification code.
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - code
 *             properties:
 *               code:
 *                 type: string
 *     responses:
 *       200:
 *         description: User verified successfully.
 *       400:
 *         description: Invalid or expired verification code.
 *       429:
 *         description: Verification limit reached for today.
 *       500:
 *         description: Server error.
 */

// https://localhost:3000/api/auth/verifyEmail
router.post("/verifyEmail", protectRoute, authController.verifyEmail)

/**
 * @swagger
 * /auth/password-recovery:
 *   post:
 *     summary: Initiate password recovery
 *     description: Sends a password reset email if the user exists.
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: Password recovery email sent successfully.
 *       400:
 *         description: User not found.
 *       429:
 *         description: Password reset limit reached for today.
 *       500:
 *         description: Server error.
 */

// https://localhost:3000/api/auth/password-recovery
router.post("/password-recovery", protectRoute, authController.forgotPassword)

/**
 * @swagger
 * /auth/reset-password/{token}:
 *   post:
 *     summary: Reset user password
 *     description: Resets the user's password using the provided token.
 *     tags:
 *       - Authentication
 *     parameters:
 *       - in: path
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         description: The reset password token sent via email.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - password
 *             properties:
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Password updated successfully.
 *       400:
 *         description: Invalid or expired reset password token.
 *       429:
 *         description: Password reset limit reached for today.
 *       500:
 *         description: Server error.
 */

// https://localhost:3000/api/auth/reset-password/:token
router.post("/reset-password/:token", protectRoute, validatePassword, authController.resetPawssord)

/**
 * @swagger
 * /auth/regenerate-verification-code:
 *   post:
 *     summary: Regenerate verification code
 *     description: Generates a new email verification code and sends it to the user's email.
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: Verification code has been sent to your email.
 *       400:
 *         description: User not found or user already verified.
 *       500:
 *         description: Server error.
 */

// https://localhost:3000/api/auth/regenerate-verification-code
router.post("/regenerate-verification-code", protectRoute, authController.regenerateVerificationCode)

module.exports = router;