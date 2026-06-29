import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ExpenseTrackerApp());
}

// ── App Root ─────────────────────────────────────────────────────────────────

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A7A7A)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// ── API Service ───────────────────────────────────────────────────────────────
// Change this to your computer's local IP if testing on a real phone
// e.g. 'http://192.168.1.5:5000'
const String baseUrl = 'http://10.0.2.2:5000'; // 10.0.2.2 = localhost for Android emulator

class ApiService {
  // Fetch all expenses
  static Future<List<dynamic>> getExpenses() async {
    final res = await http.get(Uri.parse('$baseUrl/expenses'));
    final data = jsonDecode(res.body);
    return data['expenses'];
  }

  // Add a new expense
  static Future<bool> addExpense(String title, double amount, String category) async {
    final res = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'amount': amount, 'category': category}),
    );
    return res.statusCode == 201;
  }

  // Delete an expense
  static Future<bool> deleteExpense(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/expenses/$id'));
    return res.statusCode == 200;
  }

  // Get summary
  static Future<Map<String, dynamic>> getSummary() async {
    final res = await http.get(Uri.parse('$baseUrl/summary'));
    return jsonDecode(res.body);
  }
}

// ── Home Screen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ExpenseListScreen(),
    SummaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Summary'),
        ],
      ),
    );
  }
}

// ── Expense List Screen ───────────────────────────────────────────────────────

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<dynamic> _expenses = [];
  bool _loading = true;

  // Category icons map
  final Map<String, IconData> _categoryIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Health': Icons.local_hospital,
    'Entertainment': Icons.movie,
    'Other': Icons.category,
  };

  final Map<String, Color> _categoryColors = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Shopping': Colors.pink,
    'Health': Colors.red,
    'Entertainment': Colors.purple,
    'Other': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _loading = true);
    try {
      final expenses = await ApiService.getExpenses();
      setState(() {
        _expenses = expenses;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError('Could not connect to server. Is Python running?');
    }
  }

  Future<void> _deleteExpense(int id) async {
    final success = await ApiService.deleteExpense(id);
    if (success) {
      _loadExpenses();
    } else {
      _showError('Failed to delete expense.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A7A7A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadExpenses),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No expenses yet!', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    final e = _expenses[index];
                    final category = e['category'] ?? 'Other';
                    final icon = _categoryIcons[category] ?? Icons.category;
                    final color = _categoryColors[category] ?? Colors.grey;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(icon, color: color),
                        ),
                        title: Text(e['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${e['category']}  •  ${e['date']}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'PKR ${e['amount'].toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1A7A7A)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteExpense(e['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          if (added == true) _loadExpenses();
        },
        backgroundColor: const Color(0xFF1A7A7A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

// ── Add Expense Screen ────────────────────────────────────────────────────────

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  bool _saving = false;

  final List<String> _categories = [
    'Food', 'Transport', 'Shopping', 'Health', 'Entertainment', 'Other'
  ];

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid title and amount.')),
      );
      return;
    }

    setState(() => _saving = true);
    final success = await ApiService.addExpense(title, amount, _selectedCategory);
    setState(() => _saving = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add expense.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A7A7A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            const Text('Title', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Lunch, Uber, Groceries',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Amount field
            const Text('Amount (PKR)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 500',
                prefixText: 'PKR  ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Category dropdown
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A7A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Screen ────────────────────────────────────────────────────────────

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Map<String, dynamic>? _summary;
  bool _loading = true;

  final Map<String, Color> _categoryColors = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Shopping': Colors.pink,
    'Health': Colors.red,
    'Entertainment': Colors.purple,
    'Other': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _loading = true);
    try {
      final summary = await ApiService.getSummary();
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Summary', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A7A7A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSummary),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
              ? const Center(child: Text('Failed to load summary.'))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A7A7A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text('Total Spent',
                                style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(
                              'PKR ${(_summary!['total_spent'] ?? 0).toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_summary!['expense_count'] ?? 0} expenses recorded',
                              style: const TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text('By Category',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),

                      // Category breakdown
                      ...(_summary!['by_category'] as Map<String, dynamic>? ?? {})
                          .entries
                          .map((entry) {
                        final color = _categoryColors[entry.key] ?? Colors.grey;
                        final total = (_summary!['total_spent'] ?? 1) as num;
                        final amount = (entry.value as num).toDouble();
                        final percent = total > 0 ? (amount / total) : 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 8,
                                        backgroundColor: color,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(entry.key,
                                          style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  Text(
                                    'PKR ${amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, color: color),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percent.toDouble(),
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(color),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
