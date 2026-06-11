const express = require('express');
const cors = require('cors');
const https = require('https');
const http = require('http');
const kostRoutes = require('./routes/kostRoutes');
const authRoutes = require('./routes/authRoutes');
const favoriteRoutes = require('./routes/favoriteRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Proxy gambar dari Google CDN untuk mengatasi CORS di Flutter Web
app.get('/api/image-proxy', (req, res) => {
  const { url } = req.query;
  if (!url) return res.status(400).json({ error: 'Parameter url wajib diisi' });

  let targetUrl;
  try {
    targetUrl = new URL(url);
  } catch {
    return res.status(400).json({ error: 'URL tidak valid' });
  }

  const protocol = targetUrl.protocol === 'https:' ? https : http;

  protocol.get(
    url,
    {
      headers: {
        'User-Agent': 'Mozilla/5.0',
        'Referer': 'https://www.google.com/',
      },
    },
    (imgRes) => {
      const contentType = imgRes.headers['content-type'] || 'image/jpeg';
      res.setHeader('Content-Type', contentType);
      res.setHeader('Cache-Control', 'public, max-age=86400');
      imgRes.pipe(res);
    }
  ).on('error', () => res.status(502).json({ error: 'Gagal mengambil gambar' }));
});

app.use('/api/kost', kostRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/favorites', favoriteRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Kost Directory API berjalan!' });
});

module.exports = app;