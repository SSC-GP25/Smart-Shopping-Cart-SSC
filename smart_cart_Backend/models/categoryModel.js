const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
        unique: true,
        trim: true
    },
    description: {
        type: String,
        required: true,
        trim: true
    },
    image: {
        type: String,
        default: 'https://img.icons8.com/fluent/200/instructure.png',
        // required: true,
    },

},{
    timestamps: true 
});

const Category = mongoose.model('Category',categorySchema);

module.exports = Category;