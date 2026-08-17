const config = require("../../config/smtp.config");
const nodemailer = require('nodemailer');

const SMTP_transporter = nodemailer.createTransport({
    host: config.SMTP_HOST,
    port: config.SMTP_PORT,
    secure: config.SMTP_SECURE,
    auth: {
        user: config.SMTP_USER,
        pass: config.SMTP_PASSWORD
    }
});

module.exports = SMTP_transporter;