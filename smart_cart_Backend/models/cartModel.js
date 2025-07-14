const mongoose = require('mongoose');

const cartSchema = new mongoose.Schema({
    name: {
        type: String,
        unique: true,
        trim: true,
        default: "SMCart-001"
    },
    cartID: {
        type: String,
        unique: true,
        trim: true,
        default: "SMCart-001"
    },
    userID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
    },
    cartProducts: [
        {
            productID: {
                type: mongoose.Schema.Types.ObjectId, 
                ref: 'Product',
            },
            quantity: {
                type: Number,
                default: 1 
            }
        }
    ],
    recProducts: [
        {
            type: mongoose.Schema.Types.ObjectId, 
            ref: 'Product',
            required: true
        }
    ],
    QRCode: {
        type: String
    },
    available: {
        type: Boolean,
        enum: [true, false],
        default: true
    },
    alerts: [
        {
            header: String ,
            message: String,
            timestamp: Date 
        }
    ],

    detection: [
        {
            label: String,
            confidence: Number,
            bbox: [Number],
            status: String, // "in", "out", "error"
            quantity: Number
        }
    ],
    weightReadings: [ 
        {
            value: Number,
            timestamp: Date,
            status: String // "increased", "decreased", "same"
        }
    ]
}, {
    timestamps: true
});


const Cart = mongoose.model('Cart', cartSchema);

module.exports = Cart;
