const express = require("express");
const config = require("./config");
const mongoose = require("mongoose");
const cors = require('cors');
const app = express();
app.use(cors());
const userregister = require('./Routes/RegisterUser');
const userlogin = require('./Routes/LoginUser');
const addtrackee = require('./Routes/AddTrackee');
const gettrackee = require('./Routes/GetTrackee');
const getuser = require('./Routes/GetUser');
const savelocation = require('./Routes/SaveLocation');

app.use(express.json());
app.use(
    express.urlencoded({
        extended: false,
    })
);

app.use("/api", userregister);
app.use("/api", userlogin);
app.use("/api", addtrackee);
app.use("/api", gettrackee);
app.use("/api", getuser);
app.use("/api", savelocation);

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