<h1 align="center">  𝔸𝕀  ℙℍ𝕆𝕋𝕆  𝔼𝔻𝕀𝕋𝕆ℝ </h1>


<p align="center">
  <img width="600" height="550" alt="hero_banner" src="https://github.com/user-attachments/assets/d9c12b41-e19e-4d0d-a12d-ae9a1b0b40f1" />

</p>


![Static Badge](https://img.shields.io/badge/Project-AI_Photo_Editor-purple?style=for-the-badge)
![Static Badge](https://img.shields.io/badge/Language-JavaScript-yellow?style=for-the-badge)
![Static Badge](https://img.shields.io/badge/Frontend-HTML-orange?style=for-the-badge)
![Static Badge](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

AI Photo Editor is a lightweight yet powerful browser-based image editing tool enhanced with AI features. It lets you apply filters, adjust brightness/contrast, crop, resize, and run AI operations like enhancement or style-based effects — all inside a clean UI.

---

## ✨ Features
- 🎨 Image filters (grayscale, blur, sharpen, etc.)
- 🔧 Editing tools (resize, rotate, crop)
- 🌈 Color adjustments (brightness, contrast, saturation)
- 🤖 AI-powered features (enhance, style effects, auto-correct)
- 🧩 Modular, extendable JavaScript code
- 🖼 Simple drag-and-drop interface
- 📦 Fully client-side (no backend required)
- 📝 MIT Licensed

---

## 🚀 Getting Started

### Clone the repository
```bash
git clone https://github.com/shloook/AI-Photo-Editor.git
cd AI-Photo-Editor
```

### Run the project  
Open:
```
index.html
```
Works instantly in any modern browser.

---

## 📂 Project Structure
```
AI-Photo-Editor/
├── index.html        # Main UI
├── style.css         # Editor styling
├── script.js         # Core editing logic
├── ai.js             # AI enhancement & filters
├── assets/           # Icons, UI images
├── LICENSE           # MIT License
└── README.md         # Documentation
```

---

## 🖥 HTML Layout (index.html)
```html
<div class="editor-container">
    <h1>AI Photo Editor</h1>

    <input type="file" id="imageInput" accept="image/*">

    <canvas id="photoCanvas"></canvas>

    <div class="tools">
        <button onclick="applyFilter('grayscale')">Grayscale</button>
        <button onclick="applyFilter('blur')">Blur</button>
        <button onclick="applyFilter('sharpen')">Sharpen</button>
        <button onclick="enhanceAI()">AI Enhance</button>
    </div>
</div>
```

---

## 🎨 Styling (style.css)
```css
body {
    background: #f8f8f8;
    font-family: Arial, sans-serif;
    display: flex;
    justify-content: center;
    padding: 30px;
}

.editor-container {
    width: 80%;
    background: #fff;
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 3px 12px rgba(0,0,0,0.1);
}

canvas {
    width: 100%;
    max-height: 500px;
    border-radius: 10px;
    margin-top: 15px;
}

.tools button {
    padding: 10px 20px;
    margin: 10px 5px;
    border-radius: 6px;
    border: none;
    cursor: pointer;
}
```

---

## 🧰 Editor Logic (script.js)
```javascript
const canvas = document.getElementById("photoCanvas");
const ctx = canvas.getContext("2d");
let image = new Image();

document.getElementById("imageInput").addEventListener("change", (e) => {
    const file = e.target.files[0];
    image.src = URL.createObjectURL(file);

    image.onload = () => {
        canvas.width = image.width;
        canvas.height = image.height;
        ctx.drawImage(image, 0, 0);
    };
});

function applyFilter(type) {
    const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    // Example: grayscale
    if (type === "grayscale") {
        for (let i = 0; i < imgData.data.length; i += 4) {
            let avg = (imgData.data[i] + imgData.data[i+1] + imgData.data[i+2]) / 3;
            imgData.data[i] = imgData.data[i+1] = imgData.data[i+2] = avg;
        }
    }
    ctx.putImageData(imgData, 0, 0);
}
```

---

## 🤖 AI Feature Example (ai.js)
```javascript
function enhanceAI() {
    const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);

    // Simple enhancement mock — you can replace with real ML/TF.js logic
    for (let i = 0; i < imgData.data.length; i += 4) {
        imgData.data[i]     = Math.min(255, imgData.data[i] * 1.1); // R
        imgData.data[i + 1] = Math.min(255, imgData.data[i + 1] * 1.1); // G
        imgData.data[i + 2] = Math.min(255, imgData.data[i + 2] * 1.1); // B
    }

    ctx.putImageData(imgData, 0, 0);
}
```

---

## 🧪 Optional Backend API (if extended)

### Upload Image
```
POST /api/upload
Content-Type: multipart/form-data
```

### AI Enhance API
```
POST /api/ai/enhance
Content-Type: application/json

{ "image": "<base64>" }
```

### Response Example
```json
{
  "enhanced": "<base64-image>"
}
```

---

## 🤝 Contributing
1. Fork the repository  
2. Create a new branch  
3. Commit improvements  
4. Open a pull request  

---

## 📄 License
MIT License.

---

## ⭐ Acknowledgements
Inspired by modern photo editors and browser-based AI tools.  
Built for simplicity, creativity, and fast experimentation.
