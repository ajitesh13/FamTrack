const router = require('express').Router();
const express = require('express');
const User = require('../model/UserModel');
router.use(express.json());

router.post("/addtrackee", async(req, res) => { 
    try {
        const user = await User.findById(req.body.Trackee[0].Trackee_id);
        if (user) {
            const tracker = await User.update(
                { _id: req.body.Tracker[0].Tracker_id },
                { $push: {Trackee: req.body.Trackee}}
            );
            const trackee = await User.update(
                {_id: req.body.Trackee[0].Trackee_id},
                {$push: {Tracker: req.body.Tracker}}
            );
            res.send({"msg": "Trackee added successfully!"});
        } else {
            res.send({"err": "Trackee doesn't esists"});
        }
    } catch(err) {
        res.send({"err": `${err}`});
    }
});

module.exports = router;