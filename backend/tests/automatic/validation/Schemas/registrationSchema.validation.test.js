import { describe, expect, test } from "vitest";

import {registrationSchema} from "../../../../src/modules/auth.user/auth.user.validation";

describe("registrationSchema", () => {
    test("NORMAL", () => { 
        expect(registrationSchema.validate({ 
            username: "Giliszabi", 
            email: "szabigameplay1@gmail.com", 
            password: "Szabigameplay1" 
        }).error ).toBeUndefined(); 

        expect(registrationSchema.validate({ 
            username: "ZsoltGamer005",
            email: "ZsoltGamer005@gmail.com",
            password: "ZsoltGamerPass005"
        }).error ).toBeUndefined();

        expect(registrationSchema.validate({
            username: "bubuŐ",
            email: "perovics.patrik@gmail.com",
            password: "Password123"
        }).error ).toBeUndefined();

        expect(registrationSchema.validate({
            username: "assasinKid", 
            email: "leventeMolnar@gmail.com", 
            password: "LeventeVok19" 
        }).error ).toBeUndefined(); 

        expect(registrationSchema.validate({ 
            username: "Kolbi0729", 
            email: "Werneralex12@gmail.com", 
            password: "Werneralex12" 
        }).error ).toBeUndefined();
    });

    test("USERNAME_PASSWORD_IDENTICAL", () => { 
        expect(registrationSchema.validate({ 
            username: "Giliszabi", 
            email: "szabigameplay1@gmail.com", 
            password: "Giliszabi" 
        }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");

        expect(registrationSchema.validate({ 
            username: "ZsoltGamer005",
            email: "ZsoltGamer005@gmail.com",
            password: "ZsoltGamer005"
        }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");

        expect(registrationSchema.validate({
            username: "assasinKid", 
            email: "leventeMolnar@gmail.com", 
            password: "assasinKid" 
        }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");

        expect(registrationSchema.validate({ 
            username: "Kolbi0729", 
            email: "Werneralex12@gmail.com", 
            password: "Kolbi0729" 
        }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");
    });

    test("USERNAME_REQUIRED", () => { 
        expect(registrationSchema.validate({ 
            username: "",
            email: "szabigameplay1@gmail.com", 
            password: "Giliszabi" 
        }).error.details[0].message).toBe("USERNAME_REQUIRED");

        expect(registrationSchema.validate({ 
            username: "",
            email: "ZsoltGamer005@gmail.com",
            password: "ZsoltGamer005"
        }).error.details[0].message).toBe("USERNAME_REQUIRED");

        expect(registrationSchema.validate({
            username: "", 
            email: "leventeMolnar@gmail.com", 
            password: "assasinKid" 
        }).error.details[0].message).toBe("USERNAME_REQUIRED");

        expect(registrationSchema.validate({ 
            username: "", 
            email: "Werneralex12@gmail.com", 
            password: "Kolbi0729" 
        }).error.details[0].message).toBe("USERNAME_REQUIRED");
    });

    describe("FULL_NAME", ()=>{
        test("NORMAL", () => { 
            expect(registrationSchema.validate({ 
                username: "Giliszabi", 
                email: "szabigameplay1@gmail.com", 
                password: "Szabigameplay1",
                fullname: "Gilikter Szabolcs"
            }).error ).toBeUndefined(); 

            expect(registrationSchema.validate({ 
                username: "ZsoltGamer005",
                email: "ZsoltGamer005@gmail.com",
                password: "ZsoltGamerPass005",
                fullname: "Benedek Zsolt"
            }).error ).toBeUndefined();

            expect(registrationSchema.validate({
                username: "bubuŐ",
                email: "perovics.patrik@gmail.com",
                password: "Password123",
                fullname: "Perovics Patrik"
            }).error ).toBeUndefined();

            expect(registrationSchema.validate({
                username: "assasinKid", 
                email: "leventeMolnar@gmail.com", 
                password: "LeventeVok19",
                fullname: "Molnár Levente Ákos"
            }).error ).toBeUndefined(); 

            expect(registrationSchema.validate({ 
                username: "Kolbi0729", 
                email: "Werneralex12@gmail.com", 
                password: "Werneralex12",
                fullname: "Werner Alex lászló"
            }).error ).toBeUndefined();
        });

        test("USERNAME_PASSWORD_IDENTICAL", () => { 
            expect(registrationSchema.validate({ 
                username: "Giliszabi", 
                email: "szabigameplay1@gmail.com", 
                password: "Giliszabi",
                fullname: "Gilikter Szabolcs"
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");

            expect(registrationSchema.validate({ 
                username: "ZsoltGamer005",
                email: "ZsoltGamer005@gmail.com",
                password: "ZsoltGamer005",
                fullname: "Benedek Zsolt"
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");

            expect(registrationSchema.validate({
                username: "assasinKid", 
                email: "leventeMolnar@gmail.com", 
                password: "assasinKid",
                fullname: "molnár levente ákos"
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");

            expect(registrationSchema.validate({ 
                username: "Kolbi0729", 
                email: "Werneralex12@gmail.com", 
                password: "Kolbi0729",
                fullname: "wERNER aLEX lÁSZLÓ kOLBI"
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");
        });

        test("USERNAME_REQUIRED", () => { 
            expect(registrationSchema.validate({ 
                username: "", 
                email: "szabigameplay1@gmail.com", 
                password: "Szabigameplay1",
                fullname: "Gilikter Szabolcs"
            }).error.details[0].message).toBe("USERNAME_REQUIRED");

            expect(registrationSchema.validate({ 
                username: "",
                email: "ZsoltGamer005@gmail.com",
                password: "ZsoltGamerPass005",
                fullname: "Benedek Zsolt"
            }).error.details[0].message).toBe("USERNAME_REQUIRED");

            expect(registrationSchema.validate({
                username: "",
                email: "perovics.patrik@gmail.com",
                password: "Password123",
                fullname: "Perovics Patrik"
            }).error.details[0].message).toBe("USERNAME_REQUIRED");

            expect(registrationSchema.validate({
                username: "", 
                email: "leventeMolnar@gmail.com", 
                password: "LeventeVok19",
                fullname: "Molnár Levente Ákos"
            }).error.details[0].message).toBe("USERNAME_REQUIRED"); 

            expect(registrationSchema.validate({ 
                username: "", 
                email: "Werneralex12@gmail.com", 
                password: "Werneralex12",
                fullname: "Werner Alex lászló"
            }).error.details[0].message).toBe("USERNAME_REQUIRED");
        });
    })
})