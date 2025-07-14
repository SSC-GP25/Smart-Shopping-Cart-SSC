const cloudinary = require('../../utils/cloudinary');

exports.deleteItem = async function(items){
    for (const item of items) {
        const image = item.image;
  
        if (image) {
          const publicId = image.split('/product/').slice(-1)[0].split('.')[0];
  
          await cloudinary.uploader.destroy(publicId);
        }
      }
}
