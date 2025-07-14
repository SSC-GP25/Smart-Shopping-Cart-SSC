const multer = require('multer');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'media/');  
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + '-' + file.originalname);  
    }
});

const upload = multer({ 
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB file size limit (optional)
    fileFilter: function (req, file, cb) {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
        if (allowedTypes.includes(file.mimetype)) {
            cb(null, true);  
        } else {
            cb(new Error('Invalid file type. Only JPEG, PNG, or JPG are allowed.'));
        }
    }
});

module.exports = upload;
