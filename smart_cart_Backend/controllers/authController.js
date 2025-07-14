const User = require('../models/userModel');
const jwt = require("jsonwebtoken");
const { redis } = require("../lib/redis");
const cloudinary = require('../utils/cloudinary');
const crypto = require("crypto");
const bcrypt = require("bcryptjs");
const axios = require("axios");

const dotenv = require('dotenv');
dotenv.config({ path: 'config.env' });

const generateVerficationToken = require("../utils/generateVerificationCode");
const { sendVerificationEmail, sendWelcomeEmail, sendPasswordResetEmail, sendResetSuccessfulEmail } = require("../nodemailer/emails");

const MAX_FAILED_ATTEMPTS = 3;
const LOCK_TIME = 30 * 60 * 1000; // 30 minutes lock time
let USERCOUNT = 152;

function generateUserId() {
    return Math.floor(1000000000 + Math.random() * 9000000000);
}

const generateToken = (userId) => {
    const accessToken = jwt.sign({ userId }, process.env.ACCESS_TOKEN_SECRET, { expiresIn: "15m" });
    // console.log(accessToken);
    const refreshToken = jwt.sign({ userId }, process.env.REFRESH_TOKEN_SECRET, { expiresIn: "1h" });
    // console.log(refreshToken);
    return { accessToken, refreshToken };
};
const storeRefreshToken = async (userId, refreshToken) => {
    await redis.set(`refresh_token_${userId}`, refreshToken, "EX", 60 * 60 * 1000); // expire in 1h
};
const setCookies = async (res, accessToken, refreshToken) => {
    res.cookie("accessToken", accessToken, {
        httpOnly: true, // to prevent XXS attacks
        secure: process.env.NODE_ENV === "production",
        sameSite: "strict", // to prevent CSRF attacks
        maxAge: 15 * 60 * 1000, // 15 minutes
    });

    res.cookie("refreshToken", refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "strict",
        maxAge: 60 * 60 * 1000, // 1h
    });
};

const attemptLimitExceeded = (attemptRecord, limit) => {
    const ONE_DAY = 24 * 60 * 60 * 1000;

    if (!attemptRecord || !attemptRecord.lastAttempt) return false;

    const timeSinceLastAttempt = Date.now() - new Date(attemptRecord.lastAttempt).getTime();

    if (timeSinceLastAttempt > ONE_DAY) {
        // Reset the counter after 24 hours
        attemptRecord.count = 0;
        return false;
    }

    return attemptRecord.count >= limit;
};

const updateAttemptRecord = (attemptRecord) => {
    attemptRecord.count += 1;
    attemptRecord.lastAttempt = new Date();
};

exports.Signup = async (req, res, next) => {
    const { name, email, password, country, profilePic, isAdmin, birthDate, gender } = req.body;
    try {
        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({ message: "User already exists" });
        }
        let cloudinaryResponse = null;
        if (profilePic) {
            cloudinaryResponse = await cloudinary.uploader.upload(profilePic, { folder: "users" });
        }
        // generate verification code:
        const verificationToken = generateVerficationToken();
        let userId;
        let existingUserId;

        do {
            userId = generateUserId();
            existingUserId = await User.findOne({ user_id: userId });
        } while (existingUserId);

        const newUser = await User.create({
            name: name,
            email: email,
            password: password,
            profilePic: cloudinaryResponse ? cloudinaryResponse.secure_url : "https://static.vecteezy.com/system/resources/thumbnails/018/742/015/small/minimal-profile-account-symbol-user-interface-theme-3d-icon-rendering-illustration-isolated-in-transparent-background-png.png",
            country: country,
            isAdmin: isAdmin,
            verficationToken: verificationToken,
            verficationTokenExpiresAt: Date.now() + 10 * 60 * 1000, // expires in 10 minutes
            user_id: userId,
            birthDate: birthDate,
            gender: gender,
        });

        // authenticate user 
        const { accessToken, refreshToken } = generateToken(newUser._id);

        await storeRefreshToken(newUser._id, refreshToken);

        setCookies(res, accessToken, refreshToken);
        // send verification email:
        if (newUser.isAdmin) {
            await sendVerificationEmail(process.env.ADMIN_EMAIL_ADDRESS, verificationToken);
        } else {
            await sendVerificationEmail(newUser.email, verificationToken);
        }
        // save last login to the database
        newUser.lastLogin = Date.now();
        let stripeCustomer;
        try {
            const response = await axios.post(
                "https://api.stripe.com/v1/customers",
                new URLSearchParams({ name: newUser.name, email: newUser.email }).toString(),
                { headers: { Authorization: `Bearer ${process.env.STRIPE_SECRET_KEY}`, "Content-Type": "application/x-www-form-urlencoded" } }
            );
            stripeCustomer = response.data;
            newUser.stripeCustomerId = stripeCustomer.id;
        } catch (error) {
            return res.status(500).json({ success: false, message: "Stripe API error", error: error.response?.data });
        }
        await newUser.save();


        return res.status(200).json({
            message: "user created successfully",
            token: accessToken,
            newUser: {
                _id: newUser._id,
                name: newUser.name,
                email: newUser.email,
                isAdmin: newUser.isAdmin,
                lastLogin: newUser.lastLogin,
                user_id: newUser.user_id,
                birthDate: newUser.birthDate
            },
        });

    } catch (error) {
        console.log("Error in signup controller", error.message);
        res.status(500).json({ message: error.message });
    }

};

exports.Login = async (req, res) => {
    try {
        // ================== is verified flag
        const { email, password } = req.body;
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(401).json({ message: "Invalid email or password" });
        }
        // Check if account is locked
        if (user.lockUntil > Date.now()) {
            return res.status(403).json({
                lockUntil: user.lockUntil,
                message: "Account locked. Please try again later."
            });
        }

        // Check if password is correct
        if (await bcrypt.compare(password, user.password)) {
            // Reset failed login attempts on successful login
            user.failedLoginAttempts = 0;
            user.lockUntil = undefined;

            const { accessToken, refreshToken } = generateToken(user._id);
            await storeRefreshToken(user._id, refreshToken);
            setCookies(res, accessToken, refreshToken);

            user.lastLogin = new Date();
            let firstTime = true;
            if (user.likedCategories.length < 0) {
                firstTime = false;
            }
            await user.save();
            return res.status(200).json({
                accessToken: accessToken,
                refreshToken: refreshToken,
                _id: user._id,
                name: user.name,
                email: user.email,
                firstTime: firstTime,
                isAdmin: user.isAdmin,
                lastLogin: user.lastLogin,
                user_id: user.user_id,
                stripeCustomerId: user.stripeCustomerId,
            });
        } else {
            // Increment failed login attempts
            user.failedLoginAttempts += 1;
            if (user.failedLoginAttempts >= MAX_FAILED_ATTEMPTS) {
                user.lockUntil = Date.now() + LOCK_TIME; // Lock account for 30 minutes 
            }
            await user.save();
            return res.status(401).json({
                invalidAttempts: user.failedLoginAttempts,
                message: "Invalid email or password"
            });
        }
    } catch (error) {
        console.log("Error in login controller", error.message);
        res.status(500).json({ message: error.message });
    }
};

exports.Logout = async (req, res, next) => {
    try {
        const refreshToken = req.cookies.refreshToken || req.body.refreshToken;
        if (refreshToken) {
            // delete refresh token from redis if existed
            const decode = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET); // decode it because we have the userId in it
            await redis.del(`refresh_token_${decode.userId}`);
        }
        // clear them from the cookies
        res.clearCookie("accessToken");
        res.clearCookie("refreshToken");

        return res.status(200).json({ message: "Logged out successfully" });
    } catch (error) {
        console.log("Error in logout controller", error.message);
        res.status(500).json({ message: "Server error", error: error.message });
    }
};


// create refresh token api --> recreate the access token 
exports.refreshToken = async (req, res, next) => {
    try {
        const refreshToken = req.cookies.refreshToken || req.body.refreshToken;
        // if no refresh token --> error
        if (!refreshToken) {
            return res.status(401).json({ message: "no refresh token found!" });
        }
        // if found then check if the token is valid, if valid then re generate access token , if not then logout
        // decode the token using the secret
        const decode = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);
        // get the token from redis database
        const storedToken = await redis.get(`refresh_token_${decode.userId}`);
        if (storedToken !== refreshToken) {
            return res.status(401).json({ message: "invalid refresh token" });
        }
        // if the tokens match, correct user not a hacker then create a new access token and save it to cookies
        const accessToken = jwt.sign({ userId: decode.userId }, process.env.ACCESS_TOKEN_SECRET, { expiresIn: "15m" });

        res.cookie("accessToken", accessToken, {
            httpOnly: true, // to prevent XXS attacks
            secure: process.env.NODE_ENV === "production",
            sameSite: "strict", // to prevent CSRF attacks
            maxAge: 15 * 60 * 1000 // 15 minutes
            // maxAge: 2 * 24 * 60 * 60 * 1000 // 2 days
        });
        await User.findByIdAndUpdate(decode.userId, { active: new Date() });
        return res.status(200).json({ accessToken: accessToken, message: "accessToken refreshed!" });

    } catch (error) {
        if (error.name === "TokenExpiredError") {
            return res.status(403).json({ message: "Refresh token expired, please log in again" });
        }
        console.log("Error in refresh token controller", error.message);
        res.status(500).json({ message: "An error occurred. Please try again later." });
    }
};

exports.forgotPassword = async (req, res) => {
    const { email } = req.body;
    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ message: "user not found!" });
        }
        // Check if reset password attempts exceed limit
        if (attemptLimitExceeded(user.resetPasswordAttempts, 3)) {
            return res.status(429).json({
                resetPasswordAttempts: user.resetPasswordAttempts,
                message: "Password reset limit reached for today. Try again tomorrow."
            });
        }

        // Update the attempt record
        updateAttemptRecord(user.resetPasswordAttempts);
        // generate reset token
        const resetToken = crypto.randomBytes(20).toString("hex");
        const resetTokenExpiresAt = Date.now() + 1 * 60 * 60 * 1000; // expires in 1 hour
        user.resetPasswordToken = resetToken;
        user.resetPasswordExpiresAt = resetTokenExpiresAt;

        // update the database
        await user.save();                  //https://SSC/reset-password/890172438900hd879
        // send reset email
        await sendPasswordResetEmail(user.email, `${process.env.CLIENT_URL}/reset-password/${resetToken}`);

        res.status(200).json({ message: "Reset password email sent successfully!" });
    } catch (error) {
        console.log("Error in forgotPassword: ", error.message)
        res.status(500).json({ message: "An error occurred. Please try again later." });
    }
};

exports.resetPawssord = async (req, res) => {
    const { password } = req.body;
    const { token } = req.params;
    try {
        const user = await User.findOne({
            resetPasswordToken: token,
            resetPasswordExpiresAt: { $gt: Date.now() },
        });
        console.log(user);
        if (!user) {
            return res.status(400).json({ message: "Invalid or expired reset password token!" });
        }
        // Check if password reset attempts exceed the limit
        if (attemptLimitExceeded(user.resetPasswordAttempts, 3)) {
            return res.status(429).json({ message: "Password reset limit reached for today. Try again tomorrow." });
        }

        //update password, hash it first
        const hashedPassword = await bcrypt.hash(password, 10);
        user.password = hashedPassword;

        // remove the tokens from the database
        user.resetPasswordToken = undefined;
        user.resetPasswordExpiresAt = undefined;

        // Update reset attempts record
        updateAttemptRecord(user.resetPasswordAttempts);

        await user.save();
        await sendResetSuccessfulEmail(user.email);

        return res.status(200).json({ message: "password updated successfuly" })
    } catch (error) {
        console.log("Error in forgotPassword: ", error.message);
        res.status(500).json({ message: "An error occurred. Please try again later." });
    }
};

exports.verifyEmail = async (req, res) => {
    const { code } = req.body;
    try {
        // find the sent verification code from the database, and check if it is still valid (not expired)
        const user = await User.findOne({
            verficationToken: code,
            verficationTokenExpiresAt: { $gt: Date.now() },
        });
        if (!user) {
            return res.status(400).json({ message: "Invalid or expired verification code" });
        }
        // Check if verification attempts exceed the limit 
        if (attemptLimitExceeded(user.verifyEmailCodeAttempts, 3)) {
            return res.status(429).json({ message: "Verification limit reached for today. Try again tomorrow." });
        }
        // Update verification attempt record
        updateAttemptRecord(user.verifyEmailCodeAttempts);
        // if user is found, verify = true and delete the code from the database
        user.isVerified = true;
        user.verficationToken = undefined;
        user.verficationTokenExpiresAt = undefined;

        // save the changes to the database
        await user.save();

        // send welcome email
        await sendWelcomeEmail(user.email, user.name);

        return res.status(200).json({ message: "user verified!" })
    } catch (error) {
        console.log("Error in verify email ", error);
        res.status(400).json({ success: false, message: error.message });
    }

};

exports.getProfile = async (req, res) => {
    try {
        res.json(req.user);
    } catch (error) {
        console.log("Error in get profile controller", error.message);
        res.status(500).json({ message: "Server error", error: error.message });
    }
};

exports.regenerateVerificationCode = async (req, res) => {
    const { email } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ message: "User not found" });
        }
        if (user.isVerified) {
            return res.status(400).json({ message: "user already verified" })
        }
        // Generate a new verification token
        const verificationToken = generateVerficationToken();
        user.verficationToken = verificationToken;
        user.verficationTokenExpiresAt = Date.now() + 10 * 60 * 1000; // expires in 10 minutes

        await user.save();

        // Send new verification email
        await sendVerificationEmail(user.email, verificationToken);

        return res.status(200).json({ message: "Verification code has been sent to your email" });
    } catch (error) {
        console.log("Error regenerating verification code", error.message);
        return res.status(500).json({ message: "Server error", error: error.message });
    }
};