import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExchangeRate extends StatefulWidget {
  const ExchangeRate({super.key});

  @override
  State<ExchangeRate> createState() => _ExchangeRateState();
}

class _ExchangeRateState extends State<ExchangeRate> {
  String _baseCurrency = 'USD';
  String _targetCurrency = 'EUR';
  double? _exchangeRate;
  double _amount = 0;

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'AUD'];
  final TextEditingController _amountController = TextEditingController();

  Future<void> fetchExchangeRate() async {
    final url = Uri.parse(
        "https://v6.exchangerate-api.com/v6/879eb27700d07554b810b0f6/latest/$_baseCurrency");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _exchangeRate = data['conversion_rates'][_targetCurrency];
        });
      } else {
        throw Exception('Failed to fetch exchange rate');
      }
    } catch (error) {
      print('Error fetching exchange rate: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchExchangeRate();
  }

  double? convertCurrency(double amount) {
    if (_exchangeRate != null) {
      return amount * _exchangeRate!;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 97, 158, 169),
      appBar: AppBar(
        title: const Text(
          "EXCHANGE RATE APP",
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Change this to your desired color
          ),
        ),
        backgroundColor: Color.fromARGB(255, 4, 82, 91),
        centerTitle: true,
        toolbarHeight: 100, // Increase the height of the AppBar (default is 56)
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<String>(
                    value: _baseCurrency,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _baseCurrency = value!;
                        fetchExchangeRate();
                      });
                    },
                  ),
                  const Icon(Icons.arrow_forward),
                  DropdownButton<String>(
                    value: _targetCurrency,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _targetCurrency = value!;
                        fetchExchangeRate();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Enter amount in $_baseCurrency',
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Parse the input amount and convert
                  _amount = double.tryParse(_amountController.text) ?? 0;
                });
              },
              child: const Text(
                'Convert',
                style: TextStyle(color: Color.fromARGB(255, 249, 249, 248)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 3, 46, 93),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_exchangeRate != null && _amount > 0)
              Text(
                '$_amount $_baseCurrency = ${convertCurrency(_amount)?.toStringAsFixed(2)} $_targetCurrency',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
