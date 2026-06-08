import 'package:flutter/material.dart';
import 'package:clario_app/services/api_service.dart';
import 'package:clario_app/screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _sueldoNeto;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final data = await ApiService.getSueldoNeto();
      setState(() {
        _sueldoNeto = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando datos';
        _cargando = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    await ApiService.cerrarSesion();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Clario',
            style: TextStyle(
                color: Color(0xFF00D4AA), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00D4AA)))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tarjetaSueldoNeto(),
                        const SizedBox(height: 20),
                        _tarjetaDesglose(),
                        const SizedBox(height: 20),
                        _tarjetaAlerta(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _tarjetaSueldoNeto() {
    final sueldo = _sueldoNeto?['sueldoNetoDisponible'] ?? '0';
    final mensual = _sueldoNeto?['sueldoNetoMensual'] ?? '0';
    final periodo = _sueldoNeto?['periodo'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4AA), Color(0xFF00A080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(periodo,
              style: const TextStyle(color: Colors.black54, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Sueldo Neto Disponible',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('$sueldo €',
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 42,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$mensual € / mes',
              style: const TextStyle(color: Colors.black54, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _tarjetaDesglose() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Desglose del trimestre',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _filaDesglose('Ingresos brutos',
              '${_sueldoNeto?['ingresosBrutos'] ?? 0} €', Colors.white),
          _filaDesglose('IVA a Hacienda (303)',
              '- ${_sueldoNeto?['ivaNetoModelo303'] ?? 0} €', Colors.redAccent),
          _filaDesglose('Gastos deducibles',
              '- ${_sueldoNeto?['gastosDeducibles'] ?? 0} €', Colors.orange),
          _filaDesglose('Cuota autónomos',
              '- ${_sueldoNeto?['cuotaAutonomosTrimestre'] ?? 0} €',
              Colors.redAccent),
          _filaDesglose('Provisión IRPF (130)',
              '- ${_sueldoNeto?['provisionIrpf'] ?? 0} €', Colors.redAccent),
          const Divider(color: Colors.white12),
          _filaDesglose('Sueldo neto',
              '${_sueldoNeto?['sueldoNetoDisponible'] ?? 0} €',
              const Color(0xFF00D4AA)),
        ],
      ),
    );
  }

  Widget _filaDesglose(String label, String valor, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(valor,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _tarjetaAlerta() {
    final alerta = _sueldoNeto?['alerta'] ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1500),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(alerta,
                style: const TextStyle(color: Colors.orange, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}