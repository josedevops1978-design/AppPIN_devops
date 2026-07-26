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

const getUserById = async (req, res) => {

    try {

        const id = req.params.id;

        const user = await userService.getUserById(id);

        if (!user) {

            return res.status(404).json({

                success: false,

                message: "Usuario no encontrado"

            });

        }

        return res.status(200).json({

            success: true,

            data: user

        });

    } catch (error) {

        console.error(error);

        return res.status(500).json({

            success: false,

            message: "Error al obtener el usuario"

        });

    }

};

module.exports = {

    getAllUsers,
    getUserById

};