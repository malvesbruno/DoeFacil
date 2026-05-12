import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doe_facil/service/pdfService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? "User";
    final String initials = email.substring(0, 2).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('DoeFacil',
            style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              // 2. O botão que abre o menu agora é o seu CircleAvatar
              icon: CircleAvatar(
                backgroundColor: const Color(0xFF2D6A4F),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              onSelected: (value) async {
                if (value == 'logout') {
                  // 3. Lógica de Logout
                  await FirebaseAuth.instance.signOut();
                  // O StreamBuilder no main.dart vai notar e te mandar pro Login
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Sair do App', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Escuta tanto doações quanto atividades para gerar o relatório
        stream: FirebaseFirestore.instance.collection('donations').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          
          // Lógica para calcular distribuição por categoria
          Map<String, int> categories = {
            'Grãos': 0,
            'Laticínios': 0,
            'Enlatados': 0,
            'Bebidas': 0,
            'Roupas': 0,
            'Higiene': 0,
            'Outros': 0,
          };


          for (var doc in docs) {
            String cat = doc['category'] ?? 'Outros';
            if (categories.containsKey(cat)) {
              categories[cat] = categories[cat]! + 1;
            }
          }

          double total = docs.length.toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Relatório Simples",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A))),
                const Text("Visão geral do impacto e distribuição de doações no período atual.",
                    style: TextStyle(color: Colors.grey)),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    _buildSmallButton(Icons.calendar_month, "Últimos 30 dias", (){}),
                    const SizedBox(width: 8),
                    _buildSmallButton(
                    Icons.picture_as_pdf, 
                    "Exportar PDF", 
                    PdfService.exportReport,
                    isPrimary: true, // Chamada aqui
                  ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- Métricas Reais ---
                _buildMetricCard("ITENS EM ESTOQUE", docs.length.toString(), "Dados em tempo real", Icons.inventory_2, Colors.green),
                _buildMetricCard("FAMÍLIAS IMPACTADAS", (docs.length * 4).toString(), "Estimativa baseada no estoque", Icons.people, Colors.blue),

                const SizedBox(height: 30),

                // --- Distribuição Dinâmica ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.analytics_outlined, color: Color(0xFF1B5E20)),
                          SizedBox(width: 8),
                          Text("Distribuição por Categoria", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...categories.entries.map((e) {
                        double percentage = total > 0 ? e.value / total : 0;
                        return _buildCategoryProgress(
                          e.key, 
                          percentage, 
                          "${(percentage * 100).toStringAsFixed(0)}%", 
                          _getCategoryColor(e.key)
                        );
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text("Últimas Distribuições (Logs)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Stream de Atividades para o Histórico
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('activities').orderBy('timestamp', descending: true).limit(5).snapshots(),
                  builder: (context, actSnapshot) {
                    if (!actSnapshot.hasData) return const SizedBox();
                    return Column(
                      children: actSnapshot.data!.docs.map((doc) {
                        return _buildHistoryItem(
                          doc['title'], 
                          doc['subtitle'], 
                          "Recente", 
                          doc['type'].toString().toUpperCase(), 
                          doc['type'] == 'entry' ? Colors.green : Colors.blue
                        );
                      }).toList(),
                    );
                  }
                ),
                
                const SizedBox(height: 20),
                Center(child: TextButton(onPressed: () {}, child: const Text("Ver todo o histórico"))),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Grãos': return Colors.green;
      case 'Laticínios': return Colors.blue;
      case 'Higiene': return Colors.orange;
      default: return Colors.grey;
    }
  }

  // --- Seus Widgets Auxiliares (Mantidos conforme o design) ---
  Widget _buildMetricCard(String label, String value, String trend, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(trend, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryProgress(String label, double value, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text(percent, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: value, color: color, backgroundColor: Colors.grey[200], minHeight: 8),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String local, String time, String tag, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(local),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(tag, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  // Mude o final do seu arquivo para isso:
Widget _buildSmallButton(IconData icon, String text, VoidCallback onPressed, {bool isPrimary = false}) {
  return Expanded(
    child: OutlinedButton.icon(
      onPressed: onPressed, // Agora ele executa a função passada
      icon: Icon(icon, size: 16, color: isPrimary ? Colors.white : Colors.black),
      label: Text(text, style: TextStyle(fontSize: 12, color: isPrimary ? Colors.white : Colors.black)),
      style: OutlinedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF1B4332) : Colors.white,
        side: isPrimary ? BorderSide.none : const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
}