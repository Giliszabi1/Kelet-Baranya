const apiUrl = require('../../../shared/constants/apiUrl');

function verifyEmailTemplate({ fullname, username, email, token }) {
    return `
<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Organizer fiók – e-mail megerősítés</title>

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
            padding: 32px 30px;
            text-align: center;
        }

        .header-badge {
            display: inline-block;
            margin-bottom: 14px;
            padding: 6px 12px;
            border-radius: 20px;
            background-color: rgba(255,255,255,0.18);
            color: #ffffff;
            font-size: 12px;
            font-weight: bold;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .header h1 {
            margin: 0;
            color: #ffffff;
            font-size: 25px;
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

        .action-box {
            margin: 28px 0;
            padding: 22px;
            background-color: #f8fafc;
            border-radius: 8px;
            text-align: center;
        }

        .action-title {
            margin-bottom: 8px;
            color: #1e293b;
            font-size: 16px;
            font-weight: 600;
        }

        .action-text {
            margin: 0;
            color: #64748b;
            font-size: 13px;
            line-height: 1.6;
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
            padding: 8px 0 20px;
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
                padding: 28px 20px;
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

                        <div class="header-badge">
                            Organizer
                        </div>

                        <h1>
                            Erősítsd meg az e-mail címed
                        </h1>

                        <p>
                            Új megerősítő linket kértél a fiókodhoz
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
                            Új e-mail-megerősítő linket kértél a
                            <strong>Kelet-baranya Organizer fiókodhoz</strong>.
                        </p>

                        <p class="text">
                            Az alábbi gombbal megerősítheted az e-mail címedet.
                            A megerősítés után használhatod a szervezői fiókodhoz
                            tartozó funkciókat.
                        </p>

                        <!-- ACTION -->
                        <div class="action-box">

                            <div class="action-title">
                                Organizer fiók megerősítése
                            </div>

                            <p class="action-text">
                                A megerősítés szükséges ahhoz, hogy a szervezői
                                fiókodhoz kapcsolódó funkciókat használhasd.
                            </p>

                        </div>

                        <!-- EMAIL -->
                        <div class="email-box">

                            <div class="email-label">
                                Megerősítendő e-mail cím
                            </div>

                            <div class="email-value">
                                ${email}
                            </div>

                        </div>

                        <!-- BUTTON -->
                        <div class="button-wrapper">

                            <a
                                href="${apiUrl}/auth/organizer/confirm-email?token=${token}"
                                class="button"
                                target="_blank"
                            >
                                E-mail cím megerősítése
                            </a>

                        </div>

                        <p class="text">
                            A gombra kattintva megnyílik a megerősítő oldal,
                            ahol ellenőrizzük a regisztrációdhoz tartozó
                            e-mail címet.
                        </p>

                        <hr class="divider">

                        <!-- FALLBACK -->
                        <div class="notice">

                            <strong>
                                Nem tudod megnyitni a gombot?
                            </strong>

                            <br><br>

                            Másold be az alábbi címet a böngésződ címsorába:

                            <br><br>

                            <a
                                href="${apiUrl}/auth/organizer/confirm-email?token=${token}"
                                class="link"
                                target="_blank"
                            >
                                ${apiUrl}/auth/organizer/confirm-email?token=${token}
                            </a>

                        </div>

                        <!-- SECURITY -->
                        <p class="security">
                            <strong>Biztonság:</strong><br>

                            Ha nem te kérted az e-mail cím megerősítését,
                            nincs szükséged semmilyen teendőre.
                            Az üzenetet egyszerűen figyelmen kívül hagyhatod.
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

                        <p
                            class="footer-text"
                            style="margin-top: 15px;"
                        >
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