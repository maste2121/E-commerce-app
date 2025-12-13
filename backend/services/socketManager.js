const { Server } = require("socket.io");

const customerSockets = {};
const adminSockets = [];

function initSocket(server) {
  const io = new Server(server, {
    cors: { origin: "*", methods: ["GET", "POST", "PATCH"] },
  });

  io.on("connection", (socket) => {
    console.log("🟢 Socket connected:", socket.id);

    socket.on("register_admin", () => {
      if (!adminSockets.includes(socket.id)) adminSockets.push(socket.id);
    });

    socket.on("register_customer", (customerId) => {
      customerSockets[customerId] = socket.id;
    });

    socket.on("disconnect", () => {
      const idx = adminSockets.indexOf(socket.id);
      if (idx !== -1) adminSockets.splice(idx, 1);

      for (const id in customerSockets) {
        if (customerSockets[id] === socket.id) delete customerSockets[id];
      }
    });
  });

  return {
    notifyAdmins(order) {
      adminSockets.forEach((id) => io.to(id).emit("new_order", order));
    },
    notifyCustomer(customerId, data) {
      const socketId = customerSockets[customerId];
      if (socketId) io.to(socketId).emit("order_status_update", data);
    },
  };
}

module.exports = initSocket;
