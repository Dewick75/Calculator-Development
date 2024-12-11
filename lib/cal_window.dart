// IM/2021/079 - pasindu Wickramasinghe

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userInput = "";
  String result = "0";
  bool isResultDisplayed = false;
  List<String> history = [];
  String errorMessage = "";
  int openBrackets = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(                       //App Bar
          title: const Text("IM-2021-079"),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(
                      history: history,
                      onClearHistory: clearHistory,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(                                //Body
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3.5,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (userInput.isNotEmpty) {
                              userInput =
                                  userInput.substring(0, userInput.length - 1);
                              result = userInput.isNotEmpty ? calculate() : "0";
                              if (userInput.endsWith('(')) {
                                openBrackets--;
                              } else if (userInput.endsWith(')')) {
                                openBrackets++;
                              }
                            }
                          });
                        },
                        child: const Icon(
                          Icons.backspace,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      userInput,
                      style: const TextStyle(fontSize: 32),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (errorMessage.isNotEmpty)
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  if (result != "0" && errorMessage.isEmpty)
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        result,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                color: const Color.fromARGB(66, 233, 232, 232),
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: buttonList.map((text) {
                    return button(text);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> buttonList = [
    "%",
    "√",
    "()",
    "/",
    "7",
    "8",
    "9",
    "*",
    "4",
    "5",
    "6",
    "+",
    "1",
    "2",
    "3",
    "-",
    "AC",
    "0",
    ".",
    "="
  ];

  Widget button(String text) {
    return InkWell(
      onTap: () {
        setState(() {
          handleButtonPress(text);
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: getBgColor(text),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28,
              color: getColor(text),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color getColor(String text) {
    if (text == "()") return Colors.red;
    if ("+-*/=%√=".contains(text) || text == "AC") return Colors.white;
    return Colors.indigo;
  }

  Color getBgColor(String text) {
    if (text == "AC") return Colors.red;
    if ("+-*/=%√=".contains(text)) return Colors.orange;
    return Colors.white;
  }

  void handleButtonPress(String text) {           //Handle button process
    if (text == "AC") {                      //AC
      userInput = "";
      result = "0";
      errorMessage = "";
      isResultDisplayed = false;
      openBrackets = 0;
    } else if (text == "=") {
      if (userInput.isNotEmpty) {
        String tempResult = calculate();
        if (tempResult == "Error" ||
            tempResult == "NaN" ||
            tempResult == "Can't divide by zero") {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Error"),
              content: const Text("Can't divide by zero"),   //devide 0
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );

          userInput = "";
          result = "0";
          errorMessage = "Can't divide by zero";
        } else {
          result = tempResult;
          history.add("$userInput = $result");
          isResultDisplayed = true;
          userInput = "";
          openBrackets = 0;
        }
      }
    } else if (text == "√") {
      if (userInput.isNotEmpty) {
        userInput = "sqrt($userInput)";
        result = calculate();
        isResultDisplayed = true;
      }
    } else if (text == "%") {
      if (userInput.isNotEmpty) {
        userInput += "/100";
        result = calculate();
        isResultDisplayed = true;
      }
    } else if (text == "()") {          //+-/*
      if (openBrackets == 0 &&
          (userInput.isEmpty ||
              "+-*/".contains(userInput[userInput.length - 1]))) {
        userInput += "(";
        openBrackets++;
      } else if (openBrackets > 0 &&
          !"(".contains(userInput[userInput.length - 1])) {
        userInput += ")";
        openBrackets--;
      }
    } else {
      if (isResultDisplayed || errorMessage.isNotEmpty) {
        if (RegExp(r'[0-9]').hasMatch(text)) {
          userInput = "";
          result = "0";
          errorMessage = "";
          isResultDisplayed = false;
        }
      }

      if (userInput.isEmpty) {
        if ("*/.".contains(text)) return;
      } else {
        if (RegExp(r'[+\-*/.]').hasMatch(userInput[userInput.length - 1]) &&
            RegExp(r'[+\-*/.]').hasMatch(text)) return;
        if (userInput.endsWith(".") && text == ".") return;
         // Prevent multiple decimals in the same number
        if (text == "." && userInput.split(RegExp(r'[+\-*/()]')).last.contains(".")) {
          return;
        }

      }

      if (text == "0" && userInput.isNotEmpty) {
        if (userInput == "0" || userInput.endsWith("00")) return;
        if (userInput.endsWith(".")) {
          userInput += text;
        } else {
          final lastNumber = userInput.split(RegExp(r'[+\-*/]')).last;
          if (!lastNumber.contains(".") && lastNumber == "0") return;
          userInput += text;
        }
      } else {
        userInput += text;
      }

      errorMessage = "";
      if (!"+-*/".contains(userInput[userInput.length - 1])) {
        result = calculate();
      }
    }
  }


  String calculate() {                                                           //Calculate
    try {
      final expression = Parser().parse(userInput);
      final evaluation =
          expression.evaluate(EvaluationType.REAL, ContextModel());               //Do the calculation
      if (evaluation.isNaN || evaluation.isInfinite) {
        return "Error";
      }

      String resultString = evaluation.toString();

      if (resultString.contains('.')) {
        resultString = resultString.replaceAll(RegExp(r'0*$'), '');
        resultString = resultString.replaceAll(RegExp(r'\.$'), '');
      }

      return resultString;
    } catch (e) {
      return "Error";
    }
  }

  void clearHistory() {
    setState(() {
      history.clear();
    });
  }
}

class HistoryScreen extends StatefulWidget {
  final List<String> history;
  final VoidCallback onClearHistory;

  const HistoryScreen(
      {super.key, required this.history, required this.onClearHistory});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: widget.onClearHistory,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.history.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.history[index]),
          );
        },
      ),
    );
  }
}
