const jwt = require("jsonwebtoken");
const User = require("../models/userModel");

const dotenv = require('dotenv');
dotenv.config({ path: 'config.env' });

const protectRoute = async (req, res, next) => {
    try {
        let accessToken;

        if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
            accessToken = req.headers.authorization.split(" ")[1];
          }else if (req.cookies && req.cookies.accessToken) {
            // check the cookies for the website
            accessToken = req.cookies.accessToken;
        }
        if (!accessToken) {
            return res.status(401).json({ message: "unauthorized - no access token provided" });
        }
        try {
            const decoded = jwt.verify(accessToken, process.env.ACCESS_TOKEN_SECRET);
            const user = await User.findById(decoded.userId).select("-password"); // return the user without the password

            if (!user) {
                return res.status(401).json({ message: "user not found" });
            }
            req.user = user; // to use the user in different functions
            next();
        } catch (error) {
            if (error.name === "TokenExpiredError") {
                return res.status(401).json({ message: "Access token expired, please refresh the token" });
            }
            throw error;
        }
    } catch (error) {
        console.log("error in protectRoute middleware");
        return res.status(500).json({ message: error.message });
    }
};

const adminRoute = (req, res, next) => {
    try {
        if (req.user && req.user.isAdmin === "true") {
            next();
        } else {
            return res.status(403).json({ message: "forbidden - you are not an admin" });
        }
    } catch (error) {
        console.log("error in adminRoute middleware");
        return res.status(500).json({ message: error.message });
    }
};

module.exports = { protectRoute, adminRoute };