const express = require('express');
const cors = require('cors');
const kostRoutes = require('./routes/kostRoutes');
const authRoutes = require('./routes/authRoutes');
const favoriteRoutes = require('./routes/favoriteRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/kost', kostRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/favorites', favoriteRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Kost Directory API berjalan!' });
});

module.exports = app;