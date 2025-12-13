const db = require("../config/db");

let socketService;

exports.attachSocket = (service) => {
  socketService = service;
};

exports.getOrders = async (_, res) => {
  const [orders] = await db.query("SELECT * FROM orders ORDER BY id DESC");
  res.json(orders);
};

exports.createOrder = async (req, res) => {
  const {
    customer_id,
    customer_name,
    product_id,
    product_name,
    product_price,
    quantity,
  } = req.body;

  const total = product_price * quantity;

  const [result] = await db.query(
    `INSERT INTO orders 
     (customer_id,customer_name,product_id,product_name,product_price,quantity,total_price,status,order_date)
     VALUES (?,?,?,?,?,?,?,'Pending',NOW())`,
    [
      customer_id || null,
      customer_name,
      product_id,
      product_name,
      product_price,
      quantity,
      total,
    ]
  );

  socketService?.notifyAdmins({
    orderId: result.insertId,
    customerName: customer_name,
    totalPrice: total,
  });

  res.json({ success: true, orderId: result.insertId });
};

exports.updateStatus = async (req, res) => {
  const { status, customer_id } = req.body;

  await db.query("UPDATE orders SET status=? WHERE id=?", [
    status,
    req.params.id,
  ]);

  socketService?.notifyCustomer(customer_id, {
    orderId: req.params.id,
    status,
  });

  res.json({ success: true });
};

exports.deleteOrder = async (req, res) => {
  await db.query("DELETE FROM orders WHERE id=?", [req.params.id]);
  res.json({ success: true });
};
