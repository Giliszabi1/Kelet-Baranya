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
        test("NORMAL", () => {
            expect(usernameValidation.validate("TestUser2025").error).toBeUndefined();
            expect(usernameValidation.validate("ZsoltGamer005").error).toBeUndefined();
            expect(usernameValidation.validate("Giliszabi1").error).toBeUndefined();
            expect(usernameValidation.validate("giliszabi").error).toBeUndefined();
            expect(usernameValidation.validate("Werneralex12").error).toBeUndefined();
            
        });

        test("BOUNDARY", () => {
            expect(usernameValidation.validate("test1").error).toBeUndefined();
            expect(usernameValidation.validate("a".repeat(32)).error).toBeUndefined();
            expect(usernameValidation.validate("testf").error).toBeUndefined();
            expect(usernameValidation.validate("000TEST000").error).toBeUndefined();
        });

        test("INVALID", () => {
            expect(usernameValidation.validate("a".repeat(33)).error.details[0].message).toBe("USERNAME_TOO_LONG");
            expect(usernameValidation.validate("a").error.details[0].message).toBe("USERNAME_TOO_SHORT");
            expect(usernameValidation.validate("Test_User").error.details[0].message).toBe("USERNAME_INVALID");
            expect(usernameValidation.validate("111111111").error.details[0].message).toBe("USERNAME_INVALID");
        });

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