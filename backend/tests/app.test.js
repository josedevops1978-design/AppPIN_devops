jest.mock("mysql2", () => {

    const connection = {
        connect: jest.fn((callback) => {
            callback(null);
        }),

        query: jest.fn((sql, callback) => {
            if (callback) {
                callback(null, []);
            }
        }),

        end: jest.fn()
    };

    return {
        createConnection: jest.fn(() => connection)
    };

});

const request = require("supertest");

const app = require("../src/app");

describe("API", () => {

    test("GET /api/info debe devolver información del proyecto", async () => {

        const response =
            await request(app)
                .get("/api/info");

        expect(response.statusCode).toBe(200);

        expect(response.body.proyecto)
            .toBe("Sistema Gestión Usuarios");

        expect(response.body.backend)
            .toBe("NodeJS");

        expect(response.body.database)
            .toBe("MySQL");

    });

});