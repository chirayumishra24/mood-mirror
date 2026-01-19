import os
os.environ["OPENCV_VIDEOIO_PRIORITY_MSMF"] = "0"

from flask import Flask, jsonify, Response
from flask_cors import CORS
import cv2
from deepface import DeepFace
from collections import deque
import threading, time, random, re

# ================= TEXT CLEANER =================
def clean_text(text):
    text = re.sub(r'([a-z])([A-Z])', r'\1 \2')
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

# ================= GROQ SETUP =================
try:
    from groq import Groq
    GROQ_API_KEY = os.getenv("GROQ_API_KEY")
    groq_client = Groq(api_key=GROQ_API_KEY) if GROQ_API_KEY else None
except:
    groq_client = None

def groq_joke(emotion):
    prompt = f"""
    You are a polite, family-friendly assistant.
    The person looks {emotion}.

    Create ONE short joke suitable for parents and elders.
    Language: Hinglish (Hindi + English).
    Tone: Calm, respectful, light humor.
    No sarcasm, no slang, no offensive words.

    Return ONLY the joke text.
    """
    try:
        r = groq_client.chat.completions.create(
            model="llama3-8b-8192",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.9,
            max_tokens=70
        )
        return clean_text(r.choices[0].message.content)
    except:
        return random.choice(JOKES)

# ================= FLASK APP =================
app = Flask(__name__)
CORS(app)

# ================= STATE =================
current_data = {
    "emotion": "Detecting...",
    "mood": "Unknown",
    "suggestion": "",
    "joke": "",
    "face_detected": False
}

emotion_history = deque(maxlen=4)
frame_count = 0
last_emotion = None

MOOD_MAP = {
    "happy": "Positive 😊",
    "neutral": "Calm 😐",
    "surprise": "Pleasantly Surprised 🙂",
    "sad": "Feeling Low 😢",
    "angry": "Feeling Stressed 😠",
    "fear": "Feeling Anxious 😨",
    "disgust": "Feeling Uncomfortable 😖"
}

NEGATIVE = ["sad", "angry", "fear", "disgust"]

# More descriptive, parent-friendly suggestions
SUGGESTIONS = {
    "sad": (
        "You seem a little low. It may help to take a slow breath, "
        "step outside for fresh air, or speak to someone you trust."
    ),
    "angry": (
        "It looks like there is some stress. Try pausing for a moment, "
        "relaxing your shoulders, and focusing on your breathing."
    ),
    "fear": (
        "You appear anxious. Gentle breathing and reminding yourself "
        "that you are safe right now can help calm the mind."
    ),
    "disgust": (
        "You seem uncomfortable. Taking a short break or having some "
        "water might help you feel better."
    )
}

# Safe fallback jokes
JOKES = [
    "Lagta hai thoda stress hai, par sab theek ho jayega 🙂",
    "Kabhi kabhi system slow hota hai, thoda patience kaam aata hai 😄",
    "Thodi si muskaan bhi din ko behtar bana deti hai 😊",
    "Chhoti si break kabhi kabhi kaafi madad karti hai 🌿"
]

# ================= CAMERA =================
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

# ================= VIDEO STREAM =================
def generate_frames():
    while True:
        ret, frame = cap.read()
        if not ret:
            continue
        frame = cv2.flip(cv2.resize(frame, (640, 480)), 1)
        _, buf = cv2.imencode(".jpg", frame)
        yield (
            b"--frame\r\n"
            b"Content-Type: image/jpeg\r\n\r\n" +
            buf.tobytes() + b"\r\n"
        )

# ================= EMOTION LOOP =================
def camera_loop():
    global frame_count, current_data, last_emotion

    while True:
        ret, frame = cap.read()
        if not ret:
            time.sleep(0.1)
            continue

        frame = cv2.flip(cv2.resize(frame, (640, 480)), 1)
        frame_count += 1

        if frame_count % 15 != 0:
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
                joke = groq_joke(stable) if groq_client else random.choice(JOKES)
                last_emotion = stable
            else:
                joke = current_data["joke"]

            current_data = {
                "emotion": stable,
                "mood": MOOD_MAP.get(stable, "Unknown"),
                "suggestion": SUGGESTIONS.get(stable, "") if stable in NEGATIVE else "",
                "joke": joke,
                "face_detected": True
            }

        except:
            current_data["emotion"] = "Detecting..."
            current_data["mood"] = "Unknown"
            current_data["suggestion"] = ""
            current_data["face_detected"] = False

        time.sleep(0.2)

# ================= API =================
@app.route("/mood")
def mood():
    return jsonify(current_data)

@app.route("/video")
def video():
    return Response(
        generate_frames(),
        mimetype="multipart/x-mixed-replace; boundary=frame"
    )

# ================= START =================
if __name__ == "__main__":
    threading.Thread(target=camera_loop, daemon=True).start()
    app.run(host="127.0.0.1", port=5000, debug=False, use_reloader=False)
