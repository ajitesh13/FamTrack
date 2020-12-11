const router = require('express').Router();
const express = require('express');
const User = require('../model/UserModel');
router.use(express.json());

router.post("/register", async (req, res) => {
    try{
        const user = await User.findOne({
            email: req.body.email,
            password: req.body.password
        });
        if (user) {
            res.send(user);
        } else {
            const name = req.body.name;
            const email = req.body.email;
            const password = req.body.password;
            const image = req.body.image;
            const newUser = new User({
                name: name,
                email: email,
                password: password,
                image: image,
                Trackee: [{
                    Trackee_id: ''
                }],
                Tracker: [{
                    Tracker_id: ''
                }],
                saved_location: [{
                    latitude: '', 
                    longitude: ''
                }],
                current_location: {
                    latitude: '',
                    longitude: ''
                }
            });
            newUser.save();
            res.send(newUser);
        }
    } catch {
        res.send({"error": "registration error"});
    }
});

module.exports = router;



