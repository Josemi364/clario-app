import 'package:flutter/material.dart';
import 'package:clario_app/services/api_service.dart';

class FacturasScreen extends StatefulWidget {
  const FacturasScreen({super.key});

  @override
  State<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends State<FacturasScreen> {
  List<dynamic> _facturas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarFacturas();
  }

  Future<void> _cargarFacturas() async {
    try {
      final data = await ApiService.getFacturas();
      setState(() {
        _facturas = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00D4AA)))
          : RefreshIndicator(
              onRefresh: _cargarFacturas,
              child: _facturas.isEmpty
                  ? const Center(
                      child: Text('No hay facturas todavía',
                          style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _facturas.length,
                      itemBuilder: (context, index) {
                        final f = _facturas[index];
                        return _tarjetaFactura(f);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00D4AA),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const _CrearFacturaScreen()),
          );
          _cargarFacturas();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _tarjetaFactura(Map<String, dynamic> f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(f['numeroSerie'] ?? '',
                  style: const TextStyle(
                      color: Color(0xFF00D4AA), fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(f['estado'] ?? '',
                    style: const TextStyle(
                        color: Color(0xFF00D4AA), fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(f['clienteNombre'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(f['fechaEmision'] ?? '',
                  style: const TextStyle(color: Colors.white54)),
              Text('${f['total'] ?? 0} €',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CrearFacturaScreen extends StatefulWidget {
  const _CrearFacturaScreen();

  @override
  State<_CrearFacturaScreen> createState() => _CrearFacturaScreenState();
}

class _CrearFacturaScreenState extends State<_CrearFacturaScreen> {
  final _clienteNombreController = TextEditingController();
  final _clienteNifController = TextEditingController();
  final _baseImponibleController = TextEditingController();
  final _tipoIvaController = TextEditingController(text: '21');
  final _tipoIrpfController = TextEditingController(text: '15');
  bool _cargando = false;
  String? _error;

  Future<void> _crearFactura() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await ApiService.crearFactura({
        'clienteNombre': _clienteNombreController.text.trim(),
        'clienteNif': _clienteNifController.text.trim(),
        'fechaEmision': DateTime.now().toIso8601String().split('T')[0],
        'baseImponible': double.parse(_baseImponibleController.text),
        'tipoIva': double.parse(_tipoIvaController.text),
        'tipoIrpf': double.parse(_tipoIrpfController.text),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Error al crear la factura');
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Nueva factura',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _campo('Nombre del cliente', _clienteNombreController),
            const SizedBox(height: 16),
            _campo('NIF del cliente', _clienteNifController),
            const SizedBox(height: 16),
            _campo('Base imponible (€)', _baseImponibleController,
                teclado: TextInputType.number),
            const SizedBox(height: 16),
            _campo('Tipo IVA (%)', _tipoIvaController,
                teclado: TextInputType.number),
            const SizedBox(height: 16),
            _campo('Retención IRPF (%)', _tipoIrpfController,
                teclado: TextInputType.number),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _cargando ? null : _crearFactura,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Crear factura',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController controller,
      {TextInputType teclado = TextInputType.text}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: teclado,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00D4AA)),
        ),
        filled: true,
        fillColor: const Color(0xFF161B22),
      ),
    );
  }
}