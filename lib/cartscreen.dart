import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/paymentscreen.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  const CartScreen({super.key, required this.selectedItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double total = 0.0;

  void calculateTotalPrice() {
    total = 0.0; // Reset total before recalculating

    for (var item in widget.selectedItems) {
      total += item["price"] * item["count"];
    }
  }

  void navigateToPaymentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    calculateTotalPrice();
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0, right: 70, left: 70, bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('My Cart'),
              SizedBox(
                width: 25,
              ),
              Icon(Icons.shopping_cart_outlined),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: ListView.builder(
                  itemCount: widget.selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.selectedItems[index];

                    return Card(
                      elevation: 12,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Distribute evenly
                          children: [
                            Container(
                                margin: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                    // color: Colors.pink,
                                    ),
                                child: Text('Qty: ${item["count"]}' , style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                            //Item Name
                            Container(
                              margin: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                  // color: Colors.green,
                                  ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    item["text"],
                                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Variant",
                                    style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            //Item Variant

                            //Price
                            Container(
                                margin: const EdgeInsets.only(
                                    top: 8, right: 10, bottom: 8),
                                decoration: const BoxDecoration(
                                    // x
                                    ),
                                child: Text('\$${item["price"]}', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold))),
                            //Checkout
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 70,
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Total :',
                          style: TextStyle(color: Colors.white)),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white),
                      ), // Display total with 2 decimal places
                      const SizedBox(
                        width: 15,
                      ),
                      const DottedLine(
                        direction: Axis.vertical,
                        alignment: WrapAlignment.center,
                        dashLength: 5,
                        lineLength: double.infinity,
                        lineThickness: 1.0,
                        dashColor: Colors.white,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 20.0, top: 8, bottom: 8),
                        child: Container(
                            color: Colors.black,
                            child: MaterialButton(
                              onPressed: navigateToPaymentScreen,
                              child: const Text(
                                'Checkout',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
