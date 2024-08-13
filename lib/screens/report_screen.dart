import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
import '../services/database_service.dart';
import '../models/budget_category.dart';
import '../models/transaction.dart' as trans;
import 'categoryDetailScreen.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/Indicator.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final DatabaseService _dbService = DatabaseService();
  DateTime _selectedMonth = DateTime.now();
  List<trans.Transaction> _transactions = [];
  List<BudgetCategory> _categories = [];
  String _selectedChart = 'PieChart';
  bool _isExpense = true;
  int _touchedIndex = -1; // 用於存儲被點擊的圖表部分的索引
  final List<Color> _categoryColors = [
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.red,
    Colors.cyan,
    Colors.yellow,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  // 加載報告數據
  Future<void> _loadReportData() async {
    print('--------------------------');
    print('資料: 開始載入報告數據');

    List<BudgetCategory> categories =
        await _dbService.getCategories(_isExpense);
    print('資料: 已載入 ${categories.length} 個類別');

    List<trans.Transaction> allTransactions = [];

    // 逐個類別地獲取交易數據
    for (BudgetCategory category in categories) {
      List<trans.Transaction> transactions = await _dbService
          .getTransactionsForCategoryAndMonth(category.name, _selectedMonth,
              forceRefresh: true);

      print('資料: 已載入 ${transactions.length} 筆 ${category.name} 的交易');
      allTransactions.addAll(transactions);
    }

    setState(() {
      _categories = categories;
      _transactions = allTransactions;
      _touchedIndex = -1; // 重置觸摸索引
    });

    print('資料: 報告數據載入完成');
    print('--------------------------');
  }

  // 顯示月份選擇器
  void _showMonthPicker(BuildContext context) async {
    final pickedMonth = await showMonthYearPicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedMonth != null && pickedMonth != _selectedMonth) {
      setState(() {
        _selectedMonth = pickedMonth;
      });
      _loadReportData();
    }
  }

  // 生成餅圖數據
  List<PieChartSectionData> _generatePieChartData() {
    print('--------------------------');
    print('資料: 開始生成餅圖數據');

    // 遍歷類別列表，將每個類別轉換為 PieChartSectionData 對象
    List<PieChartSectionData> pieData =
        _categories.asMap().entries.map((entry) {
      int index = entry.key; // 獲取當前類別的索引
      BudgetCategory category = entry.value; // 獲取當前類別對象

      // 計算該類別在選定月份內的總金額
      double total = _transactions
          .where(
              (t) => t.category == category.name && t.isExpense == _isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);

      print('資料: 類別 ${category.name} 的總額為 \$${total.toStringAsFixed(2)}');

      // 返回 PieChartSectionData 對象，用於餅圖的繪製
      return PieChartSectionData(
        value: total, // 設置該類別在餅圖中的值
        color: _categoryColors[index % _categoryColors.length], // 設置類別顏色
        radius: _touchedIndex == index ? 60.0 : 50.0, // 如果當前類別被點擊，增加其半徑以顯示突出效果
        title: '',
        showTitle: false, // 不顯示標題
      );
    }).toList(); // 將 map 結果轉換為列表

    print('資料: 餅圖數據生成完成');
    print('--------------------------');

    return pieData; // 返回生成的餅圖數據列表
  }

  // 生成柱狀圖數據
  List<BarChartGroupData> _generateBarChartData() {
    print('--------------------------');
    print('資料: 開始生成柱狀圖數據');
    List<BarChartGroupData> barData = _categories.asMap().entries.map((entry) {
      int index = entry.key;
      BudgetCategory category = entry.value;
      double total = _transactions
          .where(
              (t) => t.category == category.name && t.isExpense == _isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);
      print('資料: 類別 ${category.name} 的總額為 \$${total.toStringAsFixed(2)}');
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total,
            color: _categoryColors[index % _categoryColors.length],
            width: _touchedIndex == index ? 20.0 : 15.0,
            borderRadius: BorderRadius.circular(5),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: total * 1.1, // 略高於所有柱狀顯示的總高度
              color: Colors.grey[300],
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
    print('資料: 柱狀圖數據生成完成');
    print('--------------------------');
    return barData;
  }

  // 構建圖表和指示器
  Widget _buildPieChartWithIndicators() {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: _generatePieChartData(),
              )),
            ),
          ),
          // 添加類別指示器
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_categories.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Indicator(
                  color: _categoryColors[index % _categoryColors.length],
                  text: _categories[index].name,
                  isSquare: true,
                ),
              );
            }),
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  // 構建圖表
  Widget _buildChart() {
    if (_selectedChart == 'PieChart') {
      return _buildPieChartWithIndicators();
    } else if (_selectedChart == 'BarChart') {
      return BarChart(
        BarChartData(
          barGroups: _generateBarChartData(),
          alignment: BarChartAlignment.spaceEvenly,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  return Text(
                    _categories[index].name,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchCallback: (touchEvent, barTouchResponse) {
              setState(() {
                if (barTouchResponse != null && barTouchResponse.spot != null) {
                  _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                } else {
                  _touchedIndex = -1;
                }
              });
            },
          ),
        ),
      );
    } else {
      return Center(child: Text('請選擇一個圖表類型'));
    }
  }

  // 顯示被選中的類別及金額
  Widget _buildSelectedCategoryInfo() {
    if (_touchedIndex >= 0 && _touchedIndex < _categories.length) {
      BudgetCategory selectedCategory = _categories[_touchedIndex];
      double total = _transactions
          .where((t) =>
              t.category == selectedCategory.name && t.isExpense == _isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);
      return Text(
        '${selectedCategory.name} \$${total.toStringAsFixed(2)}',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
    } else {
      return Text(
        '請選擇一個類別',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
    }
  }

  // 構建報告項目列表
  Widget _buildCategoryList() {
    print('--------------------------');
    print('資料: 開始生成類別列表');
    return ListView.builder(
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        BudgetCategory category = _categories[index];
        double total = _transactions
            .where(
                (t) => t.category == category.name && t.isExpense == _isExpense)
            .fold(0.0, (sum, t) => sum + t.amount);
        print('資料: 類別 ${category.name} 的總額為 \$${total.toStringAsFixed(2)}');
        return ListTile(
          leading: Icon(category.icon),
          title: Text(category.name),
          trailing: Text('\$${total.toStringAsFixed(2)}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailScreen(
                  category: category.name,
                  month: _selectedMonth,
                  isExpense: _isExpense,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('報告'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _showMonthPicker(context), // 顯示月份選擇器
          ),
        ],
      ),
      body: Column(
        children: [
          // 圖表和支出收入切換器
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedChart = 'PieChart';
                    });
                  },
                  child: Text('餅圖'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedChart = 'BarChart';
                    });
                  },
                  child: Text('柱狀圖'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isExpense = true;
                      _loadReportData();
                    });
                  },
                  child: Text('支出'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isExpense = false;
                      _loadReportData();
                    });
                  },
                  child: Text('收入'),
                ),
              ],
            ),
          ),
          // 圖表顯示
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildChart(),
            ),
          ),
          // 選擇的項目顯示，文本加金額
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildSelectedCategoryInfo(),
            ),
          ),
          // 各類別總消費列表
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCategoryList(),
            ),
          ),
        ],
      ),
    );
  }
}
