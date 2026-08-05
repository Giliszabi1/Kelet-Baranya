const express = require('express');

const app = express()

app.use("/", (req, res)=>{
    res.send("<h1>heéép</h1>")
})

module.exports = app;