const apiUrl = require('../../../shared/constants/apiUrl');

function registerTemplate({username, email, token}) {
    return (`
        <!DOCTYPE html>
        <html lang="hu">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body, table, td, a {
                    -webkit-text-size-adjust: 100%;
                    -ms-text-size-adjust: 100%;
                }
                table, td {
                    mso-table-lspace: 0pt;
                    mso-table-rspace: 0pt;
                }
                img {
                    -ms-interpolation-mode: bicubic;
                    border: 0;
                    height: auto;
                    line-height: 100%;
                    outline: none;
                    text-decoration: none;
                }
                body {
                    margin: 0 !important;
                    padding: 0 !important;
                    width: 100% !important;
                    background-color: #f4f6f9;
                    font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
                    color: #333333;
                }
                .wrapper {
                    width: 100%;
                    table-layout: fixed;
                    background-color: #f4f6f9;
                    padding-top: 40px;
                    padding-bottom: 40px;
                }
                .main-card {
                    background-color: #ffffff;
                    margin: 0 auto;
                    width: 100%;
                    max-width: 600px;
                    border-radius: 12px;
                    overflow: hidden;
                    box-shadow: 0 4px 15px rgba(0,0,0,0.05);
                }
                .header {
                    background: linear-gradient(135deg, #3ea702 0%, #2d8c00 100%);
                    padding: 36px 30px;
                    text-align: center;
                }
                .header h1 {
                    color: #ffffff;
                    margin: 0;
                    font-size: 26px;
                    font-weight: 700;
                    letter-spacing: -0.5px;
                }
                .header p {
                    color: #dbeafe;
                    margin: 8px 0 0 0;
                    font-size: 15px;
                }
                .content {
                    padding: 40px 35px;
                }
                .greeting {
                    font-size: 20px;
                    font-weight: 600;
                    color: #1e293b;
                    margin-bottom: 16px;
                }
                .text-p {
                    font-size: 15px;
                    line-height: 1.6;
                    color: #475569;
                    margin-top: 0;
                    margin-bottom: 20px;
                }
                .info-box {
                    background-color: #f8fafc;
                    border-left: 4px solid #3ea702;
                    border-radius: 4px;
                    padding: 16px 20px;
                    margin: 25px 0;
                }
                .info-box-title {
                    font-size: 13px;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                    color: #64748b;
                    font-weight: 600;
                    margin-bottom: 4px;
                }
                .info-box-value {
                    font-size: 16px;
                    color: #0f172a;
                    font-weight: 600;
                    word-break: break-all;
                }
                .btn-container {
                    text-align: center;
                    margin: 35px 0;
                }
                .btn {
                    display: inline-block;
                    background-color: #3ea702;
                    color: #ffffff !important;
                    text-decoration: none;
                    padding: 14px 32px;
                    border-radius: 8px;
                    font-weight: 600;
                    font-size: 16px;
                    text-align: center;
                    box-shadow: 0 4px 6px -1px rgba(37, 99, 235, 0.2);
                }
                .steps-title {
                    font-size: 16px;
                    font-weight: 600;
                    color: #1e293b;
                    margin-top: 30px;
                    margin-bottom: 12px;
                }
                .step-item {
                    display: table;
                    width: 100%;
                    margin-bottom: 12px;
                }
                .step-number {
                    display: table-cell;
                    width: 28px;
                    height: 28px;
                    background-color: #eff6ff;
                    color: #3ea702;
                    font-weight: 700;
                    border-radius: 50%;
                    text-align: center;
                    vertical-align: middle;
                    font-size: 14px;
                }
                .step-text {
                    display: table-cell;
                    padding-left: 14px;
                    vertical-align: middle;
                    font-size: 14px;
                    color: #475569;
                }
                .divider {
                    border: 0;
                    border-top: 1px solid #e2e8f0;
                    margin: 30px 0;
                }
                /* Footer */
                .footer {
                    background-color: #f8fafc;
                    padding: 25px 30px;
                    text-align: center;
                    border-top: 1px solid #f1f5f9;
                }
                .footer-text {
                    font-size: 13px;
                    color: #94a3b8;
                    line-height: 1.5;
                    margin: 0 0 10px 0;
                }
                .footer-links a {
                    color: #64748b;
                    text-decoration: underline;
                    font-size: 12px;
                    margin: 0 8px;
                }
            </style>
        </head>
        <body>
            <table role="presentation" class="wrapper" cellspacing="0" cellpadding="0" border="0" width="100%">
                <tr>
                    <td align="center">
                        <table role="presentation" class="main-card" cellspacing="0" cellpadding="0" border="0" width="100%">
                            <!-- Fejléc -->
                            <tr>
                                <td class="header">
                                    <h1>Üdvözlünk a fedélzeten!</h1>
                                    <p>Köszönjük, hogy csatlakoztál hozzánk</p>
                                </td>
                            </tr>
                            <tr>
                                <td class="content">
                                    <div class="greeting">Szia ${username}!</div>
                                    <p class="text-p">
                                        Sikeresen regisztráltál a <strong>Kelet-baranya</strong> rendszerébe! Örömmel köszöntünk a közösségünkben.
                                    </p>
                                    <p class="text-p">
                                        A fiókod aktiválásához és a szolgáltatásaink használatához már csak egyetlen lépés van hátra: kérjük, erősítsd meg az e-mail címedet az alábbi gombra kattintva.
                                    </p>
                                    <div class="btn-container">
                                        <a href="${apiUrl}/auth/user/confirm-email?token=${token}" class="btn" target="_blank">E-mail cím megerősítése</a>
                                    </div>
                                    <div class="info-box">
                                        <div class="info-box-title">Regisztrált e-mail cím</div>
                                        <div class="info-box-value">${email}</div>
                                    </div>
                                    <div class="steps-title">Mi vár rád a megerősítés után?</div>
                                    <div class="step-item">
                                        <div class="step-number">1</div>
                                        <div class="step-text">Töltsd ki a profilodat a személyre szabott élményért.</div>
                                    </div>
                                    <div class="step-item">
                                        <div class="step-number">2</div>
                                        <div class="step-text">Böngéssz a legújabb funkcióink és ajánlataink között.</div>
                                    </div>
                                    <div class="step-item">
                                        <div class="step-number">3</div>
                                        <div class="step-text">Lépj kapcsolatba az ügyfélszolgálatunkkal, ha kérdésed van.</div>
                                    </div>
                                    <hr class="divider">
                                    <p class="text-p" style="font-size: 13px; color: #64748b; margin-bottom: 0;">
                                        Ha a fenti gomb nem működik, másold be az alábbi hivatkozást a böngésződbe:<br>
                                        <a href="${apiUrl}/auth/user/confirm-email?token=${token}" style="color: #6eeb25; word-break: break-all;">${apiUrl}/auth/user/confirm-email?token=${token}</a>
                                    </p>
                                </td>
                            </tr>
                            <tr>
                                <td class="footer">
                                    <p class="footer-text">
                                        Ha nem te regisztráltál erre a fiókra, kérjük, hagyd figyelmen kívül ezt az üzenetet.
                                    </p>
                                    <div class="footer-links">
                                        <a href="https://example.com/privacy">Adatvédelmi tájékoztató</a> •
                                        <a href="https://example.com/support">Ügyfélszolgálat</a> •
                                        <a href="https://example.com/terms">ÁSZF</a>
                                    </div>
                                    <p class="footer-text" style="margin-top: 15px; font-size: 11px;">
                                        © 2026 Kelet-baranya. Minden jog fenntartva.<br>
                                    </p>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </body>
        </html>
    `)
}
module.exports = registerTemplate;