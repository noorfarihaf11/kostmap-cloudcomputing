const jwt = require('jsonwebtoken');
const pool = require('../config/database');

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Token tidak ada, akses ditolak' });
  }

  try {
    // Cek apakah token ada di blacklist
    const blacklisted = await pool.query(
      'SELECT id FROM token_blacklist WHERE token = $1',
      [token]
    );
    if (blacklisted.rows.length > 0) {
      return res.status(401).json({ error: 'Token sudah tidak valid, silakan login lagi' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();

  } catch (error) {
    return res.status(403).json({ error: 'Token tidak valid' });
  }
};

module.exports = authMiddleware;