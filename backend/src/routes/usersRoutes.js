const express = require("express");

const router = express.Router();

const usersController = require("../controllers/usersController");

const authMiddleware = require("../middleware/authMiddleware");

router.get(
    "/",
    authMiddleware.verifyToken,
    usersController.getAllUsers
);

router.get(
    "/:id",
    authMiddleware.verifyToken,
    usersController.getUserById
);

module.exports = router;