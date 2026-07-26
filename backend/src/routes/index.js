const express = require("express");

const router = express.Router();

const database = require("../config/database");

const authRoutes = require("./authRoutes");

router.use("/auth", authRoutes);

router.get("/", (req, res) => {

    res.json({

        proyecto: "Gestión Usuarios DevOps",

        version: "1.0"

    });

});

router.get("/health", (req, res) => {

    database.query(

        "SELECT 1",

        (error) => {

            if (error) {

                return res.status(500).json({

                    status: "ERROR",

                    database: false

                });

            }

            res.json({

                status: "OK",

                database: true

            });

        }

    );

});

router.get("/info", (req, res) => {

    res.json({

        proyecto: "Sistema Gestión Usuarios",

        frontend: "Bootstrap",

        backend: "NodeJS",

        database: "MySQL",

        docker: false,

        terraform: false,

        githubActions: false

    });

});

module.exports = router;