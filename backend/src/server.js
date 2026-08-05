const app = require("./app");

const config = require("./config/app.config");


app.listen(config.PORT, config.HOST, () => {
    console.log(`Server running on http://`+config.HOST+":"+config.PORT);
});