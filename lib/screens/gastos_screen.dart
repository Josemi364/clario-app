import 'package:flutter/material.dart';
import 'package:clario_app/services/api_service.dart';

class GastosScreen extends StatefulWidget {
  const GastosScreen({super.key});

  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  List<dynamic> _gastos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  Future<void> _cargarGastos() async {
    try {
      final data = await ApiService.getGastos();
      setState(() {
        _gastos = data;
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
              onRefresh: _cargarGastos,
              child: _gastos.isEmpty
                  ? const Center(
                      child: Text('No hay gastos todavía',
                          style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _gastos.length,
                      itemBuilder: (context, index) {
                        final g = _gastos[index];
                        return _tarjetaGasto(g);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00D4AA),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const _CrearGastoScreen()),
          );
          _cargarGastos();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _tarjetaGasto(Map<String, dynamic> g) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(g['proveedor'] ?? '',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(g['categoria'] ?? '',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              Text(g['fechaGasto'] ?? '',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${g['baseImponible'] ?? 0} €',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Text('IVA: ${g['cuotaIva'] ?? 0} €',
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: g['esDeducible'] == true
                      ? const Color(0xFF00D4AA).withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  g['esDeducible'] == true ? 'Deducible' : 'No deducible',
                  style: TextStyle(
                      color: g['esDeducible'] == true
                          ? const Color(0xFF00D4AA)
                          : Colors.redAccent,
                      fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CrearGastoScreen extends StatefulWidget {
  const _CrearGastoScreen();

  @override
  State<_CrearGastoScreen> createState() => _CrearGastoScreenState();
}

class _CrearGastoScreenState extends State<_CrearGastoScreen> {
  final _proveedorController = TextEditingController();
  final _baseImponibleController = TextEditingController();
  final _tipoIvaController = TextEditingController(text: '21');
  String _categoria = 'OTROS';
  bool _esDeducible = true;
  bool _cargando = false;
  String? _error;

  final List<String> _categorias = [
    'MATERIAL',
    'TRANSPORTE',
    'SOFTWARE',
    'TELEFONO',
    'OTROS'
  ];

  Future<void> _crearGasto() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await ApiService.crearGasto({
        'proveedor': _proveedorController.text.trim(),
        'fechaGasto': DateTime.now().toIso8601String().split('T')[0],
        'baseImponible': double.parse(_baseImponibleController.text),
        'tipoIva': double.parse(_tipoIvaController.text),
        'categoria': _categoria,
        'esDeducible': _esDeducible,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Error al crear el gasto');
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
        title: const Text('Nuevo gasto',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _campo('Proveedor', _proveedorController),
            const SizedBox(height: 16),
            _campo('Base imponible (€)', _baseImponibleController,
                teclado: TextInputType.number),
            const SizedBox(height: 16),
            _campo('Tipo IVA (%)', _tipoIvaController,
                teclado: TextInputType.number),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              dropdownColor: const Color(0xFF161B22),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Categoría',
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
              items: _categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Es deducible',
                  style: TextStyle(color: Colors.white)),
              value: _esDeducible,
              activeThumbColor: const Color(0xFF00D4AA),
              onChanged: (v) => setState(() => _esDeducible = v),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _cargando ? null : _crearGasto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar gasto',
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