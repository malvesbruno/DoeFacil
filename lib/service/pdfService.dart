import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> exportReport() async {
    final pdf = pw.Document();

    // 1. Buscar os dados reais do Firestore
    final snapshot = await FirebaseFirestore.instance.collection('donations').get();
    final donations = snapshot.docs;

    // 2. Montar o PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("DoeFacil - Relatorio de Impacto Social", 
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Paragraph(text: "Data do relatorio: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"),
          pw.SizedBox(height: 20),
          
          // Tabela de Itens
          pw.TableHelper.fromTextArray(
            headers: ['Item', 'Categoria', 'Qtd', 'Validade'],
            data: donations.map((doc) {
              final data = doc.data();
              final date = DateTime.parse(data['expirationDate']);
              return [
                data['name'],
                data['category'],
                "${data['quantity']} ${data['unit']}",
                "${date.day}/${date.month}/${date.year}",
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
          
          pw.SizedBox(height: 40),
          pw.Footer(
            title: pw.Text("Total de itens em estoque: ${donations.length}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );

    // 3. Abrir o menu de compartilhamento/impressao nativo
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Relatorio_DoeFacil.pdf',
    );
  }
}