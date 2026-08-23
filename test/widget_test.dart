import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/data/data_sources/local/mock_data_source.dart';
import 'package:taskflow/data/data_sources/local/mock_scenerio.dart';
import 'package:taskflow/data/repositories/task_flowrepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  late MockDataSource dataSource;
  late TaskFlowRepository repository;
  setUp(() {
    dataSource = MockDataSource();
    repository = TaskFlowRepository(dataSource: dataSource);
  });

  group('TaskFlowRepository - Projects', () {
    test('loads projects for an organization', () async {
      final projects = await repository.getProjects('org_a1b2c3');

      expect(projects, isNotEmpty);

      for (final project in projects) {
        expect(project.orgId, 'org_a1b2c3');
      }
    });

    test('returns empty list for unknown organization', () async {
      final projects = await repository.getProjects('unknown_org');

      expect(projects, isEmpty);
    });
  });

  group('TaskFlowRepository - Tasks', () {
    test('loads tasks for a project', () async {
      final tasks = await repository.getTasks('proj_1001');

      expect(tasks, isNotEmpty);

      for (final task in tasks) {
        expect(task.projectId, 'proj_1001');
      }
    });

    test('returns empty list for unknown project', () async {
      final tasks = await repository.getTasks('unknown_project');

      expect(tasks, isEmpty);
    });
  });

  group('MockDataSource - Simulation', () {
    test('normal mode loads projects successfully', () async {
      dataSource.scenario = MockScenario.normal;

      final projects = await repository.getProjects('org_a1b2c3');

      expect(projects, isNotEmpty);
    });

    test('offline mode throws an error', () async {
      dataSource.scenario = MockScenario.offline;

      expect(() => repository.getProjects('org_a1b2c3'), throwsException);
    });

    test('timeout mode throws after delay', () async {
      dataSource.scenario = MockScenario.timeout;

      expect(
        () => repository.getProjects('org_a1b2c3'),
        throwsA(isA<Exception>()),
      );
    });

    test('not found mode throws an error', () async {
      dataSource.scenario = MockScenario.notFound;

      expect(() => repository.getProjects('org_a1b2c3'), throwsException);
    });
  });
}
