import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/data/data_sources/local/mock_data_source.dart';
import 'package:taskflow/data/data_sources/local/mock_scenerio.dart';

class QaSimulationScreen extends StatelessWidget {
  const QaSimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataSource = context.read<MockDataSource>();

    return Scaffold(
      appBar: AppBar(title: const Text('QA Simulation')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Simulation Mode',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'Select a mode to simulate different data-layer '
            'conditions for reviewer testing.',
          ),

          const SizedBox(height: 24),

          _ScenarioCard(
            icon: Icons.check_circle_outline,
            title: 'Normal',
            description: 'Normal application behavior.',
            onTap: () {
              dataSource.scenario = MockScenario.normal;
              _showMessage(context, 'Normal mode enabled');
            },
          ),

          _ScenarioCard(
            icon: Icons.wifi_off,
            title: 'Offline',
            description: 'Simulates an offline data source.',
            onTap: () {
              dataSource.scenario = MockScenario.offline;
              _showMessage(context, 'Offline mode enabled');
            },
          ),

          _ScenarioCard(
            icon: Icons.timer_outlined,
            title: 'Timeout',
            description: 'Simulates a delayed request followed by timeout.',
            onTap: () {
              dataSource.scenario = MockScenario.timeout;
              _showMessage(context, 'Timeout mode enabled');
            },
          ),

          _ScenarioCard(
            icon: Icons.search_off,
            title: 'Not Found',
            description: 'Simulates a resource-not-found error.',
            onTap: () {
              dataSource.scenario = MockScenario.notFound;
              _showMessage(context, 'Not Found mode enabled');
            },
          ),

          _ScenarioCard(
            icon: Icons.error_outline,
            title: 'Validation Error',
            description: 'Simulates a validation failure during writes.',
            onTap: () {
              dataSource.scenario = MockScenario.validationError;
              _showMessage(context, 'Validation Error mode enabled');
            },
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'After selecting a scenario, return to the '
                      'Projects or Tasks screen and perform the '
                      'relevant operation.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ScenarioCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ScenarioCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
