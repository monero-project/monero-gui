const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;

app.use(express.json());
app.use(express.static(path.join(__dirname)));

app.post('/submit', (req, res) => {
    const { name, email, message } = req.body;
    const csvLine = `${new Date().toISOString()},${name},${email},${message}\n`;

    fs.appendFile('submissions.csv', csvLine, (err) => {
        if (err) {
            console.error('Failed to save submission:', err);
            return res.status(500).send('Failed to save submission.');
        }
        res.status(200).send('Form submitted successfully.');
    });
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
