const mongoose = require('mongoose');
const setAisle = require('../middleware/productMiddleWare/setAisle');
const setItem_ID = require('../middleware/productMiddleWare/setItemID');

const productSchema = new mongoose.Schema({
    // Required Fields
    title: {
        type: String,
        required: true,
        trim: true,
        unique: true, // Ask Ai team
        index: true
    },
    item_id: {
        type: String,
        trim: true,
        index: true
    },
    price: {
        type: Number,
        required: true,
    },
    description: {
        type: String,
        required: true,
        trim: true
    },
    category: {
        type: String,
        required: true,
    },
    genderCategory: {
        type: String,
    },
    productBrand: {
        type: String,
    },
    productType: {
        type: String,
    },
    weight: {
        type: Number,
        required: true,
        min: 0,
    },
    barcode: {
        type: String,
        default: '',
        trim: true,
        unique: true
    },

    // Optional Fields with Defaults and Other Properties
    image: {
        type: String,
        default: 'https://img.freepik.com/premium-vector/black-icon-open-cardboard-box-receive-your-order_124715-2429.jpg',
        trim: true,
        // required: true,
    },
    tags: [{
        type: String,
        trim: true,
    }],
    isAvailable: {
        type: Boolean,
        default: true,
    },
    discount: {
        type: Number,
        default: 0,
        min: 0,
        max: 100,
    },
    aisle: {
        type: String,
    },

    // Rating, Inventory, and Sales Information
    rating: {
        type: Number,
        default: 0,
        min: 0,
        max: 5,
        required: true
    },
    inventory: {
        type: Number,
        default: 0
    },
    sales: {
        type: Number,
        default: 0
    },

    // Buyer Information (Optional, Can Be Populated)
    broughtBy: {
        type: Array,
        default: [],
    },
    // Will Be used when creating users
    // boughtBy: [{
    //     type: mongoose.Schema.Types.ObjectId,
    //     ref: 'User', // Refers to the User model
    //   }],

    // Section and Aisle (Used for Map Positioning)
    section: {
        type: String,
        required: true,
        // Updated Manually 
        enum: ['Electronics', 'Clothing', 'Groceries', 'Furniture', 'Books', 'Home Improvement', 'Home Improvement', 'Food'],
    },
    x: {
        type: Number,
        default: 2,
        max: 23,
        min: 2
    },
    y: {
        type: Number,
        default: 2,
        max: 43,
        min: 2
    }

}, {
    timestamps: true
});

productSchema.pre('save', setAisle);
productSchema.pre('save', setItem_ID);

const Product = mongoose.model('Product', productSchema);

module.exports = Product;
