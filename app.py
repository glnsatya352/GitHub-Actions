from flask import Flask, jsonify, request

app = Flask(__name__)

# In-memory storage (for demo)
tasks = [
    {"id": 1, "title": "Learn Flask", "done": True},
    {"id": 2, "title": "Build CI/CD Pipeline", "done": False},
]


@app.route("/")
def home():
    return jsonify({"message": "Welcome to Task Manager API"}), 200


@app.route("/tasks", methods=["GET"])
def get_tasks():
    return jsonify(tasks), 200


@app.route("/tasks", methods=["POST"])
def add_task():
    data = request.get_json(silent=True)

    title = data.get("title") if isinstance(data, dict) else None
    if not isinstance(title, str) or not title.strip():
        return jsonify({"error": "Title is required"}), 400

    new_task = {
        "id": len(tasks) + 1,
        "title": title.strip(),
        "done": False,
    }
    tasks.append(new_task)
    return jsonify(new_task), 201


if __name__ == "__main__":
    # No debug toggle here on purpose: debug=True is never reachable
    # in source, which satisfies Sonar's "debug mode in production"
    # hotspot. Use `flask --app app run --debug` locally if you need
    # the debugger; the container always runs via Gunicorn (see Dockerfile).
    app.run()