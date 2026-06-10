const pool = require('../config/database');

const addFavorite = async (req, res) => {
  try {
    const userId = req.user.id;
    const { kost_id } = req.body;

    const result = await pool.query(
      `
      INSERT INTO favorites (user_id, kost_id)
      VALUES ($1, $2)
      RETURNING *
      `,
      [userId, kost_id]
    );

    res.status(201).json({
      message: 'Berhasil ditambahkan ke favorite',
      favorite: result.rows[0]
    });

  } catch (error) {

    if (error.code === '23505') {
      return res.status(400).json({
        error: 'Kost sudah ada di favorite'
      });
    }

    console.error(error);

    res.status(500).json({
      error: 'Gagal menambahkan favorite'
    });
  }
};

const getMyFavorites = async (req, res) => {
  try {

    const userId = req.user.id;

    const result = await pool.query(
      `
      SELECT
        f.id AS favorite_id,
        k.*
      FROM favorites f
      JOIN kost k
      ON f.kost_id = k.id
      WHERE f.user_id = $1
      ORDER BY f.created_at DESC
      `,
      [userId]
    );

    res.json(result.rows);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      error: 'Gagal mengambil favorite'
    });
  }
};

const removeFavorite = async (req, res) => {
  try {

    const userId = req.user.id;
    const { kost_id } = req.params;

    await pool.query(
      `
      DELETE FROM favorites
      WHERE user_id = $1
      AND kost_id = $2
      `,
      [userId, kost_id]
    );

    res.json({
      message: 'Favorite berhasil dihapus'
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      error: 'Gagal menghapus favorite'
    });
  }
};

module.exports = {
  addFavorite,
  getMyFavorites,
  removeFavorite
};