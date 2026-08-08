const eslint = require("@eslint/js");

module.exports = [
    eslint.configs.recommended,

    {
        files: ["**/*.js"],

        languageOptions: {
            globals: {
                require: "readonly",
                module: "readonly",
                process: "readonly",
                console: "readonly"
            }
        },

        rules: {
            "no-unused-vars": [
                "error",
                {
                    argsIgnorePattern: "^_"
                }
            ]
        }
    }
];