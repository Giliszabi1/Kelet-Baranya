const transporter = require('../../infrastructure/mail/smtp.mail');
const smtpConfig = require('../../config/smtp.config');

const registerTemplate = require('./email-templates/registration.success');
const verifyEmailTemplate = require('./email-templates/verify.email');

class EmailService {
    
    async register({username, email, token}) {
        try {
            await transporter.sendMail({
                from: smtpConfig.SMTP_USER,
                to: email,
                subject: "Sikeres regisztráció",
                //text: `Sikeresen regisztráltál a Kelet Baranya weboldalra. A regisztráció megerősítéséhez kattints a linkre: ${newRegistrationToken}`,
                html: registerTemplate({
                    username: username, 
                    email: email, 
                    token: token
                })
            });
        } catch (mailErr) {
            console.error("Nem sikerült elküldeni a jelszó-visszaállító emailt:", mailErr);
        }
    }

    async resendConfirmationEmail({username, email, token}) {
        try {
            await transporter.sendMail({
                from: smtpConfig.SMTP_USER,
                to: email,
                subject: "Email cím validálása",
                html: verifyEmailTemplate({
                    username: username, 
                    email: email, 
                    token: token
                })
            });
        } catch (mailErr) {
            console.error("Nem sikerült elküldeni a email validáló emailt:", mailErr);
        }
    }
}
module.exports = new EmailService();

