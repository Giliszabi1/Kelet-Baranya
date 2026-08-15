const transporter = require('../../infrastructure/mail/smtp.mail');
const smtpConfig = require('../../config/smtp.config');

const registerTemplate = require('./email-templates/registration.success');

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
}
module.exports = new EmailService();

