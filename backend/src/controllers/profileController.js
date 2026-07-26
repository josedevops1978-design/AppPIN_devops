const userModel = require("../models/userModel");

const getProfile = async (req, res) => {

    try {

        const user = await userModel.findById(req.user.id);

        if (!user) {

            return res.status(404).json({
                success: false,
                message: "Usuario no encontrado"
            });

        }

        return res.json({
            success: true,
            usuario: user
        });

    } catch (error) {

        return res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

module.exports = {
    getProfile
};