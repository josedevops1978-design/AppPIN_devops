const authService = require("../services/authService");

const login = async (req, res) => {

    try {

        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: "Debe ingresar email y contraseña"
            });
        }

        const resultado = await authService.login(email, password);

        return res.status(200).json({
            success: true,
            token: resultado.token,
            usuario: resultado.usuario
        });

    } catch (error) {

        return res.status(401).json({
            success: false,
            message: error.message
        });

    }

};

module.exports = {
    login
};