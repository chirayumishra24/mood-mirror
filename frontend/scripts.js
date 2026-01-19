let lastEmotion = "";
let typingInterval = null;

const body = document.body;
const jokeEl = document.getElementById("joke");
const faceIndicator = document.getElementById("face-indicator");
const fullscreenBtn = document.getElementById("fullscreen-btn");
const cameraBox = document.querySelector(".camera");

function typeText(element, text) {
  clearInterval(typingInterval);
  element.innerText = "";
  let i = 0;

  typingInterval = setInterval(() => {
    if (i < text.length) {
      element.innerText += text[i++];
    } else {
      clearInterval(typingInterval);
    }
  }, 35);
}

async function updateUI() {
  try {
    const res = await fetch("http://127.0.0.1:5000/mood");
    const data = await res.json();

    document.getElementById("emotion").innerText = data.emotion;
    document.getElementById("mood").innerText = data.mood;

    /* ---- Face detection indicator + robotic scan ---- */
    if (data.face_detected) {
      faceIndicator.innerText = "Face Detected";
      faceIndicator.className = "face detected";
      cameraBox.classList.add("scan-active");
    } else {
      faceIndicator.innerText = "No Face";
      faceIndicator.className = "face no-face";
      cameraBox.classList.remove("scan-active");
    }

    /* ---- Emotion-based theme ---- */
    body.className = "";
    body.classList.add(data.emotion || "neutral");

    /* ---- Confidence bar (UX only) ---- */
    const confidence =
      data.emotion === "happy" ? 85 :
      data.emotion === "neutral" ? 70 :
      65;

    document.getElementById("confidence-bar").style.width =
      confidence + "%";

    /* ---- Suggestions ---- */
    const suggestionBox = document.getElementById("suggestion-box");
    if (data.suggestion) {
      suggestionBox.style.display = "block";
      document.getElementById("suggestion").innerText = data.suggestion;
    } else {
      suggestionBox.style.display = "none";
    }

    /* ---- Joke typing animation (only on emotion change) ---- */
    if (data.emotion !== lastEmotion && data.joke) {
      typeText(jokeEl, data.joke);
      lastEmotion = data.emotion;
    }

  } catch (err) {
    console.error("UI update failed:", err);
  }
}

/* ---- Fullscreen (kiosk mode) ---- */
fullscreenBtn.onclick = () => {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen();
  } else {
    document.exitFullscreen();
  }
};

/* ---- Poll backend every 2 seconds ---- */
setInterval(updateUI, 2000);
