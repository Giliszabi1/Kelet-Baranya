const bcrypt = require("bcrypt");

const HASH_ITERATIONS  = 10;
class Encryption {
    async hash(password) {
        return await bcrypt.hash(password, HASH_ITERATIONS);
    }

    async verify(password, hash) {
        return await bcrypt.compare(password, hash);
    }
}


module.exports = new Encryption();