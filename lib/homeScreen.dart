import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  

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
            style: TextStyle(
                color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
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
        stream: FirebaseFirestore.instance.collection('donations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Erro ao carregar"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Lógica de Cálculo das Stats ---
          final docs = snapshot.data!.docs;
          final totalItems = docs.length;
          
          // Conta quantos estão vencidos ou vencendo em 15 dias
          final criticalAlerts = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final expiration = DateTime.parse(data['expirationDate']);
            return expiration.difference(DateTime.now()).inDays <= 15;
          }).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Visão Geral",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("Bem-vindo de volta. Aqui está o resumo de hoje.",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),

                // --- Grid de Status Dinâmico ---
                _buildStatCard("ESTOQUE ATUAL", totalItems.toString(), 
                    "Total de Itens", Icons.inventory_2_outlined, Colors.green),
                _buildStatCard("ALERTA CRÍTICO", criticalAlerts.toString(), 
                    "Próximo do Vencimento", Icons.warning_amber_rounded, Colors.red),
                _buildStatCard("ESTE MÊS", docs.length.toString(), 
                    "Doações do Mês", Icons.thumb_up_outlined, Colors.blue),

                const SizedBox(height: 24),

                Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text("Atividade Recente",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  ],
),

StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('activities')
      .orderBy('timestamp', descending: true)
      .limit(3) // Mostra apenas as 3 últimas
      .snapshots(),
  builder: (context, activitySnapshot) {
    if (!activitySnapshot.hasData) return const SizedBox();

    return Column(
      children: activitySnapshot.data!.docs.map((doc) {
        Map<String, dynamic> act = doc.data() as Map<String, dynamic>;
        
        // Define o ícone e cor baseado no tipo
        IconData icon = Icons.info_outline;
        Color color = Colors.grey;
        
        if (act['type'] == 'entry') {
          icon = Icons.login;
          color = Colors.green;
        } else if (act['type'] == 'exit') {
          icon = Icons.logout;
          color = Colors.blue;
        }

        return _buildActivityItem(
          act['title'] ?? "",
          act['subtitle'] ?? "",
          "Agora", // Para converter o timestamp em "X min atrás", use o package 'timeago'
          icon,
          color,
        );
      }).toList(),
    );
  },
),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String sub, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Text(time,
          style: const TextStyle(fontSize: 10, color: Colors.grey)),
    );
  }
}