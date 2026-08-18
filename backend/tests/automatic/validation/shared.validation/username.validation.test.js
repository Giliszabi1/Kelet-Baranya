import { describe, expect, test } from "vitest";

import validate from '../../../../src/shared/utils/validation';

import usernameValidation from '../../../../src/shared/validation/username.validation';

const RANDOM_TEST_LENGTH = 10_000;
const approved_chars = /^[\p{L}\p{N}]+$/u;

const chars = 
`abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
áéíóöőúüűÁÉÍÓÖŐÚÜŰ
äöüÄÖÜß
0123456789
!@#$%^&*._-
~\\|&, \t\n\r,€£©®`;

describe("USERNAME", () => {

        describe("NORMAL", ()=>{
            test(`USERNAME: TestUser2025`, () => {
                expect(usernameValidation.validate("TestUser2025").error).toBeUndefined();
            });

            test(`USERNAME: ZsoltGamer005`, () => {
                expect(usernameValidation.validate("ZsoltGamer005").error).toBeUndefined();
            });

            test(`USERNAME: Giliszabi1`, () => {
                expect(usernameValidation.validate("Giliszabi1").error).toBeUndefined();
            });

            test(`USERNAME: giliszabi`, () => {
                expect(usernameValidation.validate("giliszabi").error).toBeUndefined();
            });

            test(`USERNAME: Werneralex12`, () => {
                expect(usernameValidation.validate("Werneralex12").error).toBeUndefined();
            });
        })

        describe("BOUNDARY", ()=>{

            test("USERNAME: test1", () => {
                expect(usernameValidation.validate("test1").error).toBeUndefined();
            });

            test(`USERNAME: ${"a".repeat(32)}`, () => {
                expect(usernameValidation.validate("a".repeat(32)).error).toBeUndefined();
            });

            test("USERNAME: testf", () => {
                expect(usernameValidation.validate("testf").error).toBeUndefined();
            });

            test("USERNAME: 000TEST000", () => {
                expect(usernameValidation.validate("000TEST000").error).toBeUndefined();
            });
        })
            
           
            
        

        describe("INVALID", ()=>{
            test(`USERNAME: ${"a".repeat(33)}`, () => {
                expect(usernameValidation.validate("a".repeat(33)).error.details[0].message).toBe("USERNAME_TOO_LONG");
            });

            test("USERNAME: a", () => {
                expect(usernameValidation.validate("a").error.details[0].message).toBe("USERNAME_TOO_SHORT");
            });

            test("USERNAME: Test_User", () => {
                expect(usernameValidation.validate("Test_User").error.details[0].message).toBe("USERNAME_INVALID");
            });

            test("USERNAME: 111111111", () => {
                expect(usernameValidation.validate("111111111").error.details[0].message).toBe("USERNAME_INVALID");
            });
        })

        test("RANDOM_TEST", ()=>{
            for (let i = 0; i < RANDOM_TEST_LENGTH; i++) {
                const usernameLength = Math.floor(Math.random() * 40);
                let username = ""
                let isContainInvalidChar = false
                let isContainLetter = false
                for (let j = 0; j < usernameLength; j++) {
                    const char = chars[Math.floor(Math.random()*chars.length)]
                    username += char
                    if(!approved_chars.test(char)){
                        isContainInvalidChar = true;
                    }

                    if (/[a-zA-Z]/.test(char)) {
                        isContainLetter = true;
                    }
                }

        
                if(usernameLength <= 32 && usernameLength >= 5 && !isContainInvalidChar && isContainLetter){
                    expect(usernameValidation.validate(username).error).toBeUndefined()
                    //console.log("VALID: "+ username)
                }else{
                    expect(usernameValidation.validate(username).error.details[0].message).not.toBeUndefined();
                    //console.log("INVALID: "+ JSON.stringify(username))
                }
            }
        })
    })