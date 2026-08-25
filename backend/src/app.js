const express = require("express");

const cors = require("cors");

const routes = require("./routes");

const errorHandler = require("./middleware/errorMiddleware");

const { register, metricsMiddleware } = require("./metrics");

const app = express();

app.use(cors());

app.use(express.json());

app.use(express.urlencoded({ extended: true }));

app.use(metricsMiddleware);

app.get("/metrics", async (req, res) => {

    res.set("Content-Type", register.contentType);
    res.end(await register.metrics());

});

app.use("/api", routes);

app.use(errorHandler);

module.exports = app;