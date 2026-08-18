import { describe, expect, test } from "vitest";

const token = require('../../../../src/shared/utils/token');

import tokenValidation from "../../../../src/shared/validation/token.validation";

const RANDOM_TEST_LENGTH = 100_000;
describe("TOKEN", () => {
    describe("NORMAL", () => {

        test("TOKEN: 73789fd1cc7b1679a1e2b3561db62854205c24df9f31f29fc4cb5da19f7e0ad269d813e959833e7c5fb9a2146fa70b9773eba6740ff9c50678cc63f1edf61994", () => {
            expect(tokenValidation.validate("73789fd1cc7b1679a1e2b3561db62854205c24df9f31f29fc4cb5da19f7e0ad269d813e959833e7c5fb9a2146fa70b9773eba6740ff9c50678cc63f1edf61994").error).toBeUndefined();
        });

        test("TOKEN: 1a23c76d742e6651635d68a2561853fd238e188a756d848881701c3fe892d3a05161414c25cd71ba057e564bea18d54e393a52f98edfe0da97550103ebfa34fd", () => {
            expect(tokenValidation.validate("1a23c76d742e6651635d68a2561853fd238e188a756d848881701c3fe892d3a05161414c25cd71ba057e564bea18d54e393a52f98edfe0da97550103ebfa34fd").error).toBeUndefined();
        });

        test("TOKEN: a1afbb1972d1da1715b2e80881fcb02644345d03cd09bb4b1411e1201c6e3dd7730b5f3cda9493425a4822d8b5eb2f7e420fef5586d68b1e5a5ce7b413ca1a7c", () => {
            expect(tokenValidation.validate("a1afbb1972d1da1715b2e80881fcb02644345d03cd09bb4b1411e1201c6e3dd7730b5f3cda9493425a4822d8b5eb2f7e420fef5586d68b1e5a5ce7b413ca1a7c").error).toBeUndefined();
        });

        test("TOKEN: a8fc1d9b0e239896c4d918ee7869924b408f982a42482229814e31c7677e7a6ab75e0cef909b8a032307ebacc32d235ff53bd634f4fadad6a66eb26a970bcf15", () => {
            expect(tokenValidation.validate("a8fc1d9b0e239896c4d918ee7869924b408f982a42482229814e31c7677e7a6ab75e0cef909b8a032307ebacc32d235ff53bd634f4fadad6a66eb26a970bcf15").error).toBeUndefined();
        });

        test("TOKEN: 539f49309ab98c979c8f44a3276593398e1d72f811748033a68af16c017e03e34045c17f8e33c9e1267ece92e6598c1dce1e5bac33cdff3ff73e52f055577965", () => {
            expect(tokenValidation.validate("539f49309ab98c979c8f44a3276593398e1d72f811748033a68af16c017e03e34045c17f8e33c9e1267ece92e6598c1dce1e5bac33cdff3ff73e52f055577965").error).toBeUndefined();
        });

        test("TOKEN: fdc359e5e01a3df1d25ada040e7a5d1e5424a3ec6e7c73a40fc18ce94b098160b6faa56a1078594987746da0015b5b8d1fb333eec0887877ee9dc6559e7aa565", () => {
            expect(tokenValidation.validate("fdc359e5e01a3df1d25ada040e7a5d1e5424a3ec6e7c73a40fc18ce94b098160b6faa56a1078594987746da0015b5b8d1fb333eec0887877ee9dc6559e7aa565").error).toBeUndefined();
        });

        test("TOKEN: 2f23447cf6484b6bd653cde0f775fa93b5a7c80a4af3907d2c17f997e528034b81a93b86ec8cba613060d9f035c72b3adc084adec4ef75d527bc997b22a8e916", () => {
            expect(tokenValidation.validate("2f23447cf6484b6bd653cde0f775fa93b5a7c80a4af3907d2c17f997e528034b81a93b86ec8cba613060d9f035c72b3adc084adec4ef75d527bc997b22a8e916").error).toBeUndefined();
        });

        test("TOKEN: 0e08d7e6c20060c2301e5d5c2b884abbb63bdeb93234cb3ef32924d1b490ce4ceca70bc37f736649f45e865eb6a888ff2475cc69d353bb2c999b91e6152568c8", () => {
            expect(tokenValidation.validate("0e08d7e6c20060c2301e5d5c2b884abbb63bdeb93234cb3ef32924d1b490ce4ceca70bc37f736649f45e865eb6a888ff2475cc69d353bb2c999b91e6152568c8").error).toBeUndefined();
        });

        test("TOKEN: ea1354e467e73f04a9857bb337a0939d4f003aac933289c00857e2e73e30b0302592ba1b68b64e1d39349464b37aa96b67ca0ca5c228f09841a286834afddcb9", () => {
            expect(tokenValidation.validate("ea1354e467e73f04a9857bb337a0939d4f003aac933289c00857e2e73e30b0302592ba1b68b64e1d39349464b37aa96b67ca0ca5c228f09841a286834afddcb9").error).toBeUndefined();
        });

        test("TOKEN: 2db064e7f0ea0dc4c106131ebb7d4fefb5a0f041cf97c014d012d1e919e21c9022f5dc8a02d2ab420beea5fe3d66c45f632e757877b8d7b6114b180e0b4d48b1", () => {
            expect(tokenValidation.validate("2db064e7f0ea0dc4c106131ebb7d4fefb5a0f041cf97c014d012d1e919e21c9022f5dc8a02d2ab420beea5fe3d66c45f632e757877b8d7b6114b180e0b4d48b1").error).toBeUndefined();
        });

        test("TOKEN: 3c2f213991910ff864bab882a7f1239a9b4b4ce199b25e214776948a06ddde62fb6e53867838f33a070025d573bdf5aa3c18159858f5052294c637ca022a74c8", () => {
            expect(tokenValidation.validate("3c2f213991910ff864bab882a7f1239a9b4b4ce199b25e214776948a06ddde62fb6e53867838f33a070025d573bdf5aa3c18159858f5052294c637ca022a74c8").error).toBeUndefined();
        });

        test("TOKEN: 4007532f5594380db3e33177575956ec80fd129726a074352acd6f6ab249e6e9115a99976209281c2600336b6e60707ef3d24cb75e135e9720b661fef4d7b92a", () => {
            expect(tokenValidation.validate("4007532f5594380db3e33177575956ec80fd129726a074352acd6f6ab249e6e9115a99976209281c2600336b6e60707ef3d24cb75e135e9720b661fef4d7b92a").error).toBeUndefined();
        });

        test("TOKEN: f3bef964698712fe7f8e22289fb0e06da9e62dec978c7d6dbf8475ffde99b99bf36df9118d762c3379ea14277666916eb11530952b7e5ec2f000359b83a16fcf", () => {
            expect(tokenValidation.validate("f3bef964698712fe7f8e22289fb0e06da9e62dec978c7d6dbf8475ffde99b99bf36df9118d762c3379ea14277666916eb11530952b7e5ec2f000359b83a16fcf").error).toBeUndefined();
        });

        test("TOKEN: 038e4e70c3dde6fa0cee52da85f4e7631019a052115cd92a2ea4321df7817fee7ddb6746e857c83dda185aa58ba6b9d7c2b44766c6e8a551fa8d43ffa9b6c523", () => {
            expect(tokenValidation.validate("038e4e70c3dde6fa0cee52da85f4e7631019a052115cd92a2ea4321df7817fee7ddb6746e857c83dda185aa58ba6b9d7c2b44766c6e8a551fa8d43ffa9b6c523").error).toBeUndefined();
        });

        test("TOKEN: ce7b7fb8ee6eb7a88df085fa0c53f5c7c89566dc1cbc96b619629f0232fe937f50c26689c9956ca9861a17dbba9ab1848ae1606d4f5c3515cdcdb2364bc5da2e", () => {
            expect(tokenValidation.validate("ce7b7fb8ee6eb7a88df085fa0c53f5c7c89566dc1cbc96b619629f0232fe937f50c26689c9956ca9861a17dbba9ab1848ae1606d4f5c3515cdcdb2364bc5da2e").error).toBeUndefined();
        });

        test("TOKEN: bc1477bdaa6b8b8e65920d3134c4c88dd5decd31b74a44684ee5cc977ddda100303c66929866f35dc9b85281580726331a2f761e907aedbfcf8ec019cf0b9124", () => {
            expect(tokenValidation.validate("bc1477bdaa6b8b8e65920d3134c4c88dd5decd31b74a44684ee5cc977ddda100303c66929866f35dc9b85281580726331a2f761e907aedbfcf8ec019cf0b9124").error).toBeUndefined();
        });

        test("TOKEN: ff41848ea6297747860de3b8a2579091e2451d08d426c9b43d82edfe9a8596a56b61b862891a0dcf3aa0aaefb50dea5c2f2f773c3ef9abef6e8fe37200c53262", () => {
            expect(tokenValidation.validate("ff41848ea6297747860de3b8a2579091e2451d08d426c9b43d82edfe9a8596a56b61b862891a0dcf3aa0aaefb50dea5c2f2f773c3ef9abef6e8fe37200c53262").error).toBeUndefined();
        });

        test("TOKEN: f74279d88122b91ddcf08251e9de18b2f39df50dfdc8a0008b45bccd89b3c2111b11e6bb8432a258619f407f4506f4164752af74977b2e3e36141a2d8b68ebf0", () => {
            expect(tokenValidation.validate("f74279d88122b91ddcf08251e9de18b2f39df50dfdc8a0008b45bccd89b3c2111b11e6bb8432a258619f407f4506f4164752af74977b2e3e36141a2d8b68ebf0").error).toBeUndefined();
        });

        test("TOKEN: 772cbc3b02ac911998df47fa2abb21cc611c7e0f3ce40e2ee03b110bc8ac93ebe2083b750e9ac7b9274f2dc348e5a04c3c92c6ca0e5b94c2e34a28e6428c4258", () => {
            expect(tokenValidation.validate("772cbc3b02ac911998df47fa2abb21cc611c7e0f3ce40e2ee03b110bc8ac93ebe2083b750e9ac7b9274f2dc348e5a04c3c92c6ca0e5b94c2e34a28e6428c4258").error).toBeUndefined();
        });

        test("TOKEN: 0ed9ad49f22e6a385a5400b056e3253bb5d34a02f8315169d1c2a2253e49a055a36db361c48ae45263642f77ecc59983829ab4c1fcf189997f4fe9496f54b450", () => {
            expect(tokenValidation.validate("0ed9ad49f22e6a385a5400b056e3253bb5d34a02f8315169d1c2a2253e49a055a36db361c48ae45263642f77ecc59983829ab4c1fcf189997f4fe9496f54b450").error).toBeUndefined();
        });

        test("TOKEN: 1d673a4f68979ff62cfab521db84ddc8e75e93f69db75836ddcc128eda9e1f1d89efd45614c9dea350ede954c8cbee044bae3513d2c858478b079e238d3909c3", () => {
            expect(tokenValidation.validate("1d673a4f68979ff62cfab521db84ddc8e75e93f69db75836ddcc128eda9e1f1d89efd45614c9dea350ede954c8cbee044bae3513d2c858478b079e238d3909c3").error).toBeUndefined();
        });

        test("TOKEN: 508de849b3e6f3a9a03532813b9f6e2c604de56a84f101df14377a11b6eda51858cace5a8abe2a0b435ce5069bbd4c56e916080b83e7f6ed95ee9b68b3f209ca", () => {
            expect(tokenValidation.validate("508de849b3e6f3a9a03532813b9f6e2c604de56a84f101df14377a11b6eda51858cace5a8abe2a0b435ce5069bbd4c56e916080b83e7f6ed95ee9b68b3f209ca").error).toBeUndefined();
        });

        test("TOKEN: 683231869fb1f822f11847d70116c3e30d888753c9d668a23cfa544999b6d12c548dd3500912fc9995634583af404529b99d59c6ce9bac89418723fba6bbc2d1", () => {
            expect(tokenValidation.validate("683231869fb1f822f11847d70116c3e30d888753c9d668a23cfa544999b6d12c548dd3500912fc9995634583af404529b99d59c6ce9bac89418723fba6bbc2d1").error).toBeUndefined();
        });

        test("TOKEN: 7716cf65f22cef090077822d8055d760f7509d178e70cff4c44a3bd08ff9874d539e1dc75726776b3a57b409e1c7c5a2df027609fdc2f4f6908b459ef0d96b63", () => {
            expect(tokenValidation.validate("7716cf65f22cef090077822d8055d760f7509d178e70cff4c44a3bd08ff9874d539e1dc75726776b3a57b409e1c7c5a2df027609fdc2f4f6908b459ef0d96b63").error).toBeUndefined();
        });

        test("TOKEN: 11957ffe2acc1cfe5fc6937e09ee6f7cdee9bf79888c4345868869b9e5f0545208fbe8e36545b634aff2d24507293dc6d57fad7a122010bb265b1419a9496250", () => {
            expect(tokenValidation.validate("11957ffe2acc1cfe5fc6937e09ee6f7cdee9bf79888c4345868869b9e5f0545208fbe8e36545b634aff2d24507293dc6d57fad7a122010bb265b1419a9496250").error).toBeUndefined();
        });

        test("TOKEN: 3b37ceee84fc8aa31828e1b2a628bc2f56636bc46f72cd64be2f9a1fb8246dfcdc5e6500eca8887e58471ee471538b8af46128d821c072bf2300e42dbb961c81", () => {
            expect(tokenValidation.validate("3b37ceee84fc8aa31828e1b2a628bc2f56636bc46f72cd64be2f9a1fb8246dfcdc5e6500eca8887e58471ee471538b8af46128d821c072bf2300e42dbb961c81").error).toBeUndefined();
        });

    });

    describe("INVALID", () => {

        test("TOKEN: too short", () => {
            expect(tokenValidation.validate("3b37ceee84fc8aa31828e1b2a628bc2f56636bc46f72cd64be2f9a1fb8246dfcdc5e6500eca8887e58471ee471538b8af46128d821c072bf2300e42dbb961c8").error.details[0].message).toBe("TOKEN_TOO_SHORT_OR_LONG");
        });

        test("TOKEN: too long", () => {
            expect(tokenValidation.validate("7cd02c5721e2bccf836720fbe9c83b1bef8aa146cd455fda97237869dec46461fcf494706c6b872379ebcaac7ef013877b6b4f50cda4183498c31cfab553f38").error.details[0].message).toBe("TOKEN_TOO_SHORT_OR_LONG");
        });

        test("TOKEN: MYTOKEN", () => {
            expect(tokenValidation.validate("MYTOKEN").error.details[0].message).toBe("TOKEN_TOO_SHORT_OR_LONG");
        });

    });

    test("RANDOM_TEST", () => {

        for (let i = 0; i < RANDOM_TEST_LENGTH; i++) {

            if (i % 2) {

                expect(
                    tokenValidation.validate(token.generate()).error
                ).toBeUndefined();

            } else {

                expect(
                    tokenValidation.validate(
                        token.generate().slice(
                            Math.random() * 64,
                            (Math.random() * 64) + 64
                        )
                    ).error.details[0].message
                ).toBe("TOKEN_TOO_SHORT_OR_LONG");

            }
        }

    });
})