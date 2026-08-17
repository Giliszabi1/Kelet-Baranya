import { describe, expect, test } from "vitest";

import validate from '../../../../src/shared/utils/validation';

import fullnameValidation from '../../../../src/shared/validation/fullname.validation';

import { describe, expect, test } from "vitest";

import fullnameValidation from "../../../../src/shared/validation/fullname.validation";

describe("FULLNAME", () => {

    test("NORMAL", () => {
        expect(fullnameValidation.validate("John Doe").error).toBeUndefined();
        expect(fullnameValidation.validate("John Smith").error).toBeUndefined();
        expect(fullnameValidation.validate("Szabó Szabolcs").error).toBeUndefined();
        expect(fullnameValidation.validate("Nagy Péter").error).toBeUndefined();
        expect(fullnameValidation.validate("Árvíztűrő Tükörfúrógép").error).toBeUndefined();
    });

    test("BOUNDARY", () => {
        expect(fullnameValidation.validate("A Bcd").error).toBeUndefined();
        expect(fullnameValidation.validate("Aaaaaaaa Bbbbbbbb Cccccccc Dddddddd Eeeeeeee Ffffffff").error).toBeUndefined();
        expect(fullnameValidation.validate("John Michael Smith").error).toBeUndefined();
        expect(fullnameValidation.validate("John   Smith").error).toBeUndefined();
    });

    test("INVALID", () => {
        expect(fullnameValidation.validate("A B").error.details[0].message).toBe("FULLNAME_TOO_SHORT");
        expect(fullnameValidation.validate("Tom "+ "A".repeat(62)).error.details[0].message).toBe("FULLNAME_TOO_LONG");
        expect(fullnameValidation.validate("Szabolcs").error.details[0].message).toBe("FULLNAME_INVALID");
        expect(fullnameValidation.validate("John123 Smith").error.details[0].message).toBe("FULLNAME_INVALID");
        expect(fullnameValidation.validate("John_Smith").error.details[0].message).toBe("FULLNAME_INVALID");
        expect(fullnameValidation.validate("John-Smith").error.details[0].message).toBe("FULLNAME_INVALID");
        expect(fullnameValidation.validate("").error.details[0].message).toBe("FULLNAME_REQUIRED");
    });

});