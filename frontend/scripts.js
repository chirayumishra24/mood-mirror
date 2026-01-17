let lastEmotion = "";

async function updateMood() {
  const res = await fetch("http://127.0.0.1:5000/mood");
  const data = await res.json();

  document.getElementById("emotion").innerText = data.emotion;
  document.getElementById("mood").innerText = data.mood;

  // Show suggestion only if mood is negative
  if (["sad", "angry", "fear"].includes(data.emotion)) {
    document.getElementById("suggestion").innerText = data.suggestion || data.message;
  } else {
    document.getElementById("suggestion").innerText = "All good 🙂";
  }

  // Refresh joke ONLY if emotion changed (new person)
  if (data.emotion !== lastEmotion) {
    document.getElementById("joke").innerText = data.joke || "😄";
    lastEmotion = data.emotion;
  }
}

setInterval(updateMood, 2000);
