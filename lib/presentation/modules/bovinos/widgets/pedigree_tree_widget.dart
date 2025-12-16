import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:dartz/dartz.dart' hide State; // Ocultar State de dartz para evitar conflicto con Flutter
import '../../../../domain/entities/bovinos/bovino.dart';
import '../../../../features/cattle/domain/repositories/cattle_repository.dart';
import '../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../core/errors/failures.dart';
import '../mappers/bovino_mapper.dart';
import 'pedigree_card.dart';
import '../details/bovino_details_screen.dart';

/// Widget para visualizar el árbol genealógico de un bovino
class PedigreeTreeWidget extends StatefulWidget {
  final Bovino bovino;
  final String farmId;
  final Color? primaryColor;

  const PedigreeTreeWidget({
    super.key,
    required this.bovino,
    required this.farmId,
    this.primaryColor,
  });

  @override
  State<PedigreeTreeWidget> createState() => _PedigreeTreeWidgetState();
}

class _PedigreeTreeWidgetState extends State<PedigreeTreeWidget> {
  late final CattleRepository _repository;
  
  @override
  void initState() {
    super.initState();
    _repository = GetIt.instance<CattleRepository>();
    _loadPedigree();
  }
  
  Bovino? _padre;
  Bovino? _madre;
  Bovino? _abueloPaterno;
  Bovino? _abuelaPaterna;
  Bovino? _abueloMaterno;
  Bovino? _abuelaMaterna;
  bool _isLoading = true;
  String? _errorMessage;


  Future<void> _loadPedigree() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Cargar padre y madre usando CattleRepository
      if (widget.bovino.idPadre != null) {
        final padreResult = await (_repository as dynamic).getBovineById(
          widget.farmId,
          widget.bovino.idPadre!,
        ) as Either<Failure, BovineEntity>;
        
        padreResult.fold(
          (failure) {
            // Ignorar error silenciosamente
          },
          (bovineEntity) {
            _padre = BovinoMapper.fromEntity(bovineEntity);
            
            // Cargar abuelos paternos
            if (_padre!.idPadre != null) {
              (_repository as dynamic).getBovineById(
                widget.farmId,
                _padre!.idPadre!,
              ).then((result) {
                (result as Either<Failure, BovineEntity>).fold(
                  (failure) {},
                  (abueloEntity) {
                    if (mounted) {
                      setState(() {
                        _abueloPaterno = BovinoMapper.fromEntity(abueloEntity);
                      });
                    }
                  },
                );
              });
            }
            if (_padre!.idMadre != null) {
              (_repository as dynamic).getBovineById(
                widget.farmId,
                _padre!.idMadre!,
              ).then((result) {
                (result as Either<Failure, BovineEntity>).fold(
                  (failure) {},
                  (abuelaEntity) {
                    if (mounted) {
                      setState(() {
                        _abuelaPaterna = BovinoMapper.fromEntity(abuelaEntity);
                      });
                    }
                  },
                );
              });
            }
          },
        );
      }

      if (widget.bovino.idMadre != null) {
        final madreResult = await (_repository as dynamic).getBovineById(
          widget.farmId,
          widget.bovino.idMadre!,
        ) as Either<Failure, BovineEntity>;
        
        madreResult.fold(
          (failure) {
            // Ignorar error silenciosamente
          },
          (bovineEntity) {
            _madre = BovinoMapper.fromEntity(bovineEntity);
            
            // Cargar abuelos maternos
            if (_madre!.idPadre != null) {
              (_repository as dynamic).getBovineById(
                widget.farmId,
                _madre!.idPadre!,
              ).then((result) {
                (result as Either<Failure, BovineEntity>).fold(
                  (failure) {},
                  (abueloEntity) {
                    if (mounted) {
                      setState(() {
                        _abueloMaterno = BovinoMapper.fromEntity(abueloEntity);
                      });
                    }
                  },
                );
              });
            }
            if (_madre!.idMadre != null) {
              (_repository as dynamic).getBovineById(
                widget.farmId,
                _madre!.idMadre!,
              ).then((result) {
                (result as Either<Failure, BovineEntity>).fold(
                  (failure) {},
                  (abuelaEntity) {
                    if (mounted) {
                      setState(() {
                        _abuelaMaterna = BovinoMapper.fromEntity(abuelaEntity);
                      });
                    }
                  },
                );
              });
            }
          },
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar genealogía: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToProfile(Bovino bovino) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BovinoDetailsScreen(
          bovino: bovino,
          farmId: widget.farmId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.primaryColor ?? theme.primaryColor;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPedigree,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(50),
      minScale: 0.5,
      maxScale: 2.0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Nivel 1: Abuelos
            _buildGrandparentsRow(
              abueloPaterno: _abueloPaterno,
              abuelaPaterna: _abuelaPaterna,
              abueloMaterno: _abueloMaterno,
              abuelaMaterna: _abuelaMaterna,
              color: color,
            ),
            const SizedBox(height: 24),
            // Líneas conectoras a padres
            _buildConnectorLines(color),
            const SizedBox(height: 24),
            // Nivel 2: Padres
            _buildParentsRow(
              padre: _padre,
              madre: _madre,
              color: color,
            ),
            const SizedBox(height: 24),
            // Líneas conectoras al animal actual
            _buildConnectorLines(color),
            const SizedBox(height: 24),
            // Nivel 3: Animal Actual
            _buildCurrentAnimalCard(color),
          ],
        ),
      ),
    );
  }

  Widget _buildGrandparentsRow({
    required Bovino? abueloPaterno,
    required Bovino? abuelaPaterna,
    required Bovino? abueloMaterno,
    required Bovino? abuelaMaterna,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Abuelos Paternos
        Column(
          children: [
            Text(
              'Línea Paterna',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PedigreeCard(
                  bovino: abueloPaterno,
                  relationship: 'Abuelo P.',
                  primaryColor: color,
                  onTap: abueloPaterno != null
                      ? () => _navigateToProfile(abueloPaterno)
                      : null,
                ),
                const SizedBox(width: 8),
                PedigreeCard(
                  bovino: abuelaPaterna,
                  relationship: 'Abuela P.',
                  primaryColor: color,
                  onTap: abuelaPaterna != null
                      ? () => _navigateToProfile(abuelaPaterna)
                      : null,
                ),
              ],
            ),
          ],
        ),
        // Abuelos Maternos
        Column(
          children: [
            Text(
              'Línea Materna',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PedigreeCard(
                  bovino: abueloMaterno,
                  relationship: 'Abuelo M.',
                  primaryColor: color,
                  onTap: abueloMaterno != null
                      ? () => _navigateToProfile(abueloMaterno)
                      : null,
                ),
                const SizedBox(width: 8),
                PedigreeCard(
                  bovino: abuelaMaterna,
                  relationship: 'Abuela M.',
                  primaryColor: color,
                  onTap: abuelaMaterna != null
                      ? () => _navigateToProfile(abuelaMaterna)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParentsRow({
    required Bovino? padre,
    required Bovino? madre,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PedigreeCard(
          bovino: padre,
          relationship: 'Padre',
          primaryColor: color,
          onTap: padre != null ? () => _navigateToProfile(padre) : null,
        ),
        const SizedBox(width: 24),
        PedigreeCard(
          bovino: madre,
          relationship: 'Madre',
          primaryColor: color,
          onTap: madre != null ? () => _navigateToProfile(madre) : null,
        ),
      ],
    );
  }

  Widget _buildCurrentAnimalCard(Color color) {
    return Column(
      children: [
        Text(
          'Animal Actual',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        PedigreeCard(
          bovino: widget.bovino,
          primaryColor: color,
          isHighlighted: true,
        ),
      ],
    );
  }

  Widget _buildConnectorLines(Color color) {
    return CustomPaint(
      size: const Size(double.infinity, 40),
      painter: _PedigreeLinePainter(color: color),
    );
  }
}

/// CustomPainter para dibujar las líneas conectoras del árbol
class _PedigreeLinePainter extends CustomPainter {
  final Color color;

  _PedigreeLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final topY = 0.0;
    final bottomY = size.height;

    // Línea vertical central
    canvas.drawLine(
      Offset(centerX, topY),
      Offset(centerX, bottomY),
      paint,
    );

    // Líneas horizontales desde el centro hacia los lados
    final horizontalLength = size.width * 0.3;
    
    // Línea superior (hacia abuelos)
    canvas.drawLine(
      Offset(centerX - horizontalLength, topY),
      Offset(centerX + horizontalLength, topY),
      paint,
    );

    // Línea inferior (hacia padres)
    canvas.drawLine(
      Offset(centerX - horizontalLength, bottomY),
      Offset(centerX + horizontalLength, bottomY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

