const express = require("express");
const routes = require("./routes");
const bodyParser = require("body-parser");
const cors = require("cors");
const app = express();
const http = require("http");
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);

require("./config/db")();

app.use(bodyParser.json({ limit: "50mb" }));
app.use(
  bodyParser.urlencoded({
    limit: "50mb",
    extended: true,
    parameterLimit: 50000,
  })
);

app.use(cors());

routes(app);

io.on("connection", (socket) => {
  console.log("Connected with socket IO");

  socket.on("join-chat", (room) => {
    socket.join(room);
  });

  socket.on("on-chat", (data) => {
    io.emit(data.chat._id, data);
  });

  socket.on("all", (data) => {
    io.emit("all", data);
  });
});

const port = 7000;
const host = "127.0.0.1";
server.listen(port, host, () => {
  console.log(`Server's listening at http://${host}:${port}`);
});
