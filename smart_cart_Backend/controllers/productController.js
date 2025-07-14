const Product = require('../models/productModel');
const APIFeatures = require('../utils/apiFeatures');
const cloudinary = require('../utils/cloudinary');
const {deleteItem} = require('../middleware/productMiddleWare/deleteItem');

exports.getAllProducts = async(req, res)=>{
    try {
        const features = new APIFeatures(Product.find(), req.query);
        features.filter().sort().limitFields();


        if (req.query.search) {
            const searchRegex = new RegExp(req.query.search, 'i');
            features.query = features.query.find({
                $or: [
                    { title: { $regex: searchRegex } },
                    { description: { $regex: searchRegex } },
                    { category: { $regex: searchRegex } }
                ]
            });
        }
        features.pagination();
        const products = await features.query;

        const totalCount = await Product.countDocuments();

        res.status(200).json({
            status: 'success',
            totalCount: totalCount,
            results: products.length,
            data: {
                products
            }
        });
    } catch(err) {
        res.status(404).json({
            status: 'fail',
            message: err.message
        })
    }
}
exports.getProduct = async(req, res)=>{
    try {
        const product = await Product.findById(req.params.id);
        res.status(200).json({
            status:'success',
            data: {
                product
            }
        });

    } catch(err) { 
        res.status(404).json({
            status: 'fail',
            message: err.message
        })
    }
}
exports.createProduct = async (req, res) => {
    try {
        console.log(req.body, "In Create Product! ❤️");

        const newProduct = await Product.create(req.body);

        res.status(201).json({
            status: "success",
            message: "Product created successfully!",
            data: {
                product: newProduct
            }
        });

    } catch (err) {
        if (err.name === "ValidationError") {
            const validationErrors = Object.values(err.errors).map(error => error.message);

            return res.status(400).json({
                status: "fail",
                message: "Validation error",
                errors: validationErrors
            });
        }

        res.status(400).json({
            status: "fail",
            message: "Couldn't create the product",
            error: err.message
        });
    }
};



exports.deleteProduct = async (req, res) => {
    try {
        const ids = req.body.ids;  

        const products = await Product.find({ _id: { $in: ids } });

        for (let product of products) {
            if (product.image) {
                if(product.image == "https://img.freepik.com/premium-vector/black-icon-open-cardboard-box-receive-your-order_124715-2429.jpg"){
                    console.log('✅ Old image deleted (default image)')
                  }
                else{
                    const publicId = product.image.split('/products/')[1].split('.')[0]; // Extract public ID
                    try {
                        await cloudinary.uploader.destroy(`products/${publicId}`);
                        console.log(`✅ Image for product ${product.title} deleted from Cloudinary`);
                    } catch (err) {
                        console.error(`Error deleting image for product ${product.title}:`, err);
                    }
                }
                
            }
        }

        const deletedProducts = await Product.deleteMany({
            _id: { $in: ids },
        });

        res.status(200).json({
            status: 'success',
            message: 'Products and their images deleted successfully',
            deletedCount: deletedProducts.deletedCount,
        });
    } catch (err) {
        res.status(500).json({
            status: 'fail',
            message: "Products couldn't be deleted!",
            error: err.message,
        });
    }
};

exports.deleteAllProduct = async (req, res) => {
    try {
        const products = await Product.find();

        for (let product of products) {
            if (product.image) {
                if(product.image == "https://img.freepik.com/premium-vector/black-icon-open-cardboard-box-receive-your-order_124715-2429.jpg"){
                    console.log('✅ Old image deleted (default image)')
                }else{
                    const publicId = product.image.split('/products/')[1].split('.')[0]; // Extract public ID
                    try {
                        await cloudinary.uploader.destroy(`products/${publicId}`);
                        console.log(`✅ Image for product ${product.title} deleted from Cloudinary`);
                    } catch (err) {
                        console.error(`Error deleting image for product ${product.title}:`, err);
                    }  
                }
                
            }
        }

        const deletedProducts = await Product.deleteMany();

        res.status(200).json({
            status: 'success',
            message: 'All products and their images deleted successfully',
            deletedCount: deletedProducts.deletedCount,
        });
    } catch (err) {
        res.status(500).json({
            status: 'fail',
            message: 'Products couldn\'t be deleted!',
            error: err.message,
        });
    }
};

exports.updateProduct = async (req, res) => {
    try {
        const existingProduct = await Product.findById(req.params.id);
        let imageUrl = existingProduct.image;

        if (req.body.image && existingProduct.image !== req.body.image) {
            if(existingProduct.image == "https://img.freepik.com/premium-vector/black-icon-open-cardboard-box-receive-your-order_124715-2429.jpg"){
                console.log('✅ Old image deleted (default image)')
              } else {
                const publicId = existingProduct.image.split('/products/')[1].split('.')[0];
                try {
                    await cloudinary.uploader.destroy(`products/${publicId}`);
                    console.log(`✅ Image for product ${existingProduct.title} deleted from Cloudinary`);
                } catch (err) {
                    console.error(`Error deleting image for product ${existingProduct.title}:`, err);
                }
            }
        }

        const updatedProduct = await Product.findByIdAndUpdate(req.params.id, req.body, {
            new: true,
            runValidators: true
        });

        res.status(200).json({
            status: 'success',
            message: 'Product Updated Successfully',
            data: {
                product: updatedProduct
            }
        });

    } catch (err) {
        res.status(400).json({
            status: 'fail',
            message: 'Product couldn\'t be updated',
            error: err.message,
        });
    }
};

exports.updateProductRating = async (req, res) => {
    console.log("In updateProductRating function");
    try {
        const { productId, rating, id } = req.body;

        if (!productId || !id || rating === undefined) {
            return res.status(400).json({
                status: "fail",
                message: "Missing required fields: productId, rating, or id"
            });
        }

        if (rating < 0 || rating > 5) {
            return res.status(400).json({
                status: "fail",
                message: "Rating must be between 0 and 5"
            });
        }

        const product = await Product.findById(productId);
        if (!product) {
            return res.status(404).json({
                status: "fail",
                message: "Product not found"
            });
        }

        const totalRatings = product.rating * product.broughtBy.length;
        const newTotalRatings = totalRatings + rating;
        const newAverageRating = 
            product.broughtBy.length === 0
                ? rating
                : newTotalRatings / (product.broughtBy.length + 1);

        const updatedProductRate = await Product.findByIdAndUpdate(
            productId,
            {
                $set: { rating: newAverageRating },
                $push: { broughtBy: id }
            },
            { new: true, runValidators: true }
        );

        res.status(200).json({
            status: "success",
            message: "Rating updated successfully",
            updatedProduct: updatedProductRate,
        });
    } catch (err) {
        res.status(500).json({
            status: "fail",
            message: "An error occurred while updating the rating",
            error: err.message,
        });
    }
};

