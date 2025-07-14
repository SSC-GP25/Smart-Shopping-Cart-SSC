const nodemailer = require("nodemailer");

// Create a transporter
const transporter = nodemailer.createTransport({
  service: "Gmail", // Use Gmail SMTP
  auth: {
    user: process.env.EMAIL_USER, // Your Gmail address
    pass: process.env.EMAIL_PASS, // Your Gmail App Password (not regular password)
  },
});

// Sender details
const sender = {
  name: "Smart Shopping Cart",
  address: process.env.EMAIL_USER,
};

module.exports = { transporter, sender };