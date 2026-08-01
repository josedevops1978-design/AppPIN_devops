const validateCreateUser = (user) => {

    const errors = [];

    if (!user.nombre || user.nombre.trim() === "") {
        errors.push("El nombre es obligatorio");
    }

    if (!user.apellido || user.apellido.trim() === "") {
        errors.push("El apellido es obligatorio");
    }

    if (!user.email || user.email.trim() === "") {
        errors.push("El email es obligatorio");
    }

    if (!user.password || user.password.length < 6) {
        errors.push("La contraseña debe tener al menos 6 caracteres");
    }

    return {

        valid: errors.length === 0,

        errors

    };

};

const validateUpdateUser = (user) => {

    const errors = [];

    if (!user.nombre || user.nombre.trim() === "") {
        errors.push("El nombre es obligatorio");
    }

    if (!user.apellido || user.apellido.trim() === "") {
        errors.push("El apellido es obligatorio");
    }

    if (!user.email || user.email.trim() === "") {
        errors.push("El email es obligatorio");
    }

    return {

        valid: errors.length === 0,

        errors

    };

};

module.exports = {

    validateCreateUser,

    validateUpdateUser

};