# ==============================
# WINDOWS + OPENCV FIX
# ==============================
import os
os.environ["OPENCV_VIDEOIO_PRIORITY_MSMF"] = "0"

# ==============================
# IMPORTS
# ==============================
from flask import Flask, jsonify, Response
from flask_cors import CORS
import cv2
from deepface import DeepFace
from collections import deque
import threading
import time
import random

# ==============================
# FLASK APP
# ==============================
app = Flask(__name__)
CORS(app)

# ==============================
# SHARED STATE
# ==============================
current_data = {
    "emotion": "Detecting...",
    "mood": "Unknown",
    "suggestion": "",
    "joke": ""
}

emotion_history = deque(maxlen=5)
frame_count = 0
last_emotion = None

MOOD_MAP = {
    "happy": "Positive 😊",
    "neutral": "Calm 😐",
    "surprise": "Excited 😲",
    "sad": "Low 😢",
    "angry": "Stressed 😠",
    "fear": "Anxious 😨",
    "disgust": "Uncomfortable 😖"
}

NEGATIVE = ["sad", "angry", "fear", "disgust"]

# ==============================
# SIMPLE SUGGESTIONS + JOKES
# ==============================

SUGGESTIONS = {
    "sad": "Take a deep breath and step outside for a minute 🌿",
    "angry": "Pause for 10 seconds and unclench your jaw 🧘",
    "fear": "Slow breathing helps — you’re safe right now 💙",
    "disgust": "Maybe a short break or some water would help 💧"
}

JOKES = [
    "Why don’t computers ever get tired? They take power naps ⚡😄",
    "I told my code a joke… it didn’t laugh, but it executed 😂",
    "Why was the laptop calm? It had good cache control 😎",
    "Even WiFi disconnects sometimes — it’s okay 😄"
]

# ==============================
# CAMERA DISCOVERY (WEBCAM + GLIDEX)
# ==============================

def get_camera():
    # Try DirectShow first (most stable on Windows)
    for idx in range(5):
        cap = cv2.VideoCapture(idx, cv2.CAP_DSHOW)
        if cap.isOpened():
            print(f"✅ Camera opened with DSHOW at index {idx}")
            return cap

    # Fallback
    for idx in range(5):
        cap = cv2.VideoCapture(idx, cv2.CAP_ANY)
        if cap.isOpened():
            print(f"✅ Camera opened with CAP_ANY at index {idx}")
            return cap

    return None


cap = get_camera()
if cap is None:
    print("❌ No webcam found (laptop or GlideX)")
    exit()

cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

# ==============================
# CAMERA FRAME GENERATOR (LIVE VIEW)
# ==============================

def generate_frames():
    while True:
        ret, frame = cap.read()
        if not ret:
            continue

        frame = cv2.resize(frame, (640, 480))
        frame = cv2.flip(frame, 1)

        _, buffer = cv2.imencode(".jpg", frame)
        frame_bytes = buffer.tobytes()

        yield (
            b"--frame\r\n"
            b"Content-Type: image/jpeg\r\n\r\n" +
            frame_bytes + b"\r\n"
        )

# ==============================
# CAMERA LOOP (EMOTION ANALYSIS)
# ==============================

def camera_loop():
    global frame_count, current_data, last_emotion

    while True:
        ret, frame = cap.read()
        if not ret:
            time.sleep(0.1)
            continue

        frame = cv2.resize(frame, (640, 480))
        frame = cv2.flip(frame, 1)

        frame_count += 1
        if frame_count % 15 != 0:
            time.sleep(0.05)
            continue

        try:
            result = DeepFace.analyze(
                frame,
                actions=["emotion"],
                enforce_detection=False
            )

            emotion = result[0]["dominant_emotion"]
            emotion_history.append(emotion)

            stable_emotion = max(
                set(emotion_history),
                key=emotion_history.count
            )

            # New person / emotion change → new joke
            if stable_emotion != last_emotion:
                joke = random.choice(JOKES)
                last_emotion = stable_emotion
            else:
                joke = current_data["joke"]

            current_data = {
                "emotion": stable_emotion,
                "mood": MOOD_MAP.get(stable_emotion, "Unknown"),
                "suggestion": (
                    SUGGESTIONS.get(stable_emotion, "")
                    if stable_emotion in NEGATIVE else ""
                ),
                "joke": joke
            }

        except:
            current_data = {
                "emotion": "No face detected",
                "mood": "Unknown",
                "suggestion": "",
                "joke": ""
            }

        time.sleep(0.2)

# ==============================
# API ENDPOINTS
# ==============================

@app.route("/mood")
def mood():
    return jsonify(current_data)

@app.route("/video")
def video():
    return Response(
        generate_frames(),
        mimetype="multipart/x-mixed-replace; boundary=frame"
    )

# ==============================
# START BACKEND
# ==============================

if __name__ == "__main__":
    threading.Thread(target=camera_loop, daemon=True).start()

    app.run(
        host="127.0.0.1",
        port=5000,
        debug=False,
        use_reloader=False
    )
