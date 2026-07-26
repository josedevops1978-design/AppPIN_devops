const express = require("express");

const router = express.Router();

const usersController = require("../controllers/usersController");

const authMiddleware = require("../middleware/authMiddleware");

router.get(
    "/",
    authMiddleware.verifyToken,
    usersController.getAllUsers
);

module.exports = router;