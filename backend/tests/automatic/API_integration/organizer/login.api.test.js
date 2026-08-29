import { describe, expect, test, beforeAll } from "vitest";
 
const API_URL = require('../shared/API_URL');
 
const DB_CONNECT = require('../../../../src/infrastructure/database/mysql.database');
 
const testUsers = [
  {
  username: "testuser1",
  email: "test-example@example.com",
  password: "Password123!",
  fullname: "Test User"
  },
  {
  username: "Zsoltgamer005",
  email: "Zsoltgamer005@example.com",
  password: "zsoltiPass123",
  fullname: "Test User"
  }
];
 
beforeAll(async () => {
  await DB_CONNECT.query("CALL sp_delete_all_data()");

  for (let index = 0; index < testUsers.length; index++) {
    const registerResponse = await fetch(`${API_URL}/auth/organizer/register`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(testUsers[index]),
    });
  
    if (registerResponse.status !== 201) {
      throw new Error(
        `A login teszthez szükséges teszt felhasználó regisztrációja sikertelen volt (status: ${registerResponse.status}).`
      );
    }
  }
}, 20_000);
 
describe("Bejelentkezés API", () => {
  for (let index = 0; index < testUsers.length; index++) {
    test(`NORMAL: ${testUsers[index].username}, ${testUsers[index].password}`, async () => {
      const usernameLoginResponse = await fetch(`${API_URL}/auth/organizer/login`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username: testUsers[index].username,
          password: testUsers[index].password,
        }),
      });
      console.log(usernameLoginResponse)
      console.log(testUsers[index].username, testUsers[index].password)
      expect(usernameLoginResponse.status).toBe(200);
    
      const emailLoginResponse = await fetch(`${API_URL}/auth/organizer/login`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: testUsers[index].email,
          password: testUsers[index].password,
        }),
      });
      expect(emailLoginResponse.status).toBe(200);
    }, 20_000);
  }
});
 