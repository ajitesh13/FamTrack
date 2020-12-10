const router = require('express').Router();
const express = require('express');
const User = require('../model/UserModel');
router.use(express.json());

router.post("/addlocation", async(req, res) => {
    try {   
        const user = User.findById(req.body.id);
        if (user) {
            await User.updateOne(
                { _id: req.body.id},
                {current_location: req.body.location}
            );
            res.send({"msg": "Location Saved!"});
        } else {
            res.send({"msg": "user doesn't exist"});
        }
    } catch(err) {
        res.send({"err": `${err}`});
    }
});

module.exports = router;