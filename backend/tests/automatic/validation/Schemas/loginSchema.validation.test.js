import { describe, expect, test } from "vitest";

import {loginSchema} from "../../../../src/modules/auth.user/auth.user.validation";

describe("loginSchema", () => {
    describe("USERNAME", ()=>{
        test("NORMAL", () => {
            expect(loginSchema.validate({
                username: "Giliszabi",
                password: "Password123"
            }).error).toBeUndefined()

            expect(loginSchema.validate({
                username: "Zsoltgamer005",
                password: "ZsoltgamerPass005"
            }).error).toBeUndefined()

            expect(loginSchema.validate({
                username: "bubuŐ",
                password: "Password123"
            }).error).toBeUndefined();

            expect(loginSchema.validate({
                username: "assasinKid", 
                password: "LeventeVok19" 
            }).error).toBeUndefined(); 

            expect(loginSchema.validate({ 
                username: "Kolbi0729", 
                password: "Werneralex12" 
            }).error).toBeUndefined();
        })

        test("ONLY_USERNAME", () => {
            expect(loginSchema.validate({
                username: "Giliszabi",
                password: ""
            }).error.details[0].message).toBe("PASSWORD_REQUIRED")

            expect(loginSchema.validate({
                username: "Zsoltgamer005",
                password: ""
            }).error.details[0].message).toBe("PASSWORD_REQUIRED")

            expect(loginSchema.validate({
                username: "bubuŐ",
                password: ""
            }).error.details[0].message).toBe("PASSWORD_REQUIRED")

            expect(loginSchema.validate({
                username: "assasinKid",
                password: ""
            }).error.details[0].message).toBe("PASSWORD_REQUIRED")

            expect(loginSchema.validate({ 
                username: "Kolbi0729",
                password: ""
            }).error.details[0].message).toBe("PASSWORD_REQUIRED")
        })

        test("USERNAME_PASSWORD_IDENTICAL", () => {
            expect(loginSchema.validate({
                username: "Giliszabi1",
                password: "Giliszabi1"
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL")

            expect(loginSchema.validate({
                username: "Zsoltgamer005",
                password: "Zsoltgamer005"
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL")

            expect(loginSchema.validate({
                username: "PatrikGamer1",
                password: "PatrikGamer1"
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL")

            expect(loginSchema.validate({
                username: "assasinKid2009",
                password: "assasinKid2009"
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL")

            expect(loginSchema.validate({ 
                username: "Kolbi0729",
                password: "Kolbi0729"
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL")
        })
    })
    describe("EMAIL", ()=>{
        test("NORMAL", () => {
            expect(loginSchema.validate({
                email: "szabigameplay1@gmail.com",
                password: "Password123"
            }).error).toBeUndefined()

            expect(loginSchema.validate({
                email: "ZsoltGamer005@gmail.com",
                password: "ZsoltgamerPass005"
            }).error).toBeUndefined()

            expect(loginSchema.validate({
                email: "perovics.patrik@gmail.com",
                password: "Password123"
            }).error).toBeUndefined();

            expect(loginSchema.validate({
                email: "leventeMolnar@gmail.com",
                password: "LeventeVok19" 
            }).error).toBeUndefined(); 

            expect(loginSchema.validate({ 
                email: "Werneralex12@gmail.com", 
                password: "Werneralex12" 
            }).error).toBeUndefined();
        })

        test("ONLY_EMAIL", () => {
            expect(loginSchema.validate({
                email: "szabigameplay1@gmail.com",
                password: ""
            }).error.details[0].message).toBe("PASSWORD_REQUIRED")

            expect(loginSchema.validate({
                email: "ZsoltGamer005@gmail.com",
                password: ""
            }).error.details[0].message).toBe("PASSWORD_REQUIRED")

            expect(loginSchema.validate({
                email: "perovics.patrik@gmail.com",
                password: ""
            }).error.details[0].message).toBe("PASSWORD_REQUIRED")

            expect(loginSchema.validate({
                email: "leventeMolnar@gmail.com",
                password: ""
            }).error.details[0].message).toBe("PASSWORD_REQUIRED")

            expect(loginSchema.validate({ 
                email: "Werneralex12@gmail.com", 
                password: ""
            }).error.details[0].message).toBe("PASSWORD_REQUIRED")
        })
    })
    describe("USERNAME && EMAIL", ()=>{
        test("NORMAL", () => { 
            expect(loginSchema.validate({ 
                username: "Giliszabi", 
                email: "szabigameplay1@gmail.com", 
                password: "Szabigameplay1" 
            }).error ).toBeUndefined(); 

            expect(loginSchema.validate({ 
                username: "ZsoltGamer005",
                email: "ZsoltGamer005@gmail.com",
                password: "ZsoltGamerPass005"
            }).error ).toBeUndefined();

            expect(loginSchema.validate({
                username: "bubuŐ",
                email: "perovics.patrik@gmail.com",
                password: "Password123"
            }).error ).toBeUndefined();

            expect(loginSchema.validate({
                username: "assasinKid", 
                email: "leventeMolnar@gmail.com", 
                password: "LeventeVok19" 
            }).error ).toBeUndefined(); 

            expect(loginSchema.validate({ 
                username: "Kolbi0729", 
                email: "Werneralex12@gmail.com", 
                password: "Werneralex12" 
            }).error ).toBeUndefined();
        });

        test("USERNAME_PASSWORD_IDENTICAL", () => { 
            expect(loginSchema.validate({ 
                username: "Giliszabi", 
                email: "szabigameplay1@gmail.com", 
                password: "Giliszabi" 
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");

            expect(loginSchema.validate({ 
                username: "ZsoltGamer005",
                email: "ZsoltGamer005@gmail.com",
                password: "ZsoltGamer005"
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");

            expect(loginSchema.validate({
                username: "assasinKid", 
                email: "leventeMolnar@gmail.com", 
                password: "assasinKid" 
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");

            expect(loginSchema.validate({ 
                username: "Kolbi0729", 
                email: "Werneralex12@gmail.com", 
                password: "Kolbi0729" 
            }).error.details[0].message).toBe("USERNAME_PASSWORD_IDENTICAL");
        });

        test("PASSWORD_REQUIRED", () => { 
            expect(loginSchema.validate({ 
                username: "Giliszabi", 
                email: "szabigameplay1@gmail.com", 
                password: "" 
            }).error.details[0].message).toBe("PASSWORD_REQUIRED");
        
            expect(loginSchema.validate({ 
                username: "ZsoltGamer005",
                email: "ZsoltGamer005@gmail.com",
                password: ""
            }).error.details[0].message).toBe("PASSWORD_REQUIRED");
        
            expect(loginSchema.validate({
                username: "assasinKid", 
                email: "leventeMolnar@gmail.com", 
                password: "" 
            }).error.details[0].message).toBe("PASSWORD_REQUIRED");
        
            expect(loginSchema.validate({ 
                username: "Kolbi0729", 
                email: "Werneralex12@gmail.com", 
                password: "" 
            }).error.details[0].message).toBe("PASSWORD_REQUIRED");
        });
    })

        test("ONLY_PASSWORD", ()=>{
            expect(loginSchema.validate({ 
                username: "", 
                email: "", 
                password: "Szabigameplay1" 
            }).error.details[0].message).toBe("USERNAME_OR_EMAIL_REQUIRED");
        
            expect(loginSchema.validate({ 
                username: "",
                email: "",
                password: "Zsoltgamer005"
            }).error.details[0].message).toBe("USERNAME_OR_EMAIL_REQUIRED");
        
            expect(loginSchema.validate({
                username: "", 
                email: "", 
                password: "assasinKid1"
            }).error.details[0].message).toBe("USERNAME_OR_EMAIL_REQUIRED");
        
            expect(loginSchema.validate({ 
                username: "", 
                email: "", 
                password: "Kolbi0729"
            }).error.details[0].message).toBe("USERNAME_OR_EMAIL_REQUIRED");
        })
})