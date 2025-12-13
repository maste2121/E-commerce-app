const { body } = require("express-validator");

exports.signup = [
  body("name").notEmpty().withMessage("Name is required"),
  body("email").isEmail().withMessage("Valid email required"),
  body("password")
    .isLength({ min: 6 })
    .withMessage("Password min 6 characters"),
];

exports.signin = [body("email").isEmail(), body("password").notEmpty()];
