const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const config = require("./config/app.config");


const app = express()

app.use(express.json());

const corsOption = config.corsOptions()
app.use(cors(corsOption));

const globalLimit = config.globalRateLimitOption()
app.use(rateLimit(globalLimit))

app.use("/", (req, res)=>{
    res.send("<h1>heéép</h1>")
})

module.exports = app;