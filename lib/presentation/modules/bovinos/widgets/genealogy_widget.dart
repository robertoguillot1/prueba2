import 'package:flutter/material.dart';
import '../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../features/cattle/domain/usecases/get_cattle_list.dart';
import '../../../../core/di/dependency_injection.dart' as di;
import '../../screens/bovino_detail_screen.dart';

/// Widget para mostrar el árbol genealógico de un bovino
class GenealogyWidget extends StatefulWidget {
  final BovineEntity bovine;
  final String farmId;

  const GenealogyWidget({
    super.key,
    required this.bovine,
    required this.farmId,
  });

  @override
  State<GenealogyWidget> createState() => _GenealogyWidgetState();
}

class _GenealogyWidgetState extends State<GenealogyWidget> {
  BovineEntity? _father;
  BovineEntity? _mother;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadParents();
  }

  Future<void> _loadParents() async {
    if (widget.bovine.fatherId == null && widget.bovine.motherId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final getCattleList = di.sl<GetCattleList>();
      final result = await getCattleList(
        GetCattleListParams(farmId: widget.farmId),
      );

      result.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        },
        (bovines) {
          setState(() {
            if (widget.bovine.fatherId != null) {
              try {
                _father = bovines.firstWhere(
                  (b) => b.id == widget.bovine.fatherId,
                );
              } catch (e) {
                // Padre no encontrado
              }
            }

            if (widget.bovine.motherId != null) {
              try {
                _mother = bovines.firstWhere(
                  (b) => b.id == widget.bovine.motherId,
                );
              } catch (e) {
                // Madre no encontrada
              }
            }

            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Error al cargar genealogía: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      );
    }

    // Si no hay padre ni madre registrados
    if (_father == null && _mother == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No hay información de genealogía registrada',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      );
    }

    return _buildGenealogyTree(context);
  }

  Widget _buildGenealogyTree(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fila de padres
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Padre
              Expanded(
                child: _buildParentCard(
                  context,
                  parent: _father,
                  label: 'Padre (Sire)',
                  icon: Icons.male,
                  color: Colors.blue,
                ),
              ),
              if (_father != null && _mother != null)
                const SizedBox(width: 16),
              // Madre
              Expanded(
                child: _buildParentCard(
                  context,
                  parent: _mother,
                  label: 'Madre (Dam)',
                  icon: Icons.female,
                  color: Colors.pink,
                ),
              ),
            ],
          ),

          // Líneas conectoras
          if (_father != null || _mother != null) ...[
            const SizedBox(height: 16),
            CustomPaint(
              size: const Size(double.infinity, 40),
              painter: _GenealogyConnectorPainter(
                hasFather: _father != null,
                hasMother: _mother != null,
              ),
            ),
          ],

          // Bovino actual
          const SizedBox(height: 16),
          _buildCurrentBovineCard(context),
        ],
      ),
    );
  }

  Widget _buildParentCard(
    BuildContext context, {
    required BovineEntity? parent,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    if (parent == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey.shade400, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No registrado',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BovinoDetailScreen(
              bovine: parent,
              farmId: widget.farmId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              parent.name ?? 'Sin nombre',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              parent.identifier,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
            if (parent.breed.isNotEmpty)
              Text(
                parent.breed,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBovineCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            widget.bovine.gender == BovineGender.male
                ? Icons.male
                : Icons.female,
            color: Colors.green,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Bovino Actual',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.bovine.name ?? 'Sin nombre',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.bovine.identifier,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          if (widget.bovine.breed.isNotEmpty)
            Text(
              widget.bovine.breed,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }
}

/// CustomPainter para dibujar las líneas conectoras del árbol genealógico
class _GenealogyConnectorPainter extends CustomPainter {
  final bool hasFather;
  final bool hasMother;

  _GenealogyConnectorPainter({
    required this.hasFather,
    required this.hasMother,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final topY = 0.0;
    final bottomY = size.height;

    if (hasFather && hasMother) {
      // Ambos padres: líneas desde los extremos hacia el centro
      final leftX = size.width * 0.25;
      final rightX = size.width * 0.75;

      // Línea desde padre (izquierda)
      canvas.drawLine(
        Offset(leftX, topY),
        Offset(leftX, bottomY - 20),
        paint,
      );

      // Línea desde madre (derecha)
      canvas.drawLine(
        Offset(rightX, topY),
        Offset(rightX, bottomY - 20),
        paint,
      );

      // Línea horizontal que conecta ambas
      canvas.drawLine(
        Offset(leftX, bottomY - 20),
        Offset(rightX, bottomY - 20),
        paint,
      );

      // Línea vertical central hacia abajo
      canvas.drawLine(
        Offset(centerX, bottomY - 20),
        Offset(centerX, bottomY),
        paint,
      );
    } else if (hasFather) {
      // Solo padre: línea desde la izquierda al centro
      final leftX = size.width * 0.25;
      canvas.drawLine(
        Offset(leftX, topY),
        Offset(leftX, bottomY - 20),
        paint,
      );
      canvas.drawLine(
        Offset(leftX, bottomY - 20),
        Offset(centerX, bottomY - 20),
        paint,
      );
      canvas.drawLine(
        Offset(centerX, bottomY - 20),
        Offset(centerX, bottomY),
        paint,
      );
    } else if (hasMother) {
      // Solo madre: línea desde la derecha al centro
      final rightX = size.width * 0.75;
      canvas.drawLine(
        Offset(rightX, topY),
        Offset(rightX, bottomY - 20),
        paint,
      );
      canvas.drawLine(
        Offset(rightX, bottomY - 20),
        Offset(centerX, bottomY - 20),
        paint,
      );
      canvas.drawLine(
        Offset(centerX, bottomY - 20),
        Offset(centerX, bottomY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

