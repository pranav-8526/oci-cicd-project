const http = require('http');
const port = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Hello OCI! The CI/CD Pipeline is working perfectly.\n');
  } else if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'UP', message: 'Service is healthy' }));
  } else {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not Found\n');
  }
});

server.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
