import 'package:get/get.dart';

class HomeController extends GetxController {
  // Original full list (numbers and alphabets)
  final RxList<String> allItems = <String>[].obs;

  // Filtered list based on search
  final RxList<String> filteredItems = <String>[].obs;

  // Search query
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize with numbers and alphabets
    allItems.assignAll([
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
    ]);

    // Initially show all
    filteredItems.assignAll(allItems);

    // Update filteredItems whenever searchQuery changes
    ever(searchQuery, (_) => filterItems());
  }

  void filterItems() {
    if (searchQuery.value.isEmpty) {
      filteredItems.assignAll(allItems);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredItems.assignAll(
        allItems.where((item) => item.toLowerCase().contains(query)).toList(),
      );
    }
  }
}
