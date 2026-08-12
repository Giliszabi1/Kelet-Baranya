import { describe, expect, test } from "vitest";

import {
    registrationSchema,
    loginSchema,
    forgetPasswordSchema,
    resetPasswordSchema,
} from "../../src/modules/auth.user/auth.user.validation";


describe("registrationSchema", () => {
    describe("username", () => {
        test("NORMAL_USER", () => {
            expect(registrationSchema.validate({
                    username: "TestUser2025",
                    email: "test@example.com",
                    password: "Password123"
                }).error
            ).toBeUndefined();

            expect(registrationSchema.validate({
                    username: "ZsoltGamer005",
                    email: "test@example.com",
                    password: "Password123"
                }).error
            ).toBeUndefined();

            expect(registrationSchema.validate({
                    username: "Giliszabi1",
                    email: "test@example.com",
                    password: "Password123"
                }).error
            ).toBeUndefined();

            expect(registrationSchema.validate({
                    username: "giliszabi",
                    email: "test@example.com",
                    password: "Password123"
                }).error
            ).toBeUndefined();

            expect(registrationSchema.validate({
                    username: "Werneralex12",
                    email: "test@example.com",
                    password: "Password123"
                }).error
            ).toBeUndefined();
        });

        test("boundary", ()=>{
            expect(registrationSchema.validate({
                    username: "test1",
                    email: "test@example.com",
                    password: "Password123"
                }).error
            ).toBeUndefined();

            expect(registrationSchema.validate({
                    username: "a".repeat(32),
                    email: "test@example.com",
                    password: "Password123"
                }).error
            ).toBeUndefined();
        })

        test("boundary", ()=>{
            expect(registrationSchema.validate({
                    username: "test1",
                    email: "test@example.com",
                    password: "Password123"
                }).error
            ).toBeUndefined();

            expect(registrationSchema.validate({
                    username: "!test!",
                    email: "test@example.com",
                    password: "Password123"
                }).error
            ).toBeUndefined();

            expect(registrationSchema.validate({
                    username: "!--TEST--!",
                    email: "test@example.com",
                    password: "Password123"
                }).error
            ).toBeUndefined();

            expect(registrationSchema.validate({
                    username: "a".repeat(32),
                    email: "test@example.com",
                    password: "Password123"
                }).error
            ).toBeUndefined();
        })

        test("INVALID_USER", ()=>{
            expect(registrationSchema.validate({
                    username: "a".repeat(33),
                    email: "test@example.com",
                    password: "Password123"
                }).error.details[0].message
            ).toBe("USERNAME_TOO_LONG");

            expect(registrationSchema.validate({
                    username: "a",
                    email: "test@example.com",
                    password: "Password123"
                }).error.details[0].message
            ).toBe("USERNAME_TOO_SHORT");

            expect(registrationSchema.validate({
                    username: "Password123",
                    email: "test@example.com",
                    password: "Password123"
                }).error.details[0].message
            ).toBe("USERNAME_PASSWORD_IDENTICAL");
        });
    })
})