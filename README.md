# 💸 Expense Tracker — Flutter + Python Flask

A full-stack mobile app to track daily expenses, built with a **Flutter** frontend and a **Python Flask** REST API backend.

---

## 📱 Screenshots

> _Add your app screenshots here once you run it!_
> (Take a screenshot on your emulator/phone and drag it into this README on GitHub)

---

## ✨ Features

- ➕ Add expenses with title, amount, and category
- 📋 View all expenses in a clean card list
- 🗑️ Delete any expense with one tap
- 📊 Summary screen with total spending and category breakdown
- 🎨 6 categories: Food, Transport, Shopping, Health, Entertainment, Other
- 🔗 Flutter app connects to Python backend via REST API

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter (Dart) |
| Backend API | Python, Flask |
| Data Storage | JSON file |
| API Communication | HTTP REST |

---

## 📂 Project Structure

```
expense-tracker/
│
├── expense_tracker.py   # Python Flask backend (REST API)
├── main.dart            # Flutter frontend (all screens)
└── README.md
```

---

## 🚀 Getting Started

### 1. Run the Python Backend

Make sure Python is installed, then:

```bash
pip install flask
python expense_tracker.py
```

The server will start at `http://localhost:5000`

---

### 2. Run the Flutter App

Make sure Flutter is installed, then add the `http` package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
```

Then run:

```bash
flutter pub get
flutter run
```

> **Note:** If running on a real phone (not emulator), open `main.dart` and change `10.0.2.2` to your computer's local IP address (e.g. `192.168.1.5`).

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Check if API is running |
| GET | `/expenses` | Get all expenses |
| POST | `/expenses` | Add a new expense |
| GET | `/expenses/<id>` | Get a single expense |
| DELETE | `/expenses/<id>` | Delete an expense |
| GET | `/summary` | Total spent + category breakdown |
| GET | `/expenses/category/<name>` | Filter by category |

### Example Request — Add Expense

```json
POST /expenses
Content-Type: application/json

{
  "title": "Lunch",
  "amount": 500,
  "category": "Food"
}
```

### Example Response

```json
{
  "message": "Expense added!",
  "expense": {
    "id": 1,
    "title": "Lunch",
    "amount": 500.0,
    "category": "Food",
    "date": "2026-06-29"
  }
}
```

---

## 👩‍💻 Author

**Alveena Hanif**
Software Engineering Undergraduate — Newport Institute of Communications and Economics, Karachi
📧 m.shahrukh2799428@gmail.com

---

## 📌 Status

🚧 In progress — more features coming soon (user login, charts, cloud storage)
