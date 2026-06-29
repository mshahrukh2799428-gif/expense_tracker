from flask import Flask, request, jsonify
import json
import os
from datetime import datetime

app = Flask(__name__)

DATA_FILE = "expenses.json"

# ── Helper: Load & Save ──────────────────────────────────────────────────────

def load_expenses():
    if not os.path.exists(DATA_FILE):
        return []
    with open(DATA_FILE, "r") as f:
        return json.load(f)

def save_expenses(expenses):
    with open(DATA_FILE, "w") as f:
        json.dump(expenses, f, indent=4)


# ── Routes ───────────────────────────────────────────────────────────────────

# 1. Home
@app.route("/")
def home():
    return jsonify({"message": "Expense Tracker API is running!"})


# 2. Add a new expense
# POST /expenses
# Body: { "title": "Lunch", "amount": 500, "category": "Food" }
@app.route("/expenses", methods=["POST"])
def add_expense():
    data = request.get_json()

    # Validate required fields
    if not data or not data.get("title") or not data.get("amount") or not data.get("category"):
        return jsonify({"error": "title, amount, and category are required"}), 400

    expenses = load_expenses()

    new_expense = {
        "id": len(expenses) + 1,
        "title": data["title"],
        "amount": float(data["amount"]),
        "category": data["category"],
        "date": data.get("date", datetime.today().strftime("%Y-%m-%d"))
    }

    expenses.append(new_expense)
    save_expenses(expenses)

    return jsonify({"message": "Expense added!", "expense": new_expense}), 201


# 3. Get all expenses
# GET /expenses
@app.route("/expenses", methods=["GET"])
def get_expenses():
    expenses = load_expenses()
    return jsonify({"total_count": len(expenses), "expenses": expenses})


# 4. Get a single expense by ID
# GET /expenses/<id>
@app.route("/expenses/<int:expense_id>", methods=["GET"])
def get_expense(expense_id):
    expenses = load_expenses()
    expense = next((e for e in expenses if e["id"] == expense_id), None)

    if not expense:
        return jsonify({"error": "Expense not found"}), 404

    return jsonify(expense)


# 5. Delete an expense
# DELETE /expenses/<id>
@app.route("/expenses/<int:expense_id>", methods=["DELETE"])
def delete_expense(expense_id):
    expenses = load_expenses()
    updated = [e for e in expenses if e["id"] != expense_id]

    if len(updated) == len(expenses):
        return jsonify({"error": "Expense not found"}), 404

    save_expenses(updated)
    return jsonify({"message": f"Expense {expense_id} deleted."})


# 6. Get summary (total spent + breakdown by category)
# GET /summary
@app.route("/summary", methods=["GET"])
def get_summary():
    expenses = load_expenses()

    if not expenses:
        return jsonify({"message": "No expenses found.", "total": 0, "by_category": {}})

    total = sum(e["amount"] for e in expenses)

    by_category = {}
    for e in expenses:
        cat = e["category"]
        by_category[cat] = by_category.get(cat, 0) + e["amount"]

    return jsonify({
        "total_spent": round(total, 2),
        "by_category": by_category,
        "expense_count": len(expenses)
    })


# 7. Filter expenses by category
# GET /expenses/category/<category>
@app.route("/expenses/category/<string:category>", methods=["GET"])
def get_by_category(category):
    expenses = load_expenses()
    filtered = [e for e in expenses if e["category"].lower() == category.lower()]

    if not filtered:
        return jsonify({"message": f"No expenses found for category: {category}"}), 404

    total = sum(e["amount"] for e in filtered)
    return jsonify({"category": category, "total": round(total, 2), "expenses": filtered})


# ── Run ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app.run(debug=True)
