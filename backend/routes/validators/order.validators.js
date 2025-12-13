const { body } = require("express-validator");

exports.createOrder = [
  body("customer_name").notEmpty(),
  body("product_id").isInt(),
  body("product_price").isFloat({ gt: 0 }),
  body("quantity").isInt({ gt: 0 }),
];
