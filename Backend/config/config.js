require('dotenv').config();
// import dotenv from "dotenv"
// dotenv.config();


module.exports = {
  development: {
    username: process.env.POSTGRES_USERNAME,
    password: process.env.POSTGRES_PASSWORD,
    database: "broadbandaid_dev", 
    host: "127.0.0.1",
    dialect: "postgres"
  }
}