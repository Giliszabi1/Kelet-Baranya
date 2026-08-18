import { describe, expect, test } from "vitest";

import validate from '../../../../src/shared/utils/validation';

import fullnameValidation from '../../../../src/shared/validation/fullname.validation';

import { describe, expect, test } from "vitest";

import fullnameValidation from "../../../../src/shared/validation/fullname.validation";

describe("FULLNAME", () => {

    describe("NORMAL", () => {

        test("FULLNAME: John Doe", () => {
            expect(fullnameValidation.validate("John Doe").error).toBeUndefined();
        });

        test("FULLNAME: John Smith", () => {
            expect(fullnameValidation.validate("John Smith").error).toBeUndefined();
        });

        test("FULLNAME: Szabó Szabolcs", () => {
            expect(fullnameValidation.validate("Szabó Szabolcs").error).toBeUndefined();
        });

        test("FULLNAME: Nagy Péter", () => {
            expect(fullnameValidation.validate("Nagy Péter").error).toBeUndefined();
        });

        test("FULLNAME: Árvíztűrő Tükörfúrógép", () => {
            expect(fullnameValidation.validate("Árvíztűrő Tükörfúrógép").error).toBeUndefined();
        });

    });

    describe("BOUNDARY", () => {

        test("FULLNAME: A Bcd", () => {
            expect(fullnameValidation.validate("A Bcd").error).toBeUndefined();
        });

        test("FULLNAME: Aaaaaaaa Bbbbbbbb Cccccccc Dddddddd Eeeeeeee Ffffffff", () => {
            expect(
                fullnameValidation.validate("Aaaaaaaa Bbbbbbbb Cccccccc Dddddddd Eeeeeeee Ffffffff").error).toBeUndefined();
        });

        test("FULLNAME: John Michael Smith", () => {
            expect(fullnameValidation.validate("John Michael Smith").error).toBeUndefined();
        });

        test("FULLNAME: John   Smith", () => {
            expect(fullnameValidation.validate("John   Smith").error).toBeUndefined();
        });

    });

    describe("INVALID", () => {

        test("FULLNAME: A B", () => {
            expect(fullnameValidation.validate("A B").error.details[0].message).toBe("FULLNAME_TOO_SHORT");
        });

        test(`FULLNAME: ${"Tom " + "A".repeat(62)}`, () => {
            expect(fullnameValidation.validate("Tom " + "A".repeat(62)).error.details[0].message).toBe("FULLNAME_TOO_LONG");
        });

        test("FULLNAME: Szabolcs", () => {
            expect(fullnameValidation.validate("Szabolcs").error.details[0].message).toBe("FULLNAME_INVALID");
        });

        test("FULLNAME: John123 Smith", () => {
            expect(fullnameValidation.validate("John123 Smith").error.details[0].message).toBe("FULLNAME_INVALID");
        });

        test("FULLNAME: John_Smith", () => {
            expect(fullnameValidation.validate("John_Smith").error.details[0].message).toBe("FULLNAME_INVALID");
        });

        test("FULLNAME: John-Smith", () => {
            expect(fullnameValidation.validate("John-Smith").error.details[0].message).toBe("FULLNAME_INVALID");
        });

        test("FULLNAME: empty", () => {
            expect(fullnameValidation.validate("").error.details[0].message).toBe("FULLNAME_REQUIRED");
        });

    });

});