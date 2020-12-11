const router = require('express').Router();
const express = require('express');
const User = require('../model/UserModel');
router.use(express.json());

router.post("/getuser", async(req, res) => { 
    try {
        const user = await User.findById(req.body.id);
        if (user) {
            res.send(user);
        } else {
            res.send({"err": "User doesn't exist"});
        }
    } catch(err) {
        res.send({"err": `${err}`});
    }
});

module.exports = router;