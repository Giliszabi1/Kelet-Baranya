import { describe, expect, test } from "vitest";

import passwordValidation from "../../../../src/shared/validation/password.validation";

const RANDOM_TEST_LENGTH = 10_000;

const approvedChars = /^[A-Za-z0-9!@#$%^&*]+$/;

const chars = `
abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
0123456789
!@#$%^&*._-
~\\|&, \t\n\r,€£©®
`;

describe("PASSWORD", () => {

    describe("NORMAL", () => {

        test("PASSWORD: Password123", () => {
            expect(passwordValidation.validate("Password123").error).toBeUndefined();
        });

        test("PASSWORD: TestPassword1", () => {
            expect(passwordValidation.validate("TestPassword1").error).toBeUndefined();
        });

        test("PASSWORD: Password1!", () => {
            expect(passwordValidation.validate("Password1!").error).toBeUndefined();
        });

        test("PASSWORD: SecurePass123", () => {
            expect(passwordValidation.validate("SecurePass123").error).toBeUndefined();
        });

        test("PASSWORD: MyPassword123!", () => {
            expect(passwordValidation.validate("MyPassword123!").error).toBeUndefined();
        });

    });

    describe("BOUNDARY", () => {

        test("PASSWORD: Test1234", () => {
            expect(passwordValidation.validate("Test1234").error).toBeUndefined();
        });

        test(`PASSWORD: ${"aA1" + "b".repeat(5)}`, () => {
            expect(
                passwordValidation.validate("aA1" + "b".repeat(5)).error
            ).toBeUndefined();
        });

        test(`PASSWORD: ${"a".repeat(30) + "A1"}`, () => {
            expect(
                passwordValidation.validate("a".repeat(30) + "A1").error
            ).toBeUndefined();
        });

        test("PASSWORD: 1234567Aa", () => {
            expect(passwordValidation.validate("1234567Aa").error).toBeUndefined();
        });

        test("PASSWORD: Aa123456", () => {
            expect(passwordValidation.validate("Aa123456").error).toBeUndefined();
        });

    });

    describe("INVALID", () => {

        test(`PASSWORD: ${"a".repeat(7)}`, () => {
            expect(
                passwordValidation.validate("a".repeat(7)).error.details[0].message
            ).toBe("PASSWORD_TOO_SHORT");
        });

        test("PASSWORD: password123", () => {
            expect(
                passwordValidation.validate("password123").error.details[0].message
            ).toBe("PASSWORD_INVALID");
        });

        test("PASSWORD: PASSWORD123", () => {
            expect(
                passwordValidation.validate("PASSWORD123").error.details[0].message
            ).toBe("PASSWORD_INVALID");
        });

        test("PASSWORD: Password", () => {
            expect(
                passwordValidation.validate("Password").error.details[0].message
            ).toBe("PASSWORD_INVALID");
        });

        test("PASSWORD: Password123!", () => {
            expect(
                passwordValidation.validate("Password123!").error
            ).toBeUndefined();
        });

        test("PASSWORD: Password123_", () => {
            expect(
                passwordValidation.validate("Password123_").error.details[0].message
            ).toBe("PASSWORD_INVALID");
        });

        test("PASSWORD: Password 123", () => {
            expect(
                passwordValidation.validate("Password 123").error.details[0].message
            ).toBe("PASSWORD_INVALID");
        });

        test("PASSWORD: empty", () => {
            expect(
                passwordValidation.validate("").error.details[0].message
            ).toBe("PASSWORD_REQUIRED");
        });

    });


    test("RANDOM_TEST", () => {
        for (let i = 0; i < RANDOM_TEST_LENGTH; i++) {

            const passwordLength = Math.floor(Math.random() * 40);

            let password = "";
            let isContainInvalidChar = false;
            let isContainUppercase = false;
            let isContainLowercase = false;
            let isContainsNumber = false;
            for (let j = 0; j < passwordLength; j++) {

                const char = chars[Math.floor(Math.random() * chars.length)];

                password += char;

                if (!approvedChars.test(char)) {
                    isContainInvalidChar = true;
                }

                if (/[A-Z]/.test(char)) {
                    isContainUppercase = true;
                }

                if (/[a-z]/.test(char)) {
                    isContainLowercase = true;
                }

                if (/[0-9]/.test(char)) {
                    isContainsNumber = true;
                }
            }

            const isValidPassword = !isContainInvalidChar && isContainUppercase && isContainLowercase && isContainsNumber;

            if(passwordLength <= 64 && passwordLength >= 8 && isValidPassword){
                expect(passwordValidation.validate(password).error).toBeUndefined()
                //console.log("VALID: "+ password)
            }else{
                expect(passwordValidation.validate(password).error.details[0].message).not.toBeUndefined();
                //console.log("INVALID: "+ JSON.stringify(password))
            }
        }
    });

});