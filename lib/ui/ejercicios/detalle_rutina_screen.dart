import 'dart:async';
import 'dart:ui';

import 'package:cali_app/data/ejercicio_data.dart';
import 'package:cali_app/data/rutina_data.dart';
import 'package:cali_app/ui/ejercicios/alta_rutina_screen.dart';
import 'package:cali_app/ui/ejercicios/info_ejercicio_screen.dart';
import 'package:cali_app/ui/models/detalle_rutina_model.dart';
import 'package:cali_app/ui/models/dia_rutina_model.dart';
import 'package:cali_app/ui/models/rutina_model.dart';
import 'package:cali_app/utils/tiempo_utils.dart';
import 'package:cali_app/widgets/app_layout.dart';
import 'package:cali_app/widgets/celebracion_dia_completado.dart';
import 'package:flutter/material.dart';

class DetalleRutinaScreen extends StatefulWidget {
  final RutinaModel rutina;
  final String? dniAlumno;

  const DetalleRutinaScreen({
    super.key,
    required this.rutina,
    this.dniAlumno,
  });

  @override
  State<DetalleRutinaScreen> createState() => _DetalleRutinaScreenState();
}

class _DetalleRutinaScreenState extends State<DetalleRutinaScreen> {
  late RutinaModel _rutina;
  bool _celebrando = false;

  int? _diaActivo;
  late int _diaSeleccionado;
  final Map<int, int> _segundosAcumulados = {};
  final Map<int, DateTime> _inicioPorDia = {};
  Timer? _timer;

  bool get _modoEntrenamiento => widget.dniAlumno != null;
  bool get _cronometroCorriendo => _timer != null;

  @override
  void initState() {
    super.initState();
    if (_modoEntrenamiento) {
      _rutina = RutinaData().getRutinaAlumno(widget.dniAlumno!, widget.rutina.id) ??
          widget.rutina;
    } else {
      _rutina = widget.rutina;
    }
    _diaSeleccionado = _rutina.dias.first.numero;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarCronometro() {
    if (_diaActivo != null && _diaActivo != _diaSeleccionado) {
      _pausarCronometro(_diaActivo!);
      _timer?.cancel();
      _timer = null;
    }

    _diaActivo = _diaSeleccionado;
    final acumulado = _segundosAcumulados[_diaSeleccionado] ?? 0;
    _inicioPorDia[_diaSeleccionado] =
        DateTime.now().subtract(Duration(seconds: acumulado));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  void _pausarCronometroActivo() {
    if (_diaActivo == null) return;
    _pausarCronometro(_diaActivo!);
    _timer?.cancel();
    _timer = null;
    setState(() {});
  }

  void _reiniciarCronometro() {
    if (_cronometroCorriendo && _diaActivo == _diaSeleccionado) {
      _timer?.cancel();
      _timer = null;
      _diaActivo = null;
    }
    _segundosAcumulados.remove(_diaSeleccionado);
    _inicioPorDia.remove(_diaSeleccionado);
    setState(() {});
  }

  void _onDiaSeleccionadoChanged(int dia) {
    if (_cronometroCorriendo) return;
    setState(() => _diaSeleccionado = dia);
  }

  int get _tiempoMostrado {
    if (_cronometroCorriendo && _diaActivo != null) {
      return _tiempoActual(_diaActivo!);
    }
    return _segundosAcumulados[_diaSeleccionado] ?? 0;
  }

  int _pausarCronometro(int diaNumero) {
    final inicio = _inicioPorDia[diaNumero];
    if (inicio == null) return _segundosAcumulados[diaNumero] ?? 0;
    final elapsed = DateTime.now().difference(inicio).inSeconds;
    _segundosAcumulados[diaNumero] = elapsed;
    _inicioPorDia.remove(diaNumero);
    return elapsed;
  }

  int _detenerYCapturarTiempo(int diaNumero) {
    if (_diaActivo == diaNumero) {
      _timer?.cancel();
      _timer = null;
      _diaActivo = null;
    }
    final tiempo = _pausarCronometro(diaNumero);
    _segundosAcumulados.remove(diaNumero);
    return tiempo;
  }

  int _tiempoActual(int diaNumero) {
    final inicio = _inicioPorDia[diaNumero];
    if (inicio != null) {
      return DateTime.now().difference(inicio).inSeconds;
    }
    return _segundosAcumulados[diaNumero] ?? 0;
  }

  Future<void> _onEjercicioCompletado(
    DiaRutinaModel dia,
    bool completado,
  ) async {
    if (!_modoEntrenamiento || _celebrando) return;

    final todosCompletos = dia.ejercicios.every((e) => e.completado);
    if (!todosCompletos) {
      setState(() {});
      return;
    }

    int tiempoSegundos = 0;
    if (_diaActivo == dia.numero && _cronometroCorriendo) {
      tiempoSegundos = _detenerYCapturarTiempo(dia.numero);
    } else {
      tiempoSegundos = _segundosAcumulados[dia.numero] ?? 0;
      if (_inicioPorDia.containsKey(dia.numero)) {
        tiempoSegundos = _pausarCronometro(dia.numero);
      }
      _segundosAcumulados.remove(dia.numero);
    }

    if (tiempoSegundos > 0) {
      dia.ultimoTiempoSegundos = tiempoSegundos;
    }

    setState(() {});
    _celebrando = true;
    await CelebracionDiaCompletado.mostrar(
      context,
      dia.nombre,
      tiempoSegundos: tiempoSegundos > 0 ? tiempoSegundos : null,
    );
    if (!mounted) return;

    RutinaData().resetCompletadosDia(
      widget.dniAlumno!,
      _rutina.id,
      dia.numero,
    );
    _celebrando = false;

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final puedeEditar =
        !_modoEntrenamiento && RutinaData().getPlantillaPorId(_rutina.id) != null;

    return AppLayout(
      showBackButton: true,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _rutina.nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _rutina.descripcion,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_rutina.cantidadDias} día${_rutina.cantidadDias == 1 ? '' : 's'} · ${_rutina.cantidadEjercicios} ejercicios',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (puedeEditar)
                    TextButton.icon(
                      onPressed: () async {
                        final actualizado = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AltaRutinaScreen(
                              rutinaExistente: _rutina,
                            ),
                          ),
                        );
                        if (actualizado == true && mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xffFFD700),
                      ),
                    ),
                ],
              ),
            ),
            if (_modoEntrenamiento) ...[
              _CronometroCard(
                dias: _rutina.dias,
                diaSeleccionado: _diaSeleccionado,
                diaActivo: _diaActivo,
                tiempoSegundos: _tiempoMostrado,
                corriendo: _cronometroCorriendo,
                onDiaChanged: _onDiaSeleccionadoChanged,
                onIniciar: _iniciarCronometro,
                onPausar: _pausarCronometroActivo,
                onReiniciar: _reiniciarCronometro,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Marcá cada ejercicio al terminarlo y registrá el peso que lograste.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
            ],
            ..._rutina.dias.map(
              (dia) => _DiaSection(
                dia: dia,
                modoEntrenamiento: _modoEntrenamiento,
                onEjercicioCompletado: _onEjercicioCompletado,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaSection extends StatelessWidget {
  final DiaRutinaModel dia;
  final bool modoEntrenamiento;
  final Future<void> Function(DiaRutinaModel dia, bool value) onEjercicioCompletado;

  const _DiaSection({
    required this.dia,
    required this.modoEntrenamiento,
    required this.onEjercicioCompletado,
  });

  @override
  Widget build(BuildContext context) {
    final completados =
        dia.ejercicios.where((e) => e.completado).length;
    final total = dia.ejercicios.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12, top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xffFFD700).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffFFD700),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Día ${dia.numero}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dia.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (modoEntrenamiento) ...[
                if (dia.ultimoTiempoSegundos != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatearDuracion(dia.ultimoTiempoSegundos!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                Text(
                  '$completados/$total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: completados == total
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
        ...dia.ejercicios.map(
          (d) => _DetalleEjercicioTile(
            detalle: d,
            modoEntrenamiento: modoEntrenamiento,
            onCompletadoChanged: (value) =>
                onEjercicioCompletado(dia, value),
          ),
        ),
      ],
    );
  }
}

class _DetalleEjercicioTile extends StatefulWidget {
  final DetalleRutinaModel detalle;
  final bool modoEntrenamiento;
  final ValueChanged<bool> onCompletadoChanged;

  const _DetalleEjercicioTile({
    required this.detalle,
    required this.modoEntrenamiento,
    required this.onCompletadoChanged,
  });

  @override
  State<_DetalleEjercicioTile> createState() => _DetalleEjercicioTileState();
}

class _DetalleEjercicioTileState extends State<_DetalleEjercicioTile> {
  late final TextEditingController _pesoController;

  @override
  void initState() {
    super.initState();
    final peso = widget.detalle.pesoLogrado;
    _pesoController = TextEditingController(
      text: peso != null ? _formatoPeso(peso) : '',
    );
  }

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
  }

  String _formatoPeso(double peso) {
    return peso == peso.roundToDouble()
        ? peso.toInt().toString()
        : peso.toString();
  }

  void _guardarPeso() {
    final texto = _pesoController.text.trim().replaceAll(',', '.');
    if (texto.isEmpty) {
      widget.detalle.pesoLogrado = null;
      setState(() {});
      return;
    }
    final peso = double.tryParse(texto);
    if (peso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ingresá un peso válido'),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }
    widget.detalle.pesoLogrado = peso;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Peso registrado',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xffFFD700),
        duration: Duration(seconds: 1),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detalle;
    final completado = d.completado;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: completado ? 0 : 2,
        color: completado ? Colors.green.shade50 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.modoEntrenamiento) ...[
                    Checkbox(
                      value: completado,
                      activeColor: const Color(0xffFFD700),
                      checkColor: Colors.black87,
                      onChanged: (val) {
                        if (val == null) return;
                        d.completado = val;
                        widget.onCompletadoChanged(val);
                      },
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      d.nombre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: completado ? Colors.grey.shade600 : Colors.black87,
                        decoration:
                            completado ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('${d.series} series', Icons.repeat),
                  _chip('${d.repeticiones} reps', Icons.fitness_center),
                  _chip('${d.pesoSugerido} kg sugerido', Icons.monitor_weight_outlined),
                ],
              ),
              if (widget.modoEntrenamiento) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pesoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Mi peso (kg)',
                          hintText: 'Ej: ${_formatoPeso(d.pesoSugerido)}',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xffFFD700),
                              width: 2,
                            ),
                          ),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _guardarPeso(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _guardarPeso,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.check, size: 20),
                    ),
                  ],
                ),
                if (d.pesoLogrado != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Último registro: ${_formatoPeso(d.pesoLogrado!)} kg',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  final ejercicio = EjercicioData().getPorNombre(d.nombre);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoEjercicioScreen(
                        nombre: d.nombre,
                        videoUrl: d.videoUrl,
                        descripcion: ejercicio?.descripcion ??
                            'Consultá el video para ver la técnica correcta de este ejercicio.',
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Detalle del ejercicio',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffFFD700).withOpacity(0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _CronometroCard extends StatelessWidget {
  final List<DiaRutinaModel> dias;
  final int diaSeleccionado;
  final int? diaActivo;
  final int tiempoSegundos;
  final bool corriendo;
  final ValueChanged<int> onDiaChanged;
  final VoidCallback onIniciar;
  final VoidCallback onPausar;
  final VoidCallback onReiniciar;

  const _CronometroCard({
    required this.dias,
    required this.diaSeleccionado,
    required this.diaActivo,
    required this.tiempoSegundos,
    required this.corriendo,
    required this.onDiaChanged,
    required this.onIniciar,
    required this.onPausar,
    required this.onReiniciar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: corriendo ? const Color(0xffFFD700) : Colors.grey.shade300,
          width: corriendo ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffFFD700)
                      .withOpacity(corriendo ? 0.35 : 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color:
                      corriendo ? const Color(0xffC9A600) : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      corriendo
                          ? 'Cronómetro en marcha · Día $diaActivo'
                          : 'Cronómetro',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatearDuracion(tiempoSegundos),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: corriendo ? Colors.black87 : Colors.grey.shade700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              if (corriendo)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Día a cronometrar',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: dias.map((dia) {
              final seleccionado = dia.numero == diaSeleccionado;
              return ChoiceChip(
                label: Text('Día ${dia.numero}'),
                selected: seleccionado,
                selectedColor: const Color(0xffFFD700).withOpacity(0.4),
                onSelected: corriendo ? null : (_) => onDiaChanged(dia.numero),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: corriendo ? onPausar : onIniciar,
                  icon: Icon(corriendo ? Icons.pause : Icons.play_arrow),
                  label: Text(corriendo ? 'Pausar' : 'Iniciar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (tiempoSegundos > 0 && !corriendo) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onReiniciar,
                  icon: const Icon(Icons.replay),
                  tooltip: 'Reiniciar',
                  color: Colors.grey.shade600,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
