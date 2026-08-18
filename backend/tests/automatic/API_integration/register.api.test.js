import { describe, expect, test, beforeAll } from "vitest";

const API_URL = "http://server_test:3002/api";

const DB_CONNECT = require('../../../src/infrastructure/database/mysql.database');

beforeAll(async () => {
  await DB_CONNECT.query("CALL sp_delete_all_data()");
});

describe("Regisztráció API", () => {
  const users = [
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
    },
  ];
  for (const user of users) {
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
});