const userModel = require("../models/userModel");

const getAllUsers = async () => {

    return await userModel.findAll();

};

module.exports = {

    getAllUsers

};