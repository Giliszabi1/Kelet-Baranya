const apiUrl = require('../../../shared/constants/apiUrl');

function verifyEmailTemplate({ username, email, token }) {
    return `
<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-mail cím megerősítése</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            width: 100%;
            background-color: #f4f6f9;
            font-family: Arial, Helvetica, sans-serif;
            color: #333333;
        }

        table {
            border-spacing: 0;
            border-collapse: collapse;
        }

        .wrapper {
            width: 100%;
            background-color: #f4f6f9;
            padding: 40px 15px;
        }

        .container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 12px;
            overflow: hidden;
        }

        .header {
            background-color: #3ea702;
            padding: 36px 30px;
            text-align: center;
        }

        .header h1 {
            margin: 0;
            color: #ffffff;
            font-size: 26px;
            line-height: 1.3;
        }

        .header p {
            margin: 10px 0 0;
            color: #e8f5df;
            font-size: 15px;
            line-height: 1.5;
        }

        .content {
            padding: 40px 35px;
        }

        .greeting {
            margin: 0 0 20px;
            color: #1e293b;
            font-size: 20px;
            font-weight: 600;
        }

        .text {
            margin: 0 0 18px;
            color: #475569;
            font-size: 15px;
            line-height: 1.7;
        }

        .email-box {
            margin: 25px 0;
            padding: 18px 20px;
            background-color: #f8fafc;
            border-left: 4px solid #3ea702;
            border-radius: 5px;
        }

        .email-label {
            margin-bottom: 6px;
            color: #64748b;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .email-value {
            color: #0f172a;
            font-size: 15px;
            font-weight: 600;
            word-break: break-all;
        }

        .button-wrapper {
            text-align: center;
            padding: 10px 0 20px;
        }

        .button {
            display: inline-block;
            padding: 14px 30px;
            background-color: #3ea702;
            border-radius: 8px;
            color: #ffffff !important;
            font-size: 16px;
            font-weight: bold;
            text-decoration: none;
        }

        .notice {
            margin: 25px 0;
            padding: 16px 18px;
            background-color: #f8fafc;
            border-radius: 6px;
            color: #64748b;
            font-size: 13px;
            line-height: 1.6;
        }

        .link {
            color: #3ea702;
            word-break: break-all;
        }

        .divider {
            margin: 30px 0;
            border: 0;
            border-top: 1px solid #e2e8f0;
        }

        .security {
            color: #64748b;
            font-size: 13px;
            line-height: 1.6;
        }

        .footer {
            padding: 25px 30px;
            background-color: #f8fafc;
            border-top: 1px solid #f1f5f9;
            text-align: center;
        }

        .footer-text {
            margin: 0 0 10px;
            color: #94a3b8;
            font-size: 12px;
            line-height: 1.5;
        }

        .footer-links {
            margin-top: 12px;
        }

        .footer-links a {
            color: #64748b;
            font-size: 12px;
            text-decoration: underline;
        }

        @media only screen and (max-width: 600px) {
            .wrapper {
                padding: 20px 10px;
            }

            .content {
                padding: 30px 20px;
            }

            .header {
                padding: 30px 20px;
            }

            .header h1 {
                font-size: 23px;
            }

            .button {
                display: block;
                padding: 14px 20px;
            }
        }
    </style>
</head>
<body>
    <table
        role="presentation"
        width="100%"
        cellpadding="0"
        cellspacing="0"
        border="0"
        class="wrapper"
    >
        <tr>
            <td align="center">
                <table
                    role="presentation"
                    width="100%"
                    cellpadding="0"
                    cellspacing="0"
                    border="0"
                    class="container"
                >
                    <!-- HEADER -->
                    <tr>
                        <td class="header">
                            <h1>
                                E-mail cím megerősítése
                            </h1>
                            <p>
                                Új megerősítő linket kértél
                            </p>
                        </td>
                    </tr>
                    <!-- CONTENT -->
                    <tr>
                        <td class="content">

                            <p class="greeting">
                                Szia ${username}!
                            </p>

                            <p class="text">
                                Új megerősítő linket kértél a
                                <strong>Kelet-baranya</strong> fiókodhoz.
                            </p>

                            <p class="text">
                                Ha az előző regisztrációs e-mail nem érkezett meg,
                                semmi gond. Az alábbi gombra kattintva újra
                                megerősítheted az e-mail címedet.
                            </p>

                            <!-- EMAIL ADDRESS -->
                            <div class="email-box">

                                <div class="email-label">
                                    E-mail cím
                                </div>

                                <div class="email-value">
                                    ${email}
                                </div>

                            </div>

                            <!-- BUTTON -->
                            <div class="button-wrapper">

                                <a
                                    href="${apiUrl}/auth/user/confirm-email?token=${token}"
                                    class="button"
                                    target="_blank"
                                >
                                    E-mail cím megerősítése
                                </a>

                            </div>

                            <p class="text">
                                A gombra kattintva megnyílik a megerősítő oldal,
                                ahol automatikusan ellenőrizzük a regisztrációdhoz
                                tartozó e-mail címet.
                            </p>

                            <hr class="divider">

                            <!-- FALLBACK LINK -->
                            <div class="notice">

                                <strong>
                                    Nem működik a gomb?
                                </strong>

                                <br><br>

                                Másold be az alábbi linket a böngésződ címsorába:

                                <br><br>

                                <a
                                    href="${apiUrl}/auth/user/confirm-email?token=${token}"
                                    class="link"
                                    target="_blank"
                                >
                                    "${apiUrl}/auth/user/confirm-email?token=${token}"
                                </a>

                            </div>

                            <!-- SECURITY -->
                            <p class="security">
                                <strong>Biztonsági információ:</strong><br>
                                Ha nem te kérted ezt az e-mailt, nincs szükséged
                                semmilyen teendőre. Egyszerűen hagyd figyelmen kívül
                                ezt az üzenetet.
                            </p>

                        </td>
                    </tr>

                    <!-- FOOTER -->
                    <tr>
                        <td class="footer">
                            <p class="footer-text">
                                Ez egy automatikusan generált üzenet.
                                Kérjük, ne válaszolj erre az e-mailre.
                            </p>
                            <div class="footer-links">
                                <a href="https://example.com/privacy">
                                    Adatvédelmi tájékoztató
                                </a>

                                &nbsp;•&nbsp;

                                <a href="https://example.com/support">
                                    Ügyfélszolgálat
                                </a>

                                &nbsp;•&nbsp;

                                <a href="https://example.com/terms">
                                    ÁSZF
                                </a>
                            </div>

                            <p class="footer-text" style="margin-top: 15px;">
                                © 2026 Kelet-baranya. Minden jog fenntartva.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
    `;
}

module.exports = verifyEmailTemplate;