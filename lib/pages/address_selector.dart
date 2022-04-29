// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:silu/utils.dart';

class AddressSelector extends StatefulWidget {
  const AddressSelector({Key? key}) : super(key: key);

  @override
  State<AddressSelector> createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 44,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: null,
    );
  }
}
