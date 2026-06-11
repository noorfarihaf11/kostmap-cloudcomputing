const express = require('express');
const router = express.Router();
const kostController = require('../controllers/kostController');

router.get('/nearby', kostController.getNearbyKost); // harus sebelum /:id
router.get('/', kostController.getAllKost);
router.get('/:id', kostController.getKostById);

module.exports = router;