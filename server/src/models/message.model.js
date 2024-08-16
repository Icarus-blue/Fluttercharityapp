// const mongoose = require('mongoose')

// const Schema = mongoose.Schema

// const messageSchema = new Schema({
//     sender: { type: mongoose.Schema.Types.ObjectId, ref: "user" },
//     content: { type: String, trim: true },
//     chat: { type: mongoose.Schema.Types.ObjectId, ref: "chat" },
//     readBy: [{ type: mongoose.Schema.Types.ObjectId, ref: "user" }],
// },
//     { timestamps: true }
// )

// module.exports = mongoose.model('message', messageSchema)


const mongoose = require('mongoose')

const Schema = mongoose.Schema

const messageSchema = new Schema({
    sender: { type: mongoose.Schema.Types.ObjectId, ref: "user" },
    content: { type: String, trim: true },
    chat: { type: mongoose.Schema.Types.ObjectId, ref: "chat" },
    readBy: [{ type: mongoose.Schema.Types.ObjectId, ref: "user" }],
    file: {
        filename: { type: String },
        originalname: { type: String },
        mimetype: { type: String },
        path: { type: String }
    },
    caption: { type: String, trim: true },
    messageType: { type: String, enum: ['text', 'file'], default: 'text' }
},
    { timestamps: true }
)

module.exports = mongoose.model('message', messageSchema)