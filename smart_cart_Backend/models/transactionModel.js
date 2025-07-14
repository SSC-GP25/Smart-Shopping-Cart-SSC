const mongoose = require('mongoose');

const TransactionSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
    },
    products: [
        {
            productID: {
                type: mongoose.Schema.Types.ObjectId,
                ref: "Product",
                required: true,
            },
            quantity: {
                type: Number,
                required: true,
                min: 1,
            },
            price: {
                type: Number,
                min: 0,
            },
            user_rating: {
                type: Number,
                min: 1,
                max: 5,
                default: 5,
            },
            is_rated: {
                type: Boolean,
                default: false,
            },
            rating_time: {
                type: Date,
                default: null
            },
            _id: false
        },
    ],
    totalAmount: {
        type: Number,
        required: true,
        min: 0,
    },
    stripeSessionId: {
        type: String,
        unique: true,
    },
    paymentMethod: {
        type: String,
        enum: ['Visa', 'Cash'],
        required: true,
    },
    visa: {
        type: Number,
    },
    transactionId: {
        type: String,
        unique: true,
    },
    date: {
        type: Number,
    }

}, { timestamps: true });

const Transaction = mongoose.model("Transaction", TransactionSchema);

module.exports = Transaction;
