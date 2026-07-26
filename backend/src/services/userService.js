const userModel = require("../models/userModel");

const getAllUsers = async () => {

    return await userModel.findAll();

};

const getUserById = async (id) => {

    return await userModel.findById(id);

};


module.exports = {

    getAllUsers,
    getUserById	

};