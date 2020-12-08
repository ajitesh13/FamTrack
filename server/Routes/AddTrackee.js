const router = require('express').Router();
const express = require('express');
const User = require('../model/UserModel');
router.use(express.json());

router.post("/addtrackee/:email", async(req, res) => { 
    try {
        const user = await User.findOne({
            email: req.body.Trackee[0].email
        });
        if (user) {
            const tracker = await User.update(
                { email: req.params.email },
                { $push: {Trackee: req.body.Trackee}}
            );
            // res.send({"msg": "Trackee added"});
            const trackee = await User.update(
                {email: req.body.Trackee[0].email},
                {$push: {Tracker: req.body.Tracker}}
            );
            res.send({"msg": "Trackee added successfully!"});
        } else {
            res.send({"err": "trackee doesn't esists"});
        }
    } catch(err) {
        res.send({"err": `${err}`});
    }
});

module.exports = router;