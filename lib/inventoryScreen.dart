import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doe_facil/data/activity.dart';


class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão de Inventário', style: TextStyle(fontWeight: FontWeight.bold))),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .orderBy('expirationDate', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Erro ao carregar dados'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhum item cadastrado."));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              
              // Lógica de Datas
              DateTime expiration = DateTime.parse(data['expirationDate']);
              final daysLeft = expiration.difference(DateTime.now()).inDays;
              
              String status = "OK";
              Color sColor = Colors.green[100]!;
              Color tColor = Colors.green[900]!;

              if (daysLeft < 0) {
                status = "Expired";
                sColor = Colors.red[100]!;
                tColor = Colors.red[900]!;
              } else if (daysLeft <= 15) {
                status = "Expiring in $daysLeft days";
                sColor = Colors.orange[100]!;
                tColor = Colors.orange[900]!;
              }

              return _buildInventoryCard(
                docId: doc.id,
                title: data['name'],
                category: data['category'],
                qty: "${data['quantity']} ${data['unit']}",
                status: status,
                statusColor: sColor,
                textColor: tColor,
                date: "${expiration.day}/${expiration.month}/${expiration.year}",
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildInventoryCard({
    required String docId, required String title, required String category, 
    required String qty, required String status, required Color statusColor, 
    required Color textColor, required String date,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(status, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(qty, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1B4332))),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.event, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text("Vence: $date", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
                ElevatedButton(
                  onPressed: () async { // Adicionei o async caso o log precise esperar
                    await logActivity(
                      "Saída: $title",
                      "Item retirado do estoque",
                      "exit",
                    );
                    await FirebaseFirestore.instance.collection('donations').doc(docId).delete();
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F), 
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Dar Baixa'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}