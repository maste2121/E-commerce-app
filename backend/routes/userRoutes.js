const router = require("express").Router();
const c = require("../controllers/userController");
const { validate } = require("../middlewares/validate");
const rules = require("./validators/user.validators");

// ✅ ADD THIS LINE: This allows the "GET" request for /users
router.get("/", c.getUsers);

router.post("/signup", validate(rules.signup), c.signup);
router.post("/signin", validate(rules.signin), c.signin);

module.exports = router;
