const Transaction = require("../models/transactionModel");

exports.addRating = async (req, res, next) => {
    try {
        const { orderId } = req.params;
        const ratings = req.body;
        const userID = req.user._id;

        const order = await Transaction.findOne({ _id: orderId, user: userID });
        if (!order) {
            return res.status(404).json({
                status: 'fail',
                message: 'order not found'
            });
        }
        order.products.forEach(product => {
            const ratingData = ratings.find(r => r.productID === product.productID.toString());
            if (ratingData) {
                product.user_rating = ratingData.userRating;
                product.is_rated = true;
                product.rating_time = new Date();
            }
        });
        await order.save();
        return res.status(200).json({
            status: 'success',
            order: order,
        });

    } catch (error) {
        console.error('Error in addRating controller:', error.message);
        return res.status(500).json({ message: error.message });
    }
}