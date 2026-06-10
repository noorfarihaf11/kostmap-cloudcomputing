const express = require('express');
const router = express.Router();
const kostController = require('../controllers/kostController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/nearby', authMiddleware, kostController.getNearbyKost); // harus sebelum /:id
router.get('/', authMiddleware, kostController.getAllKost); // ini teh buat /api/kost sama /api/kos?label
router.get('/:id', authMiddleware, kostController.getKostById);

module.exports = router;