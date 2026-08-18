import { describe, expect, test, beforeAll } from "vitest";
 
const API_URL = "http://server_test:3002/api";
 
const DB_CONNECT = require('../../../src/infrastructure/database/mysql.database');
 
const testUsers = [
  {
  username: "testuser1",
  email: "test-example@example.com",
  password: "Password123!",
  },
  {
  username: "Zsoltgamer005",
  email: "Zsoltgamer005@example.com",
  password: "zsoltiPass123",
  }
];
 
beforeAll(async () => {
  await DB_CONNECT.query("CALL sp_delete_all_data()");

  for (let index = 0; index < testUsers.length; index++) {
    const registerResponse = await fetch(`${API_URL}/auth/user/register`, {
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
      const usernameLoginResponse = await fetch(`${API_URL}/auth/user/login`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username: testUsers[index].username,
          password: testUsers[index].password,
        }),
      });
      const usernameLoginBody = await usernameLoginResponse.json();
    
      expect(usernameLoginResponse.status).toBe(200);
      expect(usernameLoginBody.success).toBe(true);
      expect(usernameLoginBody.data).toHaveProperty("accessToken");
      expect(usernameLoginBody.data).toHaveProperty("refreshToken");
      expect(usernameLoginBody.data.username).toBe(testUsers[index].username);
      expect(usernameLoginBody.data.email).toBe(testUsers[index].email);
    
      const emailLoginResponse = await fetch(`${API_URL}/auth/user/login`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: testUsers[index].email,
          password: testUsers[index].password,
        }),
      });
      const emailLoginBody = await emailLoginResponse.json();
    
      expect(emailLoginResponse.status).toBe(200);
      expect(emailLoginBody.success).toBe(true);
      expect(emailLoginBody.data).toHaveProperty("accessToken");
      expect(emailLoginBody.data).toHaveProperty("refreshToken");
    }, 20_000);
  }
});
 