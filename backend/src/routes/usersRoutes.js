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

router.post(
    "/",
    authMiddleware.verifyToken,
    usersController.createUser
);

router.put(
    "/:id",
    authMiddleware.verifyToken,
    usersController.updateUser
);

router.delete(
    "/:id",
    authMiddleware.verifyToken,
    usersController.deactivateUser
);

module.exports = router;