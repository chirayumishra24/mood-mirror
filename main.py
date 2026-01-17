import cv2
import random
import os
from collections import deque
from deepface import DeepFace

# ==============================
# OPTIONAL: GROQ AI SETUP
# ==============================

try:
    from groq import Groq
except ImportError:
    Groq = None

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
groq_client = None

if GROQ_API_KEY and Groq:
    try:
        groq_client = Groq(api_key=GROQ_API_KEY)
    except:
        groq_client = None

# ==============================
# CONFIGURATION
# ==============================

CAMERA_INDEX = 0
EMOTION_FRAME_INTERVAL = 15
EMOTION_SMOOTHING_WINDOW = 5

# ==============================
# EMOTION → MOOD MAP
# ==============================

MOOD_MAP = {
    "happy": "Positive 😊",
    "neutral": "Calm 😐",
    "surprise": "Excited 😲",
    "sad": "Low 😢",
    "angry": "Stressed 😠",
    "fear": "Anxious 😨",
    "disgust": "Uncomfortable 😖"
}

NEGATIVE_EMOTIONS = ["sad", "angry", "fear", "disgust"]

# ==============================
# FALLBACK SUGGESTION
# ==============================

def fallback_ai_suggestion(emotion):
    fallback = {
        "sad": "Looks heavy today. Breathe slowly 🌿 Even your coffee believes in you ☕🙂",
        "angry": "Strong energy detected. Pause for 10 seconds 🧘 Your keyboard is innocent 😅",
        "fear": "You seem tense. Slow breathing helps 🫁 Nothing is chasing you 😄",
        "disgust": "That face said ‘nope’. Take a short break ☕ Fair reaction 😆"
    }
    return fallback.get(emotion, "Stay calm 🙂")

# ==============================
# GROQ AI SUGGESTION
# ==============================

def ai_generated_suggestion(emotion):
    if groq_client is None or emotion not in NEGATIVE_EMOTIONS:
        return fallback_ai_suggestion(emotion)

    prompt = f"""
    You are an energetic, friendly, Gen-Z style wellbeing assistant.

    The person looks: {emotion}

    Instructions:
    - Match the emotional tone (sad = comforting, angry = playful-calm, fear = reassuring, disgust = humorous)
    - Be supportive but lively
    - Add ONE funny, harmless joke or witty line
    - Keep it non-medical and positive
    - 2–3 short sentences max
    - Sound human, not robotic

    Examples of humor style:
    - Light sarcasm
    - Friendly teasing
    - Relatable everyday jokes

    Now generate the response.
    """

    try:
        response = groq_client.chat.completions.create(
            model="llama3-8b-8192",
            messages=[
                {
                    "role": "system",
                    "content": "You cheer people up using humor, empathy, and positive energy."
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            temperature=0.9,   # 🔥 More creativity
            max_tokens=90
        )
        return response.choices[0].message.content.strip()

    except:
        return fallback_ai_suggestion(emotion)

# ==============================
# UI HELPER
# ==============================

def draw_text(frame, text, x, y, scale=0.7, color=(255,255,255), thickness=2):
    cv2.putText(frame, text, (x, y),
                cv2.FONT_HERSHEY_SIMPLEX,
                scale, color, thickness, cv2.LINE_AA)

# ==============================
# CAMERA & FACE DETECTOR
# ==============================

cap = cv2.VideoCapture(CAMERA_INDEX)
if not cap.isOpened():
    print("❌ Webcam not accessible")
    exit()

face_cascade = cv2.CascadeClassifier(
    cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
)

# ==============================
# STATE VARIABLES
# ==============================

frame_count = 0
current_emotion = "Detecting..."
emotion_history = deque(maxlen=EMOTION_SMOOTHING_WINDOW)
current_suggestion = ""

# ==============================
# MAIN LOOP
# ==============================

while True:
    ret, frame = cap.read()
    if not ret:
        continue

    frame = cv2.flip(frame, 1)
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    faces = face_cascade.detectMultiScale(
        gray, scaleFactor=1.1, minNeighbors=5, minSize=(80, 80)
    )

    if len(faces) > 0:
        # take largest face
        faces = sorted(faces, key=lambda x: x[2]*x[3], reverse=True)
        (x, y, w, h) = faces[0]

        cv2.rectangle(frame, (x,y), (x+w,y+h), (0,255,0), 2)
        face_img = frame[y:y+h, x:x+w]

        frame_count += 1

        if frame_count % EMOTION_FRAME_INTERVAL == 0:
            try:
                result = DeepFace.analyze(
                    face_img,
                    actions=["emotion"],
                    enforce_detection=False
                )
                detected_emotion = result[0]["dominant_emotion"]
                emotion_history.append(detected_emotion)

                current_emotion = max(
                    set(emotion_history),
                    key=emotion_history.count
                )

                current_suggestion = ai_generated_suggestion(current_emotion)

            except:
                current_emotion = "Detecting..."
                current_suggestion = ""
    else:
        current_emotion = "No face detected"
        current_suggestion = ""

    mood = MOOD_MAP.get(current_emotion, "Unknown")

    # ==============================
    # UI
    # ==============================

    draw_text(frame, "MOOD MIRROR", 20, 40, 1)
    draw_text(frame, f"Emotion: {current_emotion}", 20, 90, 0.8, (0,255,0))
    draw_text(frame, f"Mood: {mood}", 20, 130, 0.8, (255,255,0))

    if current_suggestion:
        draw_text(frame, f"Tip: {current_suggestion}", 20, 180, 0.6, (255,200,200))

    draw_text(frame,
              "Disclaimer: Not a medical diagnosis",
              20, frame.shape[0]-20, 0.5, (180,180,180), 1)

    cv2.imshow("Mood Mirror", frame)

    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

# ==============================
# CLEANUP
# ==============================

cap.release()
cv2.destroyAllWindows()
