const mongoose = require("mongoose");
require("dotenv").config();

// const urlMongodb = process.env.URL_MONGODB
// const urlMongodb = "mongodb+srv://root2:root123@cluster0.nk84uyl.mongodb.net/";
const urlMongodb = 'mongodb://127.0.0.1:27017/chatify'
const connectDB = () => {
  mongoose
    .set("strictQuery", false)
    .connect(urlMongodb, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    })
    .then((res) => {
      console.log("Connect successfully!");
    })
    .catch((error) => {
      console.log("Connect failure!");
    });
};

module.exports = connectDB;
