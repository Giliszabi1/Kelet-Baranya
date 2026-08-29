import { describe, expect, test, beforeAll } from "vitest";

const API_URL = require('../shared/API_URL');


const DB_CONNECT = require('../../../../src/infrastructure/database/mysql.database');

beforeAll(async () => {
  await DB_CONNECT.query("CALL sp_delete_all_data()");
});

describe("Regisztráció API", () => {
  //normal
  const Normal_users = [
    {
      username: "testuser1",
      email: "test-example@example.com",
      password: "Password123!",
    },
    {
      username: "Zsoltgamer005",
      email: "zsoltgamerEmail@example.com",
      password: "ZsoltiPass123",
    },
    {
      username: "PatrikGamer1",
      email: "patrik.bubu@example.com",
      password: "PatrikuPass123",
    },{
      username: "Werneralex12",
      email: "werneralex12@example.com",
      password: "Password123!",
    }
  ];
  for (const user of Normal_users) {
    test(`NORMAL: ${user.username}, ${user.email},${user.password}`, async () => {
        const response = await fetch(`${API_URL}/auth/user/register`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(user),
        });
        expect(response.status).toBe(201);
    }, 20_000);
  }

  //Negative
  const Negative_users = [
    {
      username: "testuser1",
      email: "test-example@example.com",
      password: "",
    },
    {
      username: "Zsoltgamer005",
      email: "",
      password: "ZsoltiPass123",
    },
    {
      username: "",
      email: "patrik.bubu@example.com",
      password: "PatrikuPass123",
    },{
      username: "LakatosBálint12",
      email: "LakatosBálint12@example.com",
      password: "Pass",
    },
    //write me some bad users with invalid email, username and password
    {
      username: "Harasztialex12",
      email: "Harasztialex12example.com",
      password: "Password123.",
    },
    {
      username: "Ravasz Gábor 12",
      email: "RavaszGébor12@example.com",
      password: "Password123.",
    }
  ];
  for (const user of Negative_users) {
    test(`NEGATIVE: ${user.username}, ${user.email},${user.password}`, async () => {
        const response = await fetch(`${API_URL}/auth/user/register`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(user),
        });
        expect(response.status).toBe(400);
        const data = await response.json();
        expect(data.success).toBe(false);
    }, 20_000);
    
  }
});