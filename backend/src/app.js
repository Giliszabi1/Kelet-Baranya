const express = require('express');
const cors = require('cors');

const config = require("./config/app.config");


const app = express()

app.use(express.json());

const corsOption = config.corsOptions()
app.use(cors(corsOption));


app.use("/", (req, res)=>{
    res.send("<h1>heéép</h1>")
})

module.exports = app;