const { body } = require("express-validator");

exports.createProduct = [
  body("name").notEmpty(),
  body("price").isFloat({ gt: 0 }),
  body("category").notEmpty(),
];
