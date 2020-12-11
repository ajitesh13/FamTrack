const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    name: {
        type: String,
        default: ''
    },
    email: {
        type: String,
        default: ''
    },
    password: {
        type: String,
        default: ''
    },
    image: {
        type: String,
        default: ''
    },
    Trackee: [{
        Trackee_id: {
            type: String,
            default: ''
        }
    }],
    Tracker: [{
        Tracker_id: {
            type: String,
            default: ''
        }
    }],
    saved_location: [{
        latitude: {
            type: String,
            default: ''
        }, 
        longitude: {
            type: String,
            default: ''
        }
    }],
    current_location: {
        latitude: {
            type: String,
            default: ''
        }, 
        longitude: {
            type: String,
            default: ''
        }
    }
});

const User = mongoose.model('User', userSchema);

module.exports = User;