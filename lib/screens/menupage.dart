import 'dart:async';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_application_1/database/database.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/global/common/toast.dart';
import 'package:flutter_application_1/providers/categoryprovider.dart'
    as category_provider;
import 'package:flutter_application_1/providers/themeprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/loginwidget/auth_service.dart';

// Import the CartScreen
import 'package:flutter_application_1/screens/cartscreen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.isFinished});
  final bool isFinished;

  @override
  // ignore: library_private_types_in_public_api
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  final ValueNotifier<int?> selectedCategoryId = ValueNotifier<int?>(null);
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Item> _searchResults = [];
  List<SelectedItems> selectedItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addObserver(this);
    _fetchSelectedItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      AuthService().signout();
    }
  }

  void _fetchSelectedItems() async {
    final dbService = DatabaseService.instance;
    final items = await dbService.fetchSelectedItems();
    setState(() {
      selectedItems = items;
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      if (_searchController.text.isNotEmpty) {
        _lazySearch(_searchController.text);
      } else {
        setState(() {
          _searchResults.clear();
        });
      }
    });
  }

  Future<void> _lazySearch(String query) async {
    final categoryProvider = context.read<category_provider.CategoryProvider>();
    final items = await categoryProvider.fetchItemsByName(query);

    setState(() {
      _searchResults = items;
    });
  }

  // Inside your existing MenuScreen widget

//OTHER CODE
void _incrementItemCount(SelectedItems item) async {
  final dbService = DatabaseService.instance;
  final isCountGreaterThanZero = await dbService.isItemCountGreaterThanZero(item.id!);

  if (isCountGreaterThanZero) {
    setState(() {
      final selectedItem = selectedItems.firstWhere(
        (selectedItem) => selectedItem.name == item.name,
        orElse: () {
          final newItem = SelectedItems(
            id: item.id,
            name: item.name,
            price: item.price,
            imagePath: item.imagePath,
            count: item.count,
            max: item.max, // Initialize max with item's max value
          );
          selectedItems.add(newItem);
          return newItem;
        },
      );

      if (selectedItem.max < item.count) { // Check if max is less than item's count
       
        selectedItem.max += 1; // Increment max value dynamically
      } else {
        showToast(message: 'Item has reached its maximum count.');
      }
    });
  } else {
    showToast(message: 'Item is out of stock.');
  }
}



void _decrementItemCount(SelectedItems item) async {
  final dbService = DatabaseService.instance;
  final isCountGreaterThanZero =
      await dbService.isItemCountGreaterThanZero(item.id!);

  if (isCountGreaterThanZero) {
    setState(() {
      final selectedItem = selectedItems.firstWhere(
        (selectedItem) => selectedItem.name == item.name,
        orElse: () {
          final newItem = SelectedItems(
            id: item.id,
            name: item.name,
            price: item.price,
            imagePath: item.imagePath,
            count: 0,
            max: item.max,
          );
          return newItem;
        },
      );

      if (selectedItem.count > 0) {
        selectedItem.count -= 1;
        selectedItem.max -= 1; // Decrement max value dynamically

        if (selectedItem.count == 0) {
          selectedItems.removeWhere((element) => element.name == item.name);
        }
      }
    });
  } else {
    showToast(message: 'Item is out of stock.');
  }
}

  int _getTotalItemCount() {
    return selectedItems.fold(0, (total, item) => total + item.max);
  }

  double _getTotalPrice() {
    return selectedItems.fold(
        0.0, (total, item) => total + (item.price * item.max));
  }

  void _navigateToCartScreen() {
    if (selectedItems.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartScreen(selectedItems: selectedItems),
        ),
      );
    } else {
      showToast(message: 'No items to checkout');
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context, listen: false);
    final categoryProvider = context.read<category_provider.CategoryProvider>();
    Future<List<category_provider.Category>> categoryList =
        categoryProvider.fetchCategory();

    return Scaffold(
      body: FutureBuilder<List<category_provider.Category>>(
        future: categoryList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories available'));
          } else {
            if (selectedCategoryId.value == null &&
                snapshot.hasData &&
                snapshot.data!.isNotEmpty) {
              selectedCategoryId.value = snapshot.data!.first.id;
            }

            return Column(
              children: [
                // Search Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: TextField(
                    style: Theme.of(context).textTheme.displaySmall,
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for items',
                      hintStyle: Theme.of(context).textTheme.displaySmall,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                if (_searchResults.isNotEmpty)
                  Expanded(
                    child: ListView(
                      children: _searchResults.map((item) {
                        return Padding(
                          padding:  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Card(
                            child: ListTile(
                              title: Text(item.name),
                              subtitle:
                                  Text('\$${item.price.toStringAsFixed(2)}'),
                              leading: item.imagePath.isNotEmpty
                                  ? Image.network(item.imagePath)
                                  : null,
                              onTap: () {
                                selectedCategoryId.value = item.id;
                                _searchController.clear();
                                _searchResults.clear();
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                else
                  Expanded(
                    child: ValueListenableBuilder<int?>(
                      valueListenable: selectedCategoryId,
                      builder: (context, selectedId, _) {
                        if (selectedId == null) {
                          return const Center(
                              child: Text('Select a category to view items'));
                        }

                        Future<List<Item>> itemList =
                            categoryProvider.fetchItemByCategoryId(selectedId);

                        return FutureBuilder<List<Item>>(
                          future: itemList,
                          builder: (context, itemSnapshot) {
                            if (itemSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (itemSnapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${itemSnapshot.error}'));
                            } else if (!itemSnapshot.hasData ||
                                itemSnapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('No items available'));
                            } else {
                              return ListView(
                                controller: _scrollController,
                                children: itemSnapshot.data!.map((item) {
                                  final selectedItem = selectedItems.firstWhere(
                                    (selectedItem) =>
                                        selectedItem.name == item.name,
                                    orElse: () => SelectedItems(
                                      id: item.id,
                                      name: item.name,
                                      price: item.price,
                                      imagePath: item.imagePath,
                                      count: 0,
                                      max: item.max,
                                    ),
                                  );

                                  return Padding(
                                    padding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    child: Card(
                                      child: ListTile(
                                        title: Text(item.name),
                                        subtitle: Text(
                                            '\$${item.price.toStringAsFixed(2)}'),
                                        leading: item.imagePath.isNotEmpty
                                            ? Image.network(item.imagePath)
                                            : null,
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () =>
                                                  _decrementItemCount(
                                                      selectedItem),
                                            ),
                                            Text('${selectedItem.max}'),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () =>
                                                  _incrementItemCount(
                                                      selectedItem),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),

                CategoryScrollView(
                  categoryList: snapshot.data!,
                  selectedCategoryId: selectedCategoryId,
                  scrollController: _scrollController,
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).cardColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Items: ${_getTotalItemCount()}',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Text(
              ' Total price: \$${_getTotalPrice().toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: const Alignment(1, 0.85),
        child: CheckoutButton(
          selectedItems: selectedItems,
          onPressed: () {
            if (selectedItems.isEmpty) {
              showToast(message: 'No items to checkout');
            } else {
              _navigateToCartScreen();
            }
          },
        ),
      ),
    );
  }
}

class CategoryScrollView extends StatelessWidget {
  final List<category_provider.Category> categoryList;
  final ValueNotifier<int?> selectedCategoryId;
  final ScrollController scrollController;

  const CategoryScrollView({
    super.key,
    required this.categoryList,
    required this.selectedCategoryId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      key: const PageStorageKey('categoryRowScrollPosition'),
      child: Row(
        children: categoryList.map((category) {
          return ValueListenableBuilder<int?>(
            valueListenable: selectedCategoryId,
            builder: (context, selectedCategoryIdValue, child) {
              return Container(
                width: 100,
                height: 50,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                  color: selectedCategoryIdValue == category.id
                      ? Colors.blueAccent
                      : Theme.of(context).cardColor,
                ),
                child: GestureDetector(
                  onTap: () {
                    selectedCategoryId.value = category.id;
                    if (kDebugMode) {
                      print('Selected Category ID: $selectedCategoryId');
                    }
                  },
                  child: Center(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class CheckoutButton extends StatelessWidget {
  final List<SelectedItems> selectedItems;
  final VoidCallback onPressed;

  const CheckoutButton({
    super.key,
    required this.selectedItems,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.greenAccent,
      child: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
    );
  }
}
