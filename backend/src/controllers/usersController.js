const userService = require("../services/userService");

const { 

	validateCreateUser,
	
	validateUpdateUser

  } = require("../validators/userValidator");

const apiResponse = require("../utils/apiResponse");


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

const createUser = async (req, res) => {

    try {

	const validation = validateCreateUser(req.body);

        if (!validation.valid) {

            return apiResponse.error(

                res,

                400,

                validation.errors

            );

        }

        const user = await userService.createUser(req.body);

        return apiResponse.success(

            res,

            201,

            user

        );

    } catch (error) {

        return apiResponse.error(

            res,

            500,

            error.message

        );

    }

};

const updateUser = async (req, res) => {

    try {

        const id = req.params.id;

        const validation = validateUpdateUser(req.body);

        if (!validation.valid) {

            return apiResponse.error(

                res,

                400,

                validation.errors

            );

        }

        const user = await userService.updateUser(

            id,

            req.body

        );

        return apiResponse.success(

            res,

            200,

            user

        );

    } catch (error) {

        if (error.message === "Usuario no encontrado") {

            return apiResponse.error(

                res,

                404,

                error.message

            );

        }

        return apiResponse.error(

            res,

            500,

            error.message

        );

    }

};

const deactivateUser = async (req, res) => {

    try {

        const id = req.params.id;

        const result = await userService.deactivateUser(id);

        return apiResponse.success(

            res,

            200,

            result

        );

    } catch (error) {

        if (error.message === "Usuario no encontrado") {

            return apiResponse.error(

                res,

                404,

                error.message

            );

        }

        if (error.message === "El usuario ya está inactivo") {

            return apiResponse.error(

                res,

                400,

                error.message

            );

        }

        return apiResponse.error(

            res,

            500,

            error.message

        );

    }

};

module.exports = {

    getAllUsers,
    getUserById,
    createUser,
    updateUser,
    deactivateUser

};