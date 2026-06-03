const pool = require('../config/database');

// GET /api/kost
// bisa filter: ?label=Putra atau ?city=Sidoarjo
const getAllKost = async (req, res) => {
  try {
    const { label, city } = req.query;

    let query = 'SELECT * FROM kost';
    let values = [];
    let conditions = [];

    if (label) {
      conditions.push(`label = $${values.length + 1}`);
      values.push(label);
    }

    if (city) {
      conditions.push(`city = $${values.length + 1}`);
      values.push(city);
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY title ASC';

    const result = await pool.query(query, values);
    res.json({
      total: result.rows.length,
      data: result.rows
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal mengambil data kost' });
  }
};

// GET /api/kost/:id
const getKostById = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM kost WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Kost tidak ditemukan' });
    }

    res.json(result.rows[0]);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal mengambil detail kost' });
  }
};

// GET /api/kost/nearby?lat=-7.44&lng=112.71&limit=10
// menghitung jarak pakai rumus Haversine di PostgreSQL
const getNearbyKost = async (req, res) => {
  try {
    const { lat, lng, limit = 10 } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ error: 'Parameter lat dan lng wajib diisi' });
    }

    const query = `
      SELECT *,
        (6371 * acos(
          cos(radians($1)) * cos(radians(lat)) *
          cos(radians(lng) - radians($2)) +
          sin(radians($1)) * sin(radians(lat))
        )) AS distance_km
      FROM kost
      ORDER BY distance_km ASC
      LIMIT $3
    `;

    const result = await pool.query(query, [lat, lng, limit]);
    res.json({
      total: result.rows.length,
      data: result.rows
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal mengambil kost terdekat' });
  }
};

module.exports = { getAllKost, getKostById, getNearbyKost };