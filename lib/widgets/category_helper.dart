import 'package:flutter/material.dart';

class CategoryHelper {
  static const List<String> categories = [
    'Food',
    'Travel',
    'Transport',
    'Shopping',
    'Entertainment',
    'Rent',
    'Bills',
    'Groceries',
    'Medical',
    'Education',
    'Utilities',
    'Others',
  ];

  static IconData getIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.flight_takeoff_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Entertainment':
        return Icons.sports_esports_rounded;
      case 'Rent':
        return Icons.home_rounded;
      case 'Bills':
        return Icons.receipt_rounded;
      case 'Groceries':
        return Icons.local_grocery_store_rounded;
      case 'Medical':
        return Icons.medical_services_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Utilities':
        return Icons.electrical_services_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  static Color getColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFFF9800); // Orange
      case 'Travel':
        return const Color(0xFF2196F3); // Blue
      case 'Transport':
        return const Color(0xFF00BCD4); // Cyan
      case 'Shopping':
        return const Color(0xFFE91E63); // Pink
      case 'Entertainment':
        return const Color(0xFFFFC107); // Amber
      case 'Rent':
        return const Color(0xFF795548); // Brown
      case 'Bills':
        return const Color(0xFF607D8B); // Blue Grey
      case 'Groceries':
        return const Color(0xFF4CAF50); // Green
      case 'Medical':
        return const Color(0xFFF44336); // Red
      case 'Education':
        return const Color(0xFF673AB7); // Deep Purple
      case 'Utilities':
        return const Color(0xFF9C27B0); // Purple
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}
