const Category = require('../models/categoryModel');
const Product = require('../models/productModel');
const cloudinary = require('../utils/cloudinary');


exports.getAllCategories = async (req, res) => {
    try {
        const categories = await Category.find();
        const categoriesWithProductCount = await Promise.all(
        categories.map(async (category) => {
          const productCount = await Product.countDocuments({ category: category.title });
          return {
            ...category._doc, 
            productCount,
          };
        })
      );
  
      res.status(200).json({
        status: 'success',
        results: categoriesWithProductCount.length,
        data: {
          categories: categoriesWithProductCount,
        },
      });
    } catch (err) {
      res.status(404).json({
        status: 'fail',
        message: err.message,
        error: err,
      });
    }
  };

exports.getCategory = async ( req , res ) => {
    try {
        const category = await Category.findById(req.params.id);

        res.status(200).json({
            status:'success',
            data: {
                category
            }
        })

    } catch( err ){
        res.status(404).json({
            status: 'fail',
            message: "Couldn't the find category",
            error:err
        })
    }
};

// exports.getCategoryProducts = async ( req , res ) => {
//     const { title } = req.body ;
//     if (!title || typeof title !== 'string') {
//         return res.status(400).json({
//             status: 'fail',
//             message: 'Invalid category title'
//         });
//     }
//     try {
//         const products = await Product.find({category: title});
//         if (products.length === 0) {
//             return res.status(404).json({
//                 status: 'fail',
//                 message: 'No products found for this category'
//             });
//         }
//         res.status(200).json({
//             status:'success',
//             data: {
//                 products
//             }
//         })

//     } catch( err ){
//         res.status(404).json({
//             status: 'fail',
//             message: "Couldn't find the category products",
//             error:err
//         })
//     }
// };

exports.createCategory = async ( req , res ) => {
    try {

      
        console.log(req.body);
        const newCategroy = await Category.create(req.body);
        res.status(201).json({
            status:'success',
            message:'Category Created Successfully',
            data: {
                newCategroy
            }
        });

    } catch( err ){
        res.status(400).json({
            status: 'fail',
            message: "Couldn't create category",
            error:err
        })
    }
};


exports.updateCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, image } = req.body;

    console.log('🔍 Received Data:', req.body);
    const currentCategory = await Category.findById(id);
    if (!currentCategory) {
      return res.status(404).json({ status: 'fail', message: 'Category not found' });
    }
    const updates = {};

    if (image && image !== currentCategory.image) {
      console.log('📸 Image URL has changed...');
      try {
        if (currentCategory.image) {
            if(currentCategory.image == "https://img.icons8.com/fluent/200/instructure.png"){
              console.log('✅ Old image deleted (default image)')
            }else{
              const publicId = currentCategory.image.split('/category/')[1].split('.')[0];
              await cloudinary.uploader.destroy(`category/${publicId}`);
              console.log('✅ Old image deleted from Cloudinary');
            }

        } 

        updates.image = image;
      } catch (err) {
        console.error('⚠️ Error deleting old image from Cloudinary:', err);
        return res.status(500).json({ status: 'fail', message: 'Error deleting old image' });
      }
    }

    if (title && title !== currentCategory.title) updates.title = title;
    if (description && description !== currentCategory.description) updates.description = description;

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ status: 'fail', message: 'No changes detected' });
    }

    const updatedCategory = await Category.findByIdAndUpdate(id, updates, { new: true, runValidators: true });

    console.log('✅ Updated Category:', updatedCategory);

    res.status(200).json({
      status: 'success',
      message: 'Category updated successfully',
      data: updatedCategory,
    });
  } catch (err) {
    console.error('❌ Error updating category:', err.message);
    res.status(500).json({ status: 'fail', message: "Couldn't update category", error: err.message });
  }
};


exports.deleteCategory = async (req, res) => {
  try {
    const deletedCategory = await Category.findByIdAndDelete(req.params.id);

    if (!deletedCategory) {
      return res.status(404).json({
        status: 'fail',
        message: 'Category not found',
      });
    }

    if (deletedCategory.image) {
      if(deletedCategory.image == "https://img.icons8.com/fluent/200/instructure.png"){
        console.log('✅ Old image deleted (default image)')
      }
      else{
        const publicId = deletedCategory.image.split('/category/')[1].split('.')[0]; 
      try {
        await cloudinary.uploader.destroy(`category/${publicId}`);
        console.log('✅ Image deleted from Cloudinary');
      } catch (err) {
        console.error('Error deleting image from Cloudinary:', err);
      }
      }
      
    }

    const deletedProducts = await Product.deleteMany({
      category: deletedCategory.title,
    });

    res.status(200).json({
      status: 'success',
      message: 'Category and related products deleted successfully',
      data: {
        deletedCategory,
        deletedProductsCount: deletedProducts.deletedCount,
      },
    });
  } catch (err) {
    res.status(500).json({
      status: 'fail',
      message: "Couldn't delete category",
      error: err.message,
    });
  }
};




// exports.deleteAllCategories = async (req, res) => {
//         try {
//             const ids = req.body.ids;
//             const deletedCategories = await Category.deleteMany({
//                 _id: { $in: ids },
//             });
    
//             const deletedProducts = await Product.deleteMany({
//                 category: { $in: ids },
//             });
    
//             res.status(200).json({
//                 status: 'success',
//                 message: 'Categories and related products deleted successfully',
//                 deletedCount: {
//                     categories: deletedCategories.deletedCount,
//                     products: deletedProducts.deletedCount,
//                 },
//             });
//         } catch (err) {
//             res.status(500).json({
//                 status: 'fail',
//                 message: err.message,
//             });
//         }
//     };
    