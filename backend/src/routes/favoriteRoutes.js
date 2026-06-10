const express = require('express');
const router = express.Router();

const favoriteController = require('../controllers/favoriteController');
const authMiddleware = require('../middleware/authMiddleware');

router.post(
  '/',
  authMiddleware,
  favoriteController.addFavorite
);

router.get(
  '/',
  authMiddleware,
  favoriteController.getMyFavorites
);

router.delete(
  '/:kost_id',
  authMiddleware,
  favoriteController.removeFavorite
);

module.exports = router;