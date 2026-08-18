import { describe, expect, test } from "vitest";

import validate from '../../../../src/shared/utils/validation';

import emailValidation from '../../../../src/shared/validation/email.validation';

describe("EMAIL", () => {
    describe("NORMAL", () => {

        test("EMAIL: giliszabi1@gmail.com", () => {
            expect(emailValidation.validate("giliszabi1@gmail.com").error).toBeUndefined();
        });

        test("EMAIL: szabigameplay1@gmail.com", () => {
            expect(emailValidation.validate("szabigameplay1@gmail.com").error).toBeUndefined();
        });

        test("EMAIL: gilikat@freemail.hu", () => {
            expect(emailValidation.validate("gilikat@freemail.hu").error).toBeUndefined();
        });

        test("EMAIL: gilikter.szabolcs@gmail.com", () => {
            expect(emailValidation.validate("gilikter.szabolcs@gmail.com").error).toBeUndefined();
        });

        test("EMAIL: test@freemail.au", () => {
            expect(emailValidation.validate("test@freemail.au").error).toBeUndefined();
        });

    });

    describe("BOUNDARY", () => {

        test("EMAIL: a@b.co", () => {
            expect(emailValidation.validate("a@b.co").error).toBeUndefined();
        });

        test("EMAIL: test@mail.example.com", () => {
            expect(emailValidation.validate("test@mail.example.com").error).toBeUndefined();
        });

        test("EMAIL: abcdefghijklmnopqrstuvwxyz@example.com", () => {
            expect(emailValidation.validate("abcdefghijklmnopqrstuvwxyz@example.com").error).toBeUndefined();
        });

        test("EMAIL: test@abcdefghijklmnopqrstuvwxyz.com", () => {
            expect(emailValidation.validate("test@abcdefghijklmnopqrstuvwxyz.com").error).toBeUndefined();
        });

        test("EMAIL: test.user+123@example.com", () => {expect(emailValidation.validate("test.user+123@example.com").error).toBeUndefined();});

    });

    describe("INVALID", () => {

        test("EMAIL: empty", () => {
            expect(emailValidation.validate("").error.details[0].message).toBe("EMAIL_REQUIRED");
        });

        test("EMAIL: testexample.com", () => {
            expect(emailValidation.validate("testexample.com").error.details[0].message).toBe("EMAIL_INVALID");
        });

        test("EMAIL: test@", () => {
            expect(emailValidation.validate("test@").error.details[0].message).toBe("EMAIL_INVALID");
        });

        test("EMAIL: @example.com", () => {
            expect(emailValidation.validate("@example.com").error.details[0].message).toBe("EMAIL_INVALID");
        });

    });
})