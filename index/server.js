const express = require("express");
const path = require("path");

const app = express();

app.get("/", (req, res) => {
    res.sendFile(path.join(__dirname + "/index.html"));
})

app.get("/history", (req, res) => {
    res.sendFile(path.join(__dirname + "/history.html"));
})

app.get("/rules", (req, res) => {
    res.sendFile(path.join(__dirname + "/rules.html"));
})

const server = app.listen(5009);
const portNumber = server.address().port;
console.log("port: " + portNumber);