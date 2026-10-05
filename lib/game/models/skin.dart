import 'package:flutter/material.dart';

class SkinModel {
  const SkinModel({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.price,
    this.accentColor,
    this.isAstronaut = false,
  });

  final int id;
  final String name;
  final Color primaryColor;
  final Color? accentColor;
  final int price;
  final bool isAstronaut;
}

class SkinCatalog {
  static const List<SkinModel> all = [
    SkinModel(
      id: 0,
      name: 'Sky Blue',
      primaryColor: Color(0xFF2A9DFF),
      accentColor: Color(0xFF74C3FF),
      price: 0,
    ),
    SkinModel(
      id: 1,
      name: 'Sunset',
      primaryColor: Color(0xFFFF7A59),
      accentColor: Color(0xFFFFBE8B),
      price: 80,
    ),
    SkinModel(
      id: 2,
      name: 'Mint',
      primaryColor: Color(0xFF29C7A0),
      accentColor: Color(0xFF8AE6D1),
      price: 110,
    ),
    SkinModel(
      id: 3,
      name: 'Solar Gold',
      primaryColor: Color(0xFFF4B942),
      accentColor: Color(0xFFF7D384),
      price: 130,
    ),
    SkinModel(
      id: 4,
      name: 'Crimson',
      primaryColor: Color(0xFFE74C57),
      accentColor: Color(0xFFFF9EA5),
      price: 150,
    ),
    SkinModel(
      id: 5,
      name: 'Void',
      primaryColor: Color(0xFF3E4459),
      accentColor: Color(0xFF8D96B3),
      price: 170,
    ),
    SkinModel(
      id: 6,
      name: 'Aurora',
      primaryColor: Color(0xFF7A59FF),
      accentColor: Color(0xFFC2B3FF),
      price: 190,
    ),
    SkinModel(
      id: 7,
      name: 'Astronaut',
      primaryColor: Color(0xFFF5F7FA),
      accentColor: Color(0xFF9EA9B8),
      price: 240,
      isAstronaut: true,
    ),
  ];

  static SkinModel byId(int id) {
    return all.firstWhere((skin) => skin.id == id, orElse: () => all.first);
  }
}
