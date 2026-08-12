function validationTest(req, res, next) {
    res.send({
        success: true,
        data: req.body
    })
}
module.exports = validationTest;