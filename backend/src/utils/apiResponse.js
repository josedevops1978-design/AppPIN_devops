const success = (res, statusCode, data) => {

    return res.status(statusCode).json({

        success: true,

        data

    });

};

const error = (res, status, message) => {

    return res.status(status).json({

        success: false,

        message

    });

};

module.exports = {

    success,

    error

};