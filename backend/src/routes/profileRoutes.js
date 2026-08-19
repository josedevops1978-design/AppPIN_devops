const express = require("express");

const router = express.Router();

const profileController = require("../controllers/profileController");

const authMiddleware = require("../middleware/authMiddleware");

router.get(
    "/",
    authMiddleware.verifyToken,
    profileController.getProfile
);

module.exports = router;