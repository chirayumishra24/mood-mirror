import os
os.environ["OPENCV_VIDEOIO_PRIORITY_MSMF"] = "0"

from flask import Flask, jsonify, Response
from flask_cors import CORS
import cv2
from deepface import DeepFace
from collections import deque
import threading, time, random

app = Flask(__name__)
CORS(app)

# ---- State ----
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

SUGGESTIONS = {
    "sad": "Take a deep breath and step outside 🌿",
    "angry": "Pause for 10 seconds and relax 🧘",
    "fear": "Slow breathing helps — you’re safe 💙",
    "disgust": "A short break or water may help 💧"
}

JOKES = [
    "Why don’t computers get tired? Power naps ⚡😄",
    "My code laughed… then crashed 😂",
    "Laptop stayed calm — good cache control 😎",
    "Even WiFi disconnects sometimes 😄"
]

# ---- Camera ----
def get_camera():
    for i in range(5):
        cam = cv2.VideoCapture(i, cv2.CAP_DSHOW)
        if cam.isOpened():
            print(f"✅ Camera opened (DSHOW {i})")
            return cam
    for i in range(5):
        cam = cv2.VideoCapture(i)
        if cam.isOpened():
            print(f"✅ Camera opened (AUTO {i})")
            return cam
    return None

cap = get_camera()
if cap is None:
    print("❌ No camera found")
    exit()

cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

# ---- Video stream ----
def generate_frames():
    while True:
        ret, frame = cap.read()
        if not ret:
            continue
        frame = cv2.flip(cv2.resize(frame, (640, 480)), 1)
        _, buf = cv2.imencode(".jpg", frame)
        yield b"--frame\r\nContent-Type: image/jpeg\r\n\r\n" + buf.tobytes() + b"\r\n"

# ---- Emotion loop ----
def camera_loop():
    global frame_count, current_data, last_emotion

    while True:
        ret, frame = cap.read()
        if not ret:
            time.sleep(0.1)
            continue

        frame = cv2.flip(cv2.resize(frame, (640, 480)), 1)
        frame_count += 1

        if frame_count % 10 != 0:
            time.sleep(0.03)
            continue

        try:
            small = cv2.resize(frame, (320, 240))
            result = DeepFace.analyze(
                small,
                actions=["emotion"],
                enforce_detection=False
            )

            emotions = result[0]["emotion"]
            emotion, confidence = max(emotions.items(), key=lambda x: x[1])
            if confidence < 50:
                raise Exception

            emotion_history.append(emotion)
            stable = max(set(emotion_history), key=emotion_history.count)

            if stable != last_emotion:
                joke = random.choice(JOKES)
                last_emotion = stable
            else:
                joke = current_data["joke"]

            current_data = {
                "emotion": stable,
                "mood": MOOD_MAP.get(stable, "Unknown"),
                "suggestion": SUGGESTIONS.get(stable, "") if stable in NEGATIVE else "",
                "joke": joke
            }

        except:
            current_data["emotion"] = "Detecting..."
            current_data["mood"] = "Unknown"
            current_data["suggestion"] = ""

        time.sleep(0.2)

# ---- API ----
@app.route("/mood")
def mood():
    return jsonify(current_data)

@app.route("/video")
def video():
    return Response(generate_frames(),
        mimetype="multipart/x-mixed-replace; boundary=frame")

# ---- Start ----
if __name__ == "__main__":
    threading.Thread(target=camera_loop, daemon=True).start()
    app.run(host="127.0.0.1", port=5000, debug=False, use_reloader=False)
