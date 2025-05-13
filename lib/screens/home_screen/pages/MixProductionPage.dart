import 'package:flutter/material.dart';

class MixProductionPage extends StatefulWidget {
  const MixProductionPage({super.key});

  @override
  State<MixProductionPage> createState() => _MixProductionPageState();
}

class _MixProductionPageState extends State<MixProductionPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("انتاج الخلطات"),
      ),
    );
  }
}
