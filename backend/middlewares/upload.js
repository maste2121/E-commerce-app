const multer = require("multer");
const cloudinary = require("cloudinary").v2;
const { CloudinaryStorage } = require("multer-storage-cloudinary");

// 1. Configure Cloudinary with your Render Environment Variables
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// 2. Set up Cloudinary Storage instead of Disk Storage
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: "asrat_ecommerce", // The folder name inside your Cloudinary dashboard
    allowed_formats: ["jpg", "png", "jpeg"],
    transformation: [{ width: 500, height: 500, crop: "limit" }], // Optional: Resize images
  },
});

const upload = multer({ storage: storage });

module.exports = upload;
