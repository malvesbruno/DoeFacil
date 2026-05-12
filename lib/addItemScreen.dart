import 'package:doe_facil/data/activity.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  String _category = "Grãos";
  DateTime _selectedDate = DateTime.now();
  final List<bool> _unitToggle = [true, false, false]; // kg, un, L

  void _saveItem() async {
    if (_nameController.text.isEmpty || _qtyController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('donations').add({
      'name': _nameController.text,
      'category': _category,
      'quantity': double.tryParse(_qtyController.text) ?? 0,
      'unit': _unitToggle[0] ? 'kg' : (_unitToggle[1] ? 'un' : 'L'),
      'expirationDate': _selectedDate.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _qtyController.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item salvo com sucesso!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Cadastro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nome do Item", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ["Grãos", "Laticínios", "Enlatados", "Bebidas", "Roupas", "Higiene", "Outros"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qtyController, 
              keyboardType: TextInputType.number, 
              decoration: const InputDecoration(labelText: "Quantidade", border: OutlineInputBorder())
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Text("Validade: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: ()  async{
                  // Após salvar o item no estoque:
                  logActivity(
                    "Entrada: ${_qtyController.text}${_unitToggle[0] ? 'kg' : 'un'} de ${_nameController.text}",
                    "Novo item adicionado ao estoque",
                    "entry"
                  );
                  _saveItem();
                  },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4332), foregroundColor: Colors.white),
                child: const Text("SALVAR NO ESTOQUE"),
              ),
            )
          ],
        ),
      ),
    );
  }
}