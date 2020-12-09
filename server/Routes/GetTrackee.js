const router = require('express').Router();
const express = require('express');
const User = require('../model/UserModel');
router.use(express.json());

router.post("/gettrackee", async(req, res) => { 
    try {
        const user = await User.findById(req.body.Tracker_id);
        let trackeelist = user.Trackee;
        let finaltrackeelist = new Array();
        trackeelist.forEach(element => {
            if (element.Trackee_id != "") {
                finaltrackeelist.push(element.Trackee_id);
            }
        });
        if (user) {
            res.send(finaltrackeelist);
        } else {
            res.send({"err": "Tracker doesn't exist"});
        }
    } catch(err) {
        res.send({"err": `${err}`});
    }
});

module.exports = router;