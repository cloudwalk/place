const canvas = document.getElementById("grid");
const ctx = canvas.getContext("2d");
const colorPicker = document.getElementById("color-picker");

const GRID_WIDTH = 200;
const GRID_HEIGHT = 100;
const PIXEL_SIZE = 7;

let selectedColor = "#000000";

const colors = [
  "#000000",
  "#FFFFFF",
  "#FF0000",
  "#00FF00",
  "#0000FF",
  "#FFFF00",
  "#00FFFF",
  "#FF00FF",
  "#800000",
  "#008000",
  "#000080",
  "#808000",
  "#800080",
  "#008080",
  "#C0C0C0",
  "#808080",
];

colors.forEach((color) => {
  const button = document.createElement("button");
  button.className = "color-button";
  button.style.backgroundColor = color;
  button.addEventListener("click", () => {
    selectedColor = color;
  });
  colorPicker.appendChild(button);
});

function drawGrid() {
  ctx.fillStyle = "#FFFFFF";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

function drawPixel(x, y, color) {
  ctx.fillStyle = color;
  ctx.fillRect(x * PIXEL_SIZE, y * PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE);
}

canvas.addEventListener("click", (event) => {
  const rect = canvas.getBoundingClientRect();
  const x = Math.floor((event.clientX - rect.left) / PIXEL_SIZE);
  const y = Math.floor((event.clientY - rect.top) / PIXEL_SIZE);

  if (x >= 0 && x < GRID_WIDTH && y >= 0 && y < GRID_HEIGHT) {
    sendPixelToServer(x, y, selectedColor);
  }
});

function sendPixelToServer(x, y, color) {
  fetch("/pixel", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ x, y, color }),
  });
}

function loadPixels() {
  fetch("/pixels")
    .then((response) => response.json())
    .then((pixels) => {
      Object.entries(pixels).forEach(([key, color]) => {
        const [x, y] = key.split(",").map(Number);
        drawPixel(x, y, color);
      });
    });
}

// WebSocket connection
const socket = new WebSocket("ws://" + window.location.host + "/ws");

socket.onmessage = function (event) {
  const pixel = JSON.parse(event.data);
  drawPixel(pixel.x, pixel.y, pixel.color);
};

socket.onopen = function () {
  console.log("WebSocket connection established");
};

socket.onerror = function (error) {
  console.error("WebSocket error:", error);
};

socket.onclose = function () {
  console.log("WebSocket connection closed");
};

// Ping to keep the connection alive
setInterval(() => {
  if (socket.readyState === WebSocket.OPEN) {
    socket.send("ping");
  }
}, 30000);

drawGrid();
loadPixels();
