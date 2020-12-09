const router = require('express').Router();
const express = require('express');
const User = require('../model/UserModel');
router.use(express.json());

router.post("/savelocation", async(req, res) => {
    try {   
        const user = await User.findById(req.body.id);
        if (user) {
            await User.update(
                {_id: req.body.id},
                {$push: {saved_location: req.body.Saved_location}}
            );
            res.send({"msg": "location saved"});
        } else {
            res.send({"msg": "user doesn't exist"});
        }

    } catch(err) {
        res.send({"err": `${err}`});
    }
});

module.exports = router;