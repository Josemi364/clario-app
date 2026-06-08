import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clario_app/services/api_service.dart';
import 'dart:io';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  File? _imagen;
  Map<String, dynamic>? _resultado;
  bool _cargando = false;
  String? _error;

  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarImagen(ImageSource source) async {
    final XFile? foto = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (foto != null) {
      setState(() {
        _imagen = File(foto.path);
        _resultado = null;
        _error = null;
      });
      await _analizarImagen();
    }
  }

  Future<void> _analizarImagen() async {
    if (_imagen == null) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado = await ApiService.analizarFacturaOcr(_imagen!);
      setState(() {
        _resultado = resultado;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error analizando la imagen';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Escanear factura',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _botonSeleccion(),
            const SizedBox(height: 20),
            if (_imagen != null) _previstaImagen(),
            if (_cargando) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Color(0xFF00D4AA)),
              const SizedBox(height: 12),
              const Text('Analizando con IA...',
                  style: TextStyle(color: Colors.white54)),
            ],
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            if (_resultado != null) ...[
              const SizedBox(height: 20),
              _tarjetaResultado(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _botonSeleccion() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.document_scanner,
              color: Color(0xFF00D4AA), size: 48),
          const SizedBox(height: 12),
          const Text('Escanea un ticket o factura',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('La IA extraerá los datos automáticamente',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _seleccionarImagen(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                  label: const Text('Cámara',
                      style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _seleccionarImagen(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, color: Colors.black),
                  label: const Text('Galería',
                      style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previstaImagen() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(_imagen!, height: 200, fit: BoxFit.cover),
    );
  }

  Widget _tarjetaResultado() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D4AA).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Datos extraídos por IA',
              style: TextStyle(
                  color: Color(0xFF00D4AA),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _fila('Proveedor', _resultado?['proveedor']?.toString() ?? '-'),
          _fila('Base imponible', '${_resultado?['baseImponible'] ?? 0} €'),
          _fila('Tipo IVA', '${_resultado?['tipoIva'] ?? 0}%'),
          _fila('Cuota IVA', '${_resultado?['cuotaIva'] ?? 0} €'),
          _fila('Total', '${_resultado?['total'] ?? 0} €'),
          _fila('Fecha', _resultado?['fecha']?.toString() ?? '-'),
          _fila('Categoría', _resultado?['categoria']?.toString() ?? '-'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _guardarGasto,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar como gasto',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(valor,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _guardarGasto() async {
    if (_resultado == null) return;
    try {
      await ApiService.crearGasto({
        'proveedor': _resultado?['proveedor'] ?? 'Desconocido',
        'fechaGasto': _resultado?['fecha'] ??
            DateTime.now().toIso8601String().split('T')[0],
        'baseImponible': _resultado?['baseImponible'] ?? 0,
        'tipoIva': _resultado?['tipoIva'] ?? 21,
        'categoria': _resultado?['categoria'] ?? 'OTROS',
        'esDeducible': true,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto guardado correctamente'),
            backgroundColor: Color(0xFF00D4AA),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = 'Error guardando el gasto');
    }
  }
}