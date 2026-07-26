const userService = require("../services/userService");

const getAllUsers = async (req, res) => {

    try {

        const users = await userService.getAllUsers();

        return res.status(200).json({

            success: true,

            total: users.length,

            data: users

        });

    } catch (error) {

        console.error(error);

        return res.status(500).json({

            success: false,

            message: "Error al obtener los usuarios"

        });

    }

};

module.exports = {

    getAllUsers

};