function twoFactorCodeTemplate({ username, email, code }) {
    return `
    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px; border: 1px solid #eaeaea; border-radius: 8px;">
        <h2 style="color: #222;">Bejelentkezési hitelesítő kód</h2>
        <p>Szia ${username || ""}!</p>
        <p>A bejelentkezésed véglegesítéséhez add meg az alábbi kódot az oldalon:</p>
        <p style="font-size: 32px; font-weight: bold; letter-spacing: 6px; text-align: center; margin: 24px 0;">
            ${code}
        </p>
        <p>A kód <strong>10 percig</strong> érvényes.</p>
        <p>Ha nem te próbáltál bejelentkezni, hagyd figyelmen kívül ezt az emailt, és javasoljuk, hogy változtasd meg a jelszavad.</p>
    </div>
    `;
};

module.exports = twoFactorCodeTemplate;