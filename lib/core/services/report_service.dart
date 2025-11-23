import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

/// Servicio para generar reportes PDF y CSV
class ReportService {
  /// Genera un reporte PDF de inventario
  Future<File> generateInventoryReport({
    required String module,
    required List<Map<String, dynamic>> data,
    required String farmName,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Reporte de Inventario - $module',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Finca: $farmName'),
          pw.Text('Fecha: ${dateFormat.format(DateTime.now())}'),
          pw.SizedBox(height: 20),
          if (data.isNotEmpty)
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: data.first.keys.map((key) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      key.toString(),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  )).toList(),
                ),
                ...data.map((row) => pw.TableRow(
                      children: row.values.map((value) => pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(value?.toString() ?? ''),
                          )).toList(),
                    )),
              ],
            )
          else
            pw.Text('No hay datos para mostrar'),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/reporte_${module}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Exporta datos a CSV
  Future<File> exportToCsv({
    required String module,
    required List<Map<String, dynamic>> data,
  }) async {
    if (data.isEmpty) {
      throw Exception('No hay datos para exportar');
    }

    final headers = data.first.keys.toList();
    final rows = <List<dynamic>>[
      headers,
      ...data.map((row) => headers.map((key) => row[key]?.toString() ?? '').toList()),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/export_${module}_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    return file;
  }
}

