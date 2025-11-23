import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';
import '../models/reproduction_event.dart';
import 'reproduction_event_form_screen.dart';

class ReproductiveCheckupScreen extends StatelessWidget {
  final Farm farm;
  final Cattle cattle;

  const ReproductiveCheckupScreen({
    super.key,
    required this.farm,
    required this.cattle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chequeo reproductivo - ${cattle.name ?? cattle.identification ?? 'Vaca'}'),
        centerTitle: true,
        backgroundColor: farm.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _child) {
          final updatedFarm = farmProvider.farms.firstWhere(
            (f) => f.id == farm.id,
            orElse: () => farm,
          );

          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionCard(
                context,
                'Fecundación',
                Icons.favorite,
                Colors.pink,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReproductionEventFormScreen(
                        farm: updatedFarm,
                        cattle: cattle,
                        eventType: ReproductionEventType.insemination,
                      ),
                    ),
                  );
                },
              ),
              _buildActionCard(
                context,
                'Chequeo',
                Icons.check_circle,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReproductionEventFormScreen(
                        farm: updatedFarm,
                        cattle: cattle,
                        eventType: ReproductionEventType.pregnancy,
                      ),
                    ),
                  );
                },
              ),
              _buildActionCard(
                context,
                'Parto',
                Icons.child_care,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReproductionEventFormScreen(
                        farm: updatedFarm,
                        cattle: cattle,
                        eventType: ReproductionEventType.calving,
                      ),
                    ),
                  );
                },
              ),
              _buildActionCard(
                context,
                'Aborto',
                Icons.warning,
                Colors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReproductionEventFormScreen(
                        farm: updatedFarm,
                        cattle: cattle,
                        eventType: ReproductionEventType.abortion,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}























