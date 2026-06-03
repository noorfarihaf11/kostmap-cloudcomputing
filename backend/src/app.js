const express = require('express');
const cors = require('cors');
const kostRoutes = require('./routes/kostRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/kost', kostRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Kost Directory API berjalan!' });
});

module.exports = app;