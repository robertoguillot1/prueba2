import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cattle.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../screens/cattle_profile_screen.dart';
import 'pedigree_card.dart';

class PedigreeTreeWidget extends StatelessWidget {
  final Cattle cattle;
  final Farm farm;
  final Color primaryColor;

  const PedigreeTreeWidget({
    super.key,
    required this.cattle,
    required this.farm,
    this.primaryColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        // Buscar ancestros usando la función fetchAncestors
        final ancestors = _fetchAncestors(cattle, updatedFarm);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_tree, color: primaryColor, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Árbol Genealógico (Pedigrí)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (ancestors['padre'] == null && ancestors['madre'] == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay información de padres registrada',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Puedes agregar los padres en la sección de edición',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(50),
                      minScale: 0.4,
                      maxScale: 2.5,
                      child: _buildTreeLayout(
                        context,
                        updatedFarm,
                        ancestors,
                        primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Busca los ancestros del animal usando sus IDs
  Map<String, Cattle?> _fetchAncestors(Cattle animal, Farm farm) {
    Cattle? padre;
    Cattle? madre;
    Cattle? abueloPaterno;
    Cattle? abuelaPaterna;
    Cattle? abueloMaterno;
    Cattle? abuelaMaterna;

    // Buscar padre
    if (animal.idPadre != null && animal.idPadre!.isNotEmpty) {
      try {
        padre = farm.cattle.firstWhere((c) => c.id == animal.idPadre);
      } catch (e) {
        padre = null;
      }
    }

    // Buscar madre
    if (animal.idMadre != null && animal.idMadre!.isNotEmpty) {
      try {
        madre = farm.cattle.firstWhere((c) => c.id == animal.idMadre);
      } catch (e) {
        madre = null;
      }
    }

    // Buscar abuelos paternos
    if (padre != null) {
      if (padre.idPadre != null && padre.idPadre!.isNotEmpty) {
        try {
          abueloPaterno = farm.cattle.firstWhere((c) => c.id == padre!.idPadre);
        } catch (e) {
          abueloPaterno = null;
        }
      }
      if (padre.idMadre != null && padre.idMadre!.isNotEmpty) {
        try {
          abuelaPaterna = farm.cattle.firstWhere((c) => c.id == padre!.idMadre);
        } catch (e) {
          abuelaPaterna = null;
        }
      }
    }

    // Buscar abuelos maternos
    if (madre != null) {
      if (madre.idPadre != null && madre.idPadre!.isNotEmpty) {
        try {
          abueloMaterno = farm.cattle.firstWhere((c) => c.id == madre!.idPadre);
        } catch (e) {
          abueloMaterno = null;
        }
      }
      if (madre.idMadre != null && madre.idMadre!.isNotEmpty) {
        try {
          abuelaMaterna = farm.cattle.firstWhere((c) => c.id == madre!.idMadre);
        } catch (e) {
          abuelaMaterna = null;
        }
      }
    }

    return {
      'padre': padre,
      'madre': madre,
      'abueloPaterno': abueloPaterno,
      'abuelaPaterna': abuelaPaterna,
      'abueloMaterno': abueloMaterno,
      'abuelaMaterna': abuelaMaterna,
    };
  }

  Widget _buildTreeLayout(
    BuildContext context,
    Farm farm,
    Map<String, Cattle?> ancestors,
    Color primaryColor,
  ) {
    final padre = ancestors['padre'];
    final madre = ancestors['madre'];
    final abueloPaterno = ancestors['abueloPaterno'];
    final abuelaPaterna = ancestors['abuelaPaterna'];
    final abueloMaterno = ancestors['abueloMaterno'];
    final abuelaMaterna = ancestors['abuelaMaterna'];

    final hasGrandparents = abueloPaterno != null ||
        abuelaPaterna != null ||
        abueloMaterno != null ||
        abuelaMaterna != null;

    return SizedBox(
      width: hasGrandparents ? 900 : 600,
      height: hasGrandparents ? 550 : 400,
      child: CustomPaint(
        painter: PedigreeTreePainter(
          cattle: cattle,
          padre: padre,
          madre: madre,
          abueloPaterno: abueloPaterno,
          abuelaPaterna: abuelaPaterna,
          abueloMaterno: abueloMaterno,
          abuelaMaterna: abuelaMaterna,
          primaryColor: primaryColor,
        ),
        child: Stack(
          children: [
            // Nivel 1: Abuelos (si existen)
            if (hasGrandparents) ...[
              // Abuelos paternos (izquierda)
              Positioned(
                left: 50,
                top: 30,
                child: PedigreeCard(
                  animal: abueloPaterno,
                  relationship: 'Abuelo Paterno',
                  primaryColor: primaryColor,
                  onTap: abueloPaterno != null
                      ? () => _navigateToProfile(context, farm, abueloPaterno)
                      : null,
                ),
              ),
              Positioned(
                left: 220,
                top: 30,
                child: PedigreeCard(
                  animal: abuelaPaterna,
                  relationship: 'Abuela Paterna',
                  primaryColor: primaryColor,
                  onTap: abuelaPaterna != null
                      ? () => _navigateToProfile(context, farm, abuelaPaterna)
                      : null,
                ),
              ),
              // Abuelos maternos (derecha)
              Positioned(
                left: 550,
                top: 30,
                child: PedigreeCard(
                  animal: abueloMaterno,
                  relationship: 'Abuelo Materno',
                  primaryColor: primaryColor,
                  onTap: abueloMaterno != null
                      ? () => _navigateToProfile(context, farm, abueloMaterno)
                      : null,
                ),
              ),
              Positioned(
                left: 720,
                top: 30,
                child: PedigreeCard(
                  animal: abuelaMaterna,
                  relationship: 'Abuela Materna',
                  primaryColor: primaryColor,
                  onTap: abuelaMaterna != null
                      ? () => _navigateToProfile(context, farm, abuelaMaterna)
                      : null,
                ),
              ),
            ],

            // Nivel 2: Padres
            Positioned(
              left: hasGrandparents ? 120 : 50,
              top: hasGrandparents ? 220 : 50,
              child: PedigreeCard(
                animal: padre,
                relationship: 'Padre',
                primaryColor: primaryColor,
                onTap: padre != null
                    ? () => _navigateToProfile(context, farm, padre)
                    : null,
              ),
            ),
            Positioned(
              left: hasGrandparents ? 600 : 400,
              top: hasGrandparents ? 220 : 50,
              child: PedigreeCard(
                animal: madre,
                relationship: 'Madre',
                primaryColor: primaryColor,
                onTap: madre != null
                    ? () => _navigateToProfile(context, farm, madre)
                    : null,
              ),
            ),

            // Nivel 3: Animal actual (centro, destacado)
            Positioned(
              left: hasGrandparents ? 360 : 225,
              top: hasGrandparents ? 420 : 250,
              child: PedigreeCard(
                animal: cattle,
                relationship: 'Animal Actual',
                primaryColor: primaryColor,
                isCurrent: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, Farm farm, Cattle animal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CattleProfileScreen(
          farm: farm,
          cattle: animal,
        ),
      ),
    );
  }
}

class PedigreeTreePainter extends CustomPainter {
  final Cattle cattle;
  final Cattle? padre;
  final Cattle? madre;
  final Cattle? abueloPaterno;
  final Cattle? abuelaPaterna;
  final Cattle? abueloMaterno;
  final Cattle? abuelaMaterna;
  final Color primaryColor;

  PedigreeTreePainter({
    required this.cattle,
    this.padre,
    this.madre,
    this.abueloPaterno,
    this.abuelaPaterna,
    this.abueloMaterno,
    this.abuelaMaterna,
    this.primaryColor = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final hasGrandparents = abueloPaterno != null ||
        abuelaPaterna != null ||
        abueloMaterno != null ||
        abuelaMaterna != null;

    // Posiciones calculadas (matching con el Stack)
    final animalX = hasGrandparents ? 360.0 : 225.0;
    final animalY = hasGrandparents ? 420.0 : 250.0;
    final animalCenterX = animalX + 70; // Centro de la tarjeta (140/2)
    final animalCenterY = animalY + 60; // Aproximado

    // Líneas desde padres al animal actual
    if (padre != null) {
      final padreX = hasGrandparents ? 120.0 : 50.0;
      final padreY = hasGrandparents ? 220.0 : 50.0;
      final padreCenterX = padreX + 70;
      final padreCenterY = padreY + 60;

      // Línea vertical desde el padre
      canvas.drawLine(
        Offset(padreCenterX, padreCenterY + 60),
        Offset(padreCenterX, animalCenterY - 60),
        paint,
      );
      // Línea horizontal hacia el animal
      canvas.drawLine(
        Offset(padreCenterX, animalCenterY - 60),
        Offset(animalCenterX, animalCenterY - 60),
        paint,
      );
      // Línea vertical hacia el animal
      canvas.drawLine(
        Offset(animalCenterX, animalCenterY - 60),
        Offset(animalCenterX, animalCenterY),
        paint,
      );
    }

    if (madre != null) {
      final madreX = hasGrandparents ? 600.0 : 400.0;
      final madreY = hasGrandparents ? 220.0 : 50.0;
      final madreCenterX = madreX + 70;
      final madreCenterY = madreY + 60;

      // Línea vertical desde la madre
      canvas.drawLine(
        Offset(madreCenterX, madreCenterY + 60),
        Offset(madreCenterX, animalCenterY - 60),
        paint,
      );
      // Línea horizontal hacia el animal
      canvas.drawLine(
        Offset(madreCenterX, animalCenterY - 60),
        Offset(animalCenterX, animalCenterY - 60),
        paint,
      );
      // Línea vertical hacia el animal
      canvas.drawLine(
        Offset(animalCenterX, animalCenterY - 60),
        Offset(animalCenterX, animalCenterY),
        paint,
      );
    }

    // Líneas desde abuelos a padres (si existen)
    if (hasGrandparents && padre != null) {
      final padreX = 120.0;
      final padreY = 220.0;
      final padreCenterX = padreX + 70;
      final padreCenterY = padreY + 60;

      // Línea desde abuelo paterno
      if (abueloPaterno != null) {
        final abueloX = 50.0;
        final abueloY = 30.0;
        final abueloCenterX = abueloX + 70;
        final abueloCenterY = abueloY + 60;

        canvas.drawLine(
          Offset(abueloCenterX, abueloCenterY + 60),
          Offset(abueloCenterX, padreCenterY - 60),
          paint,
        );
        canvas.drawLine(
          Offset(abueloCenterX, padreCenterY - 60),
          Offset(padreCenterX, padreCenterY - 60),
          paint,
        );
        canvas.drawLine(
          Offset(padreCenterX, padreCenterY - 60),
          Offset(padreCenterX, padreCenterY),
          paint,
        );
      }

      // Línea desde abuela paterna
      if (abuelaPaterna != null) {
        final abuelaX = 220.0;
        final abuelaY = 30.0;
        final abuelaCenterX = abuelaX + 70;
        final abuelaCenterY = abuelaY + 60;

        canvas.drawLine(
          Offset(abuelaCenterX, abuelaCenterY + 60),
          Offset(abuelaCenterX, padreCenterY - 60),
          paint,
        );
        canvas.drawLine(
          Offset(abuelaCenterX, padreCenterY - 60),
          Offset(padreCenterX, padreCenterY - 60),
          paint,
        );
        canvas.drawLine(
          Offset(padreCenterX, padreCenterY - 60),
          Offset(padreCenterX, padreCenterY),
          paint,
        );
      }
    }

    if (hasGrandparents && madre != null) {
      final madreX = 600.0;
      final madreY = 220.0;
      final madreCenterX = madreX + 70;
      final madreCenterY = madreY + 60;

      // Línea desde abuelo materno
      if (abueloMaterno != null) {
        final abueloX = 550.0;
        final abueloY = 30.0;
        final abueloCenterX = abueloX + 70;
        final abueloCenterY = abueloY + 60;

        canvas.drawLine(
          Offset(abueloCenterX, abueloCenterY + 60),
          Offset(abueloCenterX, madreCenterY - 60),
          paint,
        );
        canvas.drawLine(
          Offset(abueloCenterX, madreCenterY - 60),
          Offset(madreCenterX, madreCenterY - 60),
          paint,
        );
        canvas.drawLine(
          Offset(madreCenterX, madreCenterY - 60),
          Offset(madreCenterX, madreCenterY),
          paint,
        );
      }

      // Línea desde abuela materna
      if (abuelaMaterna != null) {
        final abuelaX = 720.0;
        final abuelaY = 30.0;
        final abuelaCenterX = abuelaX + 70;
        final abuelaCenterY = abuelaY + 60;

        canvas.drawLine(
          Offset(abuelaCenterX, abuelaCenterY + 60),
          Offset(abuelaCenterX, madreCenterY - 60),
          paint,
        );
        canvas.drawLine(
          Offset(abuelaCenterX, madreCenterY - 60),
          Offset(madreCenterX, madreCenterY - 60),
          paint,
        );
        canvas.drawLine(
          Offset(madreCenterX, madreCenterY - 60),
          Offset(madreCenterX, madreCenterY),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
