const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      unique: false
    },
    user_id:{
      type: String,
      required: true,
      unique: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
    },
    password: {
      type: String,
      required: true,
    },
    profilePic: {
      type: String,
      default: "https://static.vecteezy.com/system/resources/thumbnails/018/742/015/small/minimal-profile-account-symbol-user-interface-theme-3d-icon-rendering-illustration-isolated-in-transparent-background-png.png"
    },
    notifications: [
      { type: mongoose.Schema.Types.ObjectId, ref: "Notification" },
    ],
    country: {
      type: String,
      default: "Egypt"
    },
    birthDate: {
      type: Date,
    },
    gender: {
      type: String,
    },
    isAdmin: {
      type: Boolean,
      default: false
    },
    cartItems: [
      {
        quantity: {
          type: Number,
          default: 0
        },
        product: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Product"
        }
      }
    ],
    recProducts: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Product',
      }
    ],
    lastLogin: {
      type: Date,
      default: Date.now(),
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    resetPasswordToken: String,
    resetPasswordExpiresAt: Date,
    verficationToken: String,
    verficationTokenExpiresAt: Date,
    failedLoginAttempts: {
      type: Number,
      default: 0
    },
    lockUntil: {
      type: Date,
      default: undefined,
    },
    resetPasswordAttempts: {
      count: { type: Number, default: 0 },
      lastAttempt: { type: Date },
    },
    verifyEmailCodeAttempts: {
      count: { type: Number, default: 0 },
      lastAttempt: { type: Date },
    },
    likedCategories: [
      {type: String,}
    ],
    totalSpent: {
      type: Number,
      default: 0
    },
    totalTransactions: {
      type: Number,
      default: 0
    },
    active:{
      type: Date,
    },
    stripeCustomerId: {
      type: String,
    }
  },
  { timestamps: true }
);
// userSchema.pre("save", async function (next) {
//   if (!this.isModified("password")) {
//     return next();
//   }

//   try {
//     const salt = await bcrypt.genSalt(10);
//     this.password = await bcrypt.hash(this.password, salt);
//     next();
//   } catch (error) {
//     next(error);
//   }
// });

// userSchema.methods.isPasswordMatched = function (password) {
//   return bcrypt.compareSync(password, this.password);
// };


//(pre-save hook): hash the user password before we save our user --> run this function
userSchema.pre('save', async function (next) {
  // only hash the password if it has been modified (hasent been changed)
  if (!this.isModified('password')) return next();
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next(); // to call the next middleware
  } catch (error) {
    next(error);
  }
});

// to check for the password of the current user, to check credentials
userSchema.methods.comparePassword = async function (password) {
  return await bcrypt.compare(password, this.password);
};

const User = mongoose.model("User", userSchema);

module.exports = User;

