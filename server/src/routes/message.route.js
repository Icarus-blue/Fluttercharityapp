const multer = require('multer')
const express = require('express');
const path = require('path');
const fs = require('fs');
const { protect } = require('../middlewares/auth.middleware');
const messageController = require('../controllers/message.controller');

const router = express.Router();
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, 'uploads/')
    },
    filename: function (req, file, cb) {
      cb(null, Date.now() + '-' + file.originalname)
    }
  });
const upload = multer({ storage: storage });

const messageRoute = app => {
    router.get('/:chatId', protect, messageController.allMessages);
    router.post('/', protect, upload.single('file'), messageController.sendMessage);
    router.patch('/:messageId', protect, messageController.readMessage);

    // New route for downloading files
    router.get('/download/:filename', protect, (req, res) => {
        const filename = req.params.filename;
        const projectRoot = path.resolve(__dirname, '..', '..'); // Go up two levels from 'src'
        const filePath = path.join(projectRoot, 'uploads', filename);
        // Check if file exists
        if (fs.existsSync(filePath)) {
            console.log('Hello ');
            res.download(filePath, filename, (err) => {
                if (err) {
                    res.status(500).send('Error downloading file');
                }
            });
        } else {
            res.status(404).send('File not found');
        }
    });

    return app.use('/api/message', router);
};

module.exports = messageRoute;