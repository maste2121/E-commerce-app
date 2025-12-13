const router = require("express").Router();
const c = require("../controllers/userController");
const { validate } = require("../middlewares/validate");
const rules = require("./validators/user.validators");

router.post("/signup", validate(rules.signup), c.signup);
router.post("/signin", validate(rules.signin), c.signin);

module.exports = router;
