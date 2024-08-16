const messageModel = require('../models/message.model')
const chatModel = require('../models/chat.model')
const userModel = require('../models/user.model')

const messageController = {
    allMessages: async (req, res) => {
        try {
            const messages = await messageModel.find({ chat: req.params.chatId })
                .populate("sender", "name image email")
                .populate("chat")
            res.json(messages)
        } catch (error) {
            res.status(400)
            throw new Error(error.message)
        }
    },

    sendMessage: async (req, res) => {
        const { content, chatId, caption } = req.body
    
        if (!chatId) {
            console.log("Invalid data passed into request")
            return res.sendStatus(400)
        }
    
        var newMessage = {
            sender: req.user._id,
            chat: chatId,
        }
    
        if (content) {
            newMessage.content = content
        } else if (req.file) {
            newMessage.file = {
                filename: req.file.filename,
                originalname: req.file.originalname,
                mimetype: req.file.mimetype,
                path: req.file.path
            }
            if (caption) {
                newMessage.caption = caption
            }
        } else {
            console.log("No content or file provided")
            return res.sendStatus(400)
        }
    
        try {
            var message = await messageModel.create(newMessage)
    
            message = await message.populate("sender", "name image")
            message = await message.populate("chat")
            message = await userModel.populate(message, {
                path: "chat.users",
                select: "name image email",
            })
    
            await chatModel.findByIdAndUpdate(req.body.chatId, { latestMessage: message })
    
            res.json(message)
        } catch (error) {
            res.status(400)
            throw new Error(error.message)
        }
    },

    readMessage: async (req, res, next) => {
        const messageId = req.params.messageId

        if (!messageId) {
            console.log("Invalid data passed into request")
            return res.sendStatus(400)
        }

        await messageModel.findByIdAndUpdate(messageId, { readBy: req.user._id })
            .then(async (message) => {
                res.json(message)
            })
            .catch(next)
    }
}

module.exports = messageController
