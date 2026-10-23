const { useAzureMonitor } = require("@azure/monitor-opentelemetry");
const http = require("node:http");

useAzureMonitor();

const server = http.createServer((request, response) => {
  if (request.url === "/health") {
    response.writeHead(200, { "content-type": "text/plain" });
    response.end("Super healthy");
    return;
  }

  if (request.url === "/work") {
    const finishAt = Date.now() + 500;
    let value = 0;
    while (Date.now() < finishAt) {
      value = Math.sqrt(value + Math.random());
    }
    response.writeHead(200, { "content-type": "text/plain" });
    response.end(`Work completed: ${value.toFixed(2)}`);
    return;
  }

  response.writeHead(200, { "content-type": "text/html; charset=utf-8" });
  response.end(
    "<!doctype html><html><head><title>Vybhava App Service autoscale sample</title></head>" +
      "<body><h1>Vybhava App Service autoscale sample</h1>" +
      "<p>Application Insights is collecting request telemetry.</p>" +
      "<p>Visit <a href=\"/work\">/work</a> to generate a brief CPU workload.</p></body></html>",
  );
});

const port = Number(process.env.PORT || 8080);
server.listen(port);
