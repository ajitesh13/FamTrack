const express = require("express");
const config = require("./config");
const mongoose = require("mongoose");
const cors = require('cors');
const app = express();
app.use(cors());
const userregister = require('./Routes/RegisterUserRoute');
const userlogin = require('./Routes/LoginUser');

app.use(express.json());
app.use(
    express.urlencoded({
        extended: false,
    })
);

app.use("/api", userregister);
app.use("/api", userlogin);

const mongodburl = config.MONGODB_URL;
mongoose
.connect(mongodburl, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    useCreateIndex: true,
}).catch((err) => {
    console.log(`Error Thrown in Mongoose Connection(server.js): ${err}`);
});

app.get("/", (req, res) => {
    res.send({"msg": "This is sample GET"});
});


const port = process.config.PORT || 5000;
app.listen(port, () => {
    console.log(`Server running successfully at http://localhost:${port}`);
});