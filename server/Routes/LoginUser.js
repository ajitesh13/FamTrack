const router = require('express').Router();
const express = require('express');
const User = require('../model/UserModel');
router.use(express.json());

router.post("/login", async (req, res) => {
    try {
        const user = await User.findOne({
            email: req.body.email,
            password: req.body.password
        });
        if (user) {
            res.send(user);
        } else {
            res.send({"error": "invalid email id and password"});
        }
    } catch {
        res.status({"error" : "login error"});
    }
});

module.exports = router;