import { describe, expect, test } from "vitest";

import validate from '../../../../src/shared/utils/validation';

import emailValidation from '../../../../src/shared/validation/email.validation';

describe("EMAIL", () => {
    test("NORMAL", () => {
        expect(emailValidation.validate("giliszabi1@gmail.com").error).toBeUndefined();
        expect(emailValidation.validate("szabigameplay1@gmail.com").error).toBeUndefined();
        expect(emailValidation.validate("gilikat@freemail.hu").error).toBeUndefined();
        expect(emailValidation.validate("gilikter.szabolcs@gmail.com").error).toBeUndefined();
        expect(emailValidation.validate("test@freemail.au").error).toBeUndefined();
    });

    test("BOUNDARY", () => {
        expect(emailValidation.validate("a@b.co").error).toBeUndefined();
        expect(emailValidation.validate("test@mail.example.com").error).toBeUndefined();
        expect(emailValidation.validate("abcdefghijklmnopqrstuvwxyz@example.com").error).toBeUndefined();
        expect(emailValidation.validate("test@abcdefghijklmnopqrstuvwxyz.com").error).toBeUndefined();
        expect(emailValidation.validate("test.user+123@example.com").error).toBeUndefined();
    });
    
    test("INVALID", () => {
        expect(emailValidation.validate("").error.details[0].message).toBe("EMAIL_REQUIRED");
        expect(emailValidation.validate("testexample.com").error.details[0].message).toBe("EMAIL_INVALID");
        expect(emailValidation.validate("test@").error.details[0].message).toBe("EMAIL_INVALID");
        expect(emailValidation.validate("@example.com").error.details[0].message).toBe("EMAIL_INVALID");
    });
})