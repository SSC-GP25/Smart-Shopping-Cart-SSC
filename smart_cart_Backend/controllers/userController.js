const User = require("../models/userModel"); 
const Category = require("../models/categoryModel");
const cloudinary = require('../utils/cloudinary');
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const { redis } = require("../lib/redis");
exports.getRecommendedProducts = async (req, res) => {
    try {
        const { userId } = req.params;

        const user = await User.findById(userId).populate("recProducts");

        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        res.status(200).json({
            count: user.recProducts.length,
            recProducts: user.recProducts
        });
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
};

exports.getCategoriesNames = async (req, res) => {
  try {
    const categories = await Category.find({}).select('title');
    if(!categories.length){
      return res.status(404).json({ message: "No categories found" });
    }
    res.status(200).json({ 
      status: "success",  
      results: categories.length, 
      data:{
        categories: categories
      } 
    });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
}

exports.saveLikedCategories = async (req, res) => {
  const {likedCategories} = req.body;
  try{
      const user = req.user;
      if(!user){
        return res.status(400).json({ 
          status: "fail",
          message: "invalid user, please Login" });
      }
      if(likedCategories.length <= 0 || !likedCategories){
        return res.status(400).json({ 
          status: "fail", 
          message: "Choose liked categories" });
      }
      user.likedCategories = likedCategories;
      await user.save();

      res.status(200).json({ 
        status: "success",  
        results: likedCategories.length, 
        data:{
          likedCategories: likedCategories
        } 
      });
  }catch(error){
    console.error('Error in Node.js saveLikedCategories controller:', error.message);
    return res.status(500).json({ message: "Server error", error: error.message });
  }
}

exports.updateUser = async (req, res) => {
  const { id } = req.params;
  const { name, email, profilePic, country, birthday, password } = req.body;

  try {
    if (!id) {
      return res.status(400).json({ message: "Invalid User ID" });
    }

    console.log("🔍 Received Update Data:", req.body);

    const currentUser = await User.findById(id);
    if (!currentUser) {
      return res.status(404).json({ message: "User not found" });
    }

    const updates = {};

    if (profilePic && profilePic !== currentUser.profilePic) {
      console.log("📸 Profile image URL has changed...");

      try {
        if (currentUser.profilePic) {
          if (currentUser.profilePic === "https://static.vecteezy.com/system/resources/thumbnails/018/742/015/small/minimal-profile-account-symbol-user-interface-theme-3d-icon-rendering-illustration-isolated-in-transparent-background-png.png") {
            console.log("✅ Old profile image is default, no need to delete");
          } else {
            const publicId = currentUser.profilePic.split("/user/")[1].split(".")[0];
            await cloudinary.uploader.destroy(`user/${publicId}`);
            console.log("✅ Old profile image deleted from Cloudinary");
          }
        }

        updates.profilePic = profilePic;
      } catch (err) {
        console.error("⚠️ Error deleting old image from Cloudinary:", err);
        return res.status(500).json({ message: "Error deleting old image", error: err.message });
      }
    }

    if (name && name !== currentUser.name) updates.name = name;
    if (email && email !== currentUser.email) updates.email = email;
    if (country && country !== currentUser.country) updates.country = country;
    if (birthday && birthday !== currentUser.birthDate) updates.birthDate = birthday;

    if (password && password !== currentUser.password) {
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);
      updates.password = hashedPassword;  // Save the hashed password
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ message: "No changes detected" });
    }

    const updatedUser = await User.findByIdAndUpdate(id, updates, { new: true, runValidators: true });

    console.log("✅ Updated User:", updatedUser);

    res.status(200).json({
      status: "success",
      message: "User updated successfully",
      user: updatedUser,
    });
  } catch (error) {
    console.error("❌ Error updating user:", error.message);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};



exports.deleteUser = async (req, res) => {
  const id = req.params.id;

  try {
    if (!id) {
      return res.status(400).json({ message: "Invalid User ID" });
    }

    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Handle profile picture deletion
    if (user.profilePic && user.profilePic !== "https://static.vecteezy.com/system/resources/thumbnails/018/742/015/small/minimal-profile-account-symbol-user-interface-theme-3d-icon-rendering-illustration-isolated-in-transparent-background-png.png") {
      try {
        const publicId = user.profilePic.split("/user/")[1].split(".")[0];
        await cloudinary.uploader.destroy(`user/${publicId}`);
        console.log("✅ User profile image deleted from Cloudinary");
      } catch (err) {
        console.error("⚠️ Error deleting user image from Cloudinary:", err);
        return res.status(500).json({ message: "Error deleting user image", error: err.message });
      }
    }

    // Handle refresh token removal from Redis
    const refreshToken = req.cookies.refreshToken || req.body.refreshToken;
    if (refreshToken) {
      try {
        const decode = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);
        await redis.del(`refresh_token_${decode.userId}`);
      } catch (err) {
        console.error("⚠️ Error removing refresh token:", err);
      }
    }

    // Clear authentication cookies
    res.clearCookie("accessToken");
    res.clearCookie("refreshToken");

    // Delete user from database
    await User.findByIdAndDelete(id);

    res.status(200).json({ message: "User deleted successfully" });
  } catch (error) {
    console.error("❌ Error in deleteUser controller:", error.message);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};


// // Add Recommended Products for a User
// exports.addRecommendedProducts = async (req, res) => {
//     const { userId } = req.params;
//     const { productIds } = req.body; // Expecting an array of product IDs
  
//     try {
//       const user = await User.findById(userId);
  
//       if (!user) {
//         return res.status(404).json({ message: "User not found" });
//       }
  
//       const products = await Product.find({ _id: { $in: productIds } });
  
//       if (products.length !== productIds.length) {
//         return res.status(400).json({ message: "Some products do not exist" });
//       }
  
//       user.recProducts = [];
  
//       user.recProducts = productIds;
  
//       await user.save();
  
//       res.status(200).json({ message: "Recommended products updated", recProducts: user.recProducts });
//     } catch (error) {
//       res.status(500).json({ message: "Server error", error: error.message });
//     }
// };
  
  

