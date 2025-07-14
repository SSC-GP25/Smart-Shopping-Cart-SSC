const { transporter, sender } = require("./nodemailer.config");
const {
  VERIFICATION_EMAIL_TEMPLATE,
  PASSWORD_RESET_REQUEST_TEMPLATE,
  PASSWORD_RESET_SUCCESS_TEMPLATE,
} = require("../mailtrap/emailTemplates");

const sendVerificationEmail = async (email, verificationToken) => {
  try {
    const mailOptions = {
      from: `${sender.name} <${sender.address}>`,
      to: email,
      subject: "Verify your email address",
      html: VERIFICATION_EMAIL_TEMPLATE.replace("{verificationCode}", verificationToken),
    };

    await transporter.sendMail(mailOptions);
    console.log("Verification email sent successfully!");
  } catch (error) {
    console.error("Error in sendVerificationEmail:", error.message);
    throw error; // Re-throw for controller to handle
  }
};

const sendWelcomeEmail = async (email, username) => {
  try {
    const mailOptions = {
      from: `${sender.name} <${sender.address}>`,
      to: email,
      subject: "Welcome to Smart Shopping Cart!",
      html: `
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Welcome</title>
        </head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="background: linear-gradient(to right, rgb(76, 96, 175), rgb(43, 71, 137)); padding: 20px; text-align: center;">
            <h1 style="color: white; margin: 0;">Welcome to SSC</h1>
          </div>
          <div style="background-color: #f9f9f9; padding: 20px; border-radius: 0 0 5px 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
            <p>Hello ${username},</p>
            <p>Welcome to Smart Shopping Cart! We’re excited to have you on board.</p>
            <p>Best regards,<br>The SSC Team</p>
          </div>
        </body>
        </html>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log("Welcome email sent successfully!");
  } catch (error) {
    console.error("Error in sendWelcomeEmail:", error.message);
    throw error;
  }
};

const sendPasswordResetEmail = async (email, resetURL) => {
  try {
    const mailOptions = {
      from: `${sender.name} <${sender.address}>`,
      to: email,
      subject: "Password Reset Request",
      html: PASSWORD_RESET_REQUEST_TEMPLATE.replace("{resetURL}", resetURL),
    };

    await transporter.sendMail(mailOptions);
    console.log("Reset email sent successfully!");
  } catch (error) {
    console.error("Error in sendPasswordResetEmail:", error.message);
    throw error;
  }
};

const sendResetSuccessfulEmail = async (email) => {
  try {
    const mailOptions = {
      from: `${sender.name} <${sender.address}>`,
      to: email,
      subject: "Password Reset Successful!",
      html: PASSWORD_RESET_SUCCESS_TEMPLATE,
    };

    await transporter.sendMail(mailOptions);
    console.log("Reset successful email sent successfully!");
  } catch (error) {
    console.error("Error in sendResetSuccessfulEmail:", error.message);
    throw error;
  }
};

module.exports = {
  sendPasswordResetEmail,
  sendResetSuccessfulEmail,
  sendVerificationEmail,
  sendWelcomeEmail,
};