const router = require('express').Router();
const express = require('express');
const User = require('../model/UserModel');
router.use(express.json());

router.post("/register", (req, res) => {
    try{
        const name = req.body.name;
        const email = req.body.email;
        const password = req.body.password;
        const newUser = new User({
            name: name,
            email: email,
            password: password,
            Trackee: [{
                id:'',
                name: '',
                latitude: '',
                longitude: '',
                saved_location: {
                    latitude: '', 
                    longitude: ''
                }
            }],
            Tracker: [{
                id: '',
                name: ''
            }],
            saved_location: {
                latitude: '', 
                longitude: ''
            }
        });
        newUser.save();
        res.send(newUser);
    } catch {
        res.send({"error": "registration error"});
    }
});

module.exports = router;



