// lib/screens/live_cart_screen.dart
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class LiveCartScreen extends StatefulWidget {
  final int sessionId;
  const LiveCartScreen({super.key, required this.sessionId});

  @override
  State<LiveCartScreen> createState() => _LiveCartScreenState();
}

class _LiveCartScreenState extends State<LiveCartScreen> {
  late final WebSocketChannel channel;
  
  final String _baseUrl = "http://192.168.197.142:8000";

  @override
  void initState() {
    super.initState();
    
    // تحويل الـ HTTP إلى WebSocket URL
    final httpUri = Uri.parse(_baseUrl);
    final wsUrl = Uri(
      scheme: httpUri.scheme == "https" ? "wss" : "ws", // دعم wss لو كنت تستخدم HTTPS
      host: httpUri.host,
      port: httpUri.port,
      path: '/ws/cart/${widget.sessionId}',
    );

    channel = WebSocketChannel.connect(wsUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Cart (Session #${widget.sessionId})"),
      ),
      body: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Connection Error. Please try again."));
          }

          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Waiting for cart updates..."),
                ],
              ),
            );
          }

          try {
            final cartData = json.decode(snapshot.data);
            final List<dynamic> items = cartData['items'];
            final double total = (cartData['current_total'] as num).toDouble();

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: const Icon(Icons.shopping_basket),
                        title: Text(item['name'] ?? 'Unknown Item'),
                        subtitle: Text("Quantity: ${item['quantity']}"),
                        trailing: Text("${(item['price'] as num).toStringAsFixed(2)} \$"),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    "Total: ${total.toStringAsFixed(2)} \$",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          } catch (e) {
            return const Center(child: Text("Invalid data received from server."));
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
