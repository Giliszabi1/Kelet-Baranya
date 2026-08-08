function validate(schema){
    return (req, res, next) => {

        const validationResult = schema.validate(req.body, {
            abortEarly: false
        });

        const errors = validationResult.error;

        if (errors) {
            return res.status(400).json({
                success: false,
                errors: errors.details.map((error) => error.message)
            });
        }

        next();
    };
}
module.exports = validate;
