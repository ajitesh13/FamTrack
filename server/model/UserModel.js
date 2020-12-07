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
    Trackee: [{
        id: {
            type: String,
            default: ''
        },
        name: {
            type: String,
            default: ''
        },
        latitude: {
            type: String,
            default: '',
        },
        longitude: {
            type: String,
            default: ''
        },
        saved_location: {
            latitude: {
                type: String,
                default: ''
            }, 
            longitude: {
                type: String,
                default: ''
            }
        }
    }],
    Tracker: [{
        id: {
            type: String,
            default: ''
        },
        name: {
            type: String,
            default: ''
        }
    }],
    saved_location: {
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