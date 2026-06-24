import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/presentation/walkthrough_controller.dart';
import '../features/onboarding/presentation/walkthrough_keys.dart';
import '../features/onboarding/presentation/walkthrough_step.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/project/presentation/screens/project_selection_screen.dart';
import '../features/project/presentation/screens/create_project_screen.dart';
import '../features/project/presentation/screens/edit_project_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/expense/presentation/screens/expense_screen.dart';
import '../features/expense/presentation/screens/expense_detail_screen.dart';
import '../features/expense/presentation/screens/add_edit_expense_screen.dart';
import '../features/material/presentation/screens/material_screen.dart';
import '../features/material/presentation/screens/material_detail_screen.dart';
import '../features/material/presentation/screens/add_edit_material_screen.dart';
import '../features/report/domain/report_type.dart';
import '../features/report/presentation/screens/reports_screen.dart';
import '../features/report/presentation/screens/pdf_viewer_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/manage_projects_screen.dart';
import '../features/backup/presentation/screens/data_management_screen.dart';
import '../features/backup/presentation/screens/import_preview_screen.dart';
import '../features/settings/presentation/screens/default_project_screen.dart';
import '../features/settings/presentation/screens/expense_categories_screen.dart';
import '../features/settings/presentation/screens/currency_screen.dart';
import '../features/settings/presentation/screens/date_format_screen.dart';
import '../features/settings/presentation/screens/theme_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../features/settings/presentation/screens/terms_screen.dart';
import '../features/settings/presentation/screens/contact_support_screen.dart';
import '../features/stage/presentation/screens/stages_screen.dart';
import '../features/stage/presentation/screens/stage_detail_screen.dart';
import '../features/stage/presentation/screens/add_edit_stage_screen.dart';
import '../features/photo/presentation/screens/photos_screen.dart';
import '../features/photo/presentation/screens/photo_detail_screen.dart';

part 'route_names.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutePaths.root,
  routes: [
    GoRoute(
      path: AppRoutePaths.root,
      name: AppRouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    // Top-level import entry point (Home screen "Import Project" action). No
    // active project context needed; reuses the Settings import preview screen.
    GoRoute(
      path: '/import-project',
      name: AppRouteNames.importProject,
      builder: (context, state) {
        final zipPath = state.extra as String? ?? '';
        return ImportPreviewScreen(projectId: 0, zipPath: zipPath);
      },
    ),
    GoRoute(
      path: AppRoutePaths.projects,
      name: AppRouteNames.projects,
      builder: (context, state) => const ProjectSelectionScreen(),
      routes: [
        GoRoute(
          path: 'create',
          name: AppRouteNames.createProject,
          builder: (context, state) => const CreateProjectScreen(),
        ),
        GoRoute(
          path: ':id/edit',
          name: AppRouteNames.editProject,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return EditProjectScreen(projectId: id);
          },
        ),
        GoRoute(
          path: ':id/stages',
          name: AppRouteNames.stages,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return StagesScreen(projectId: id);
          },
          routes: [
            GoRoute(
              path: 'add',
              name: AppRouteNames.addStage,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return AddEditStageScreen(projectId: id);
              },
            ),
            GoRoute(
              path: ':stageId',
              name: AppRouteNames.stageDetail,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                final stageId = int.parse(state.pathParameters['stageId']!);
                return StageDetailScreen(projectId: id, stageId: stageId);
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  name: AppRouteNames.editStage,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    final stageId =
                        int.parse(state.pathParameters['stageId']!);
                    return AddEditStageScreen(
                      projectId: id,
                      stageId: stageId,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: ':id/photos',
          name: AppRouteNames.photos,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final stageId = state.uri.queryParameters['stageId'] != null
                ? int.tryParse(state.uri.queryParameters['stageId']!)
                : null;
            return PhotosScreen(projectId: id, stageId: stageId);
          },
          routes: [
            GoRoute(
              path: ':photoId',
              name: AppRouteNames.photoDetail,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                final photoId =
                    int.parse(state.pathParameters['photoId']!);
                final stageId = state.uri.queryParameters['stageId'] != null
                    ? int.tryParse(state.uri.queryParameters['stageId']!)
                    : null;
                return PhotoDetailScreen(
                  projectId: id,
                  photoId: photoId,
                  stageId: stageId,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: ':id/manage-projects',
          name: AppRouteNames.manageProjects,
          builder: (context, state) => const ManageProjectsScreen(),
        ),
        GoRoute(
          path: ':id/data-management',
          name: AppRouteNames.dataManagement,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return DataManagementScreen(projectId: id);
          },
          routes: [
            GoRoute(
              path: 'import-preview',
              name: AppRouteNames.importPreview,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                final zipPath = state.extra as String? ?? '';
                return ImportPreviewScreen(projectId: id, zipPath: zipPath);
              },
            ),
          ],
        ),
        GoRoute(
          path: ':id/default-project',
          name: AppRouteNames.defaultProject,
          builder: (context, state) => const DefaultProjectScreen(),
        ),
        GoRoute(
          path: ':id/expense-categories',
          name: AppRouteNames.expenseCategories,
          builder: (context, state) => const ExpenseCategoriesScreen(),
        ),
        GoRoute(
          path: ':id/currency',
          name: AppRouteNames.currency,
          builder: (context, state) => const CurrencyScreen(),
        ),
        GoRoute(
          path: ':id/date-format',
          name: AppRouteNames.dateFormat,
          builder: (context, state) => const DateFormatScreen(),
        ),
        GoRoute(
          path: ':id/theme',
          name: AppRouteNames.theme,
          builder: (context, state) => const ThemeScreen(),
        ),
        GoRoute(
          path: ':id/about',
          name: AppRouteNames.about,
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: ':id/privacy-policy',
          name: AppRouteNames.privacyPolicy,
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: ':id/terms',
          name: AppRouteNames.terms,
          builder: (context, state) => const TermsScreen(),
        ),
        GoRoute(
          path: ':id/contact-support',
          name: AppRouteNames.contactSupport,
          builder: (context, state) => const ContactSupportScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            final id = int.parse(
              state.pathParameters['id'] ?? '0',
            );
            return _ProjectShell(projectId: id, child: child);
          },
          routes: [
            GoRoute(
              path: ':id/dashboard',
              name: AppRouteNames.dashboard,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return DashboardScreen(projectId: id);
              },
            ),
            GoRoute(
              path: ':id/expenses',
              name: AppRouteNames.expenses,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ExpenseScreen(projectId: id);
              },
              routes: [
                GoRoute(
                  path: 'add',
                  name: AppRouteNames.addExpense,
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return AddEditExpenseScreen(projectId: id);
                  },
                ),
                GoRoute(
                  path: ':expenseId',
                  name: AppRouteNames.expenseDetail,
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    final expId =
                        int.parse(state.pathParameters['expenseId']!);
                    return ExpenseDetailScreen(projectId: id, expenseId: expId);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      name: AppRouteNames.editExpense,
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        final expId =
                            int.parse(state.pathParameters['expenseId']!);
                        return AddEditExpenseScreen(
                          projectId: id,
                          expenseId: expId,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: ':id/materials',
              name: AppRouteNames.materials,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return MaterialScreen(projectId: id);
              },
              routes: [
                GoRoute(
                  path: 'add',
                  name: AppRouteNames.addMaterial,
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return AddEditMaterialScreen(projectId: id);
                  },
                ),
                GoRoute(
                  path: ':materialId',
                  name: AppRouteNames.materialDetail,
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    final matId = int.parse(state.pathParameters['materialId']!);
                    return MaterialDetailScreen(projectId: id, materialId: matId);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      name: AppRouteNames.editMaterial,
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        final matId =
                            int.parse(state.pathParameters['materialId']!);
                        return AddEditMaterialScreen(
                          projectId: id,
                          materialId: matId,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: ':id/reports',
              name: AppRouteNames.reports,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ReportsScreen(projectId: id);
              },
              routes: [
                GoRoute(
                  path: 'pdf',
                  name: AppRouteNames.pdfViewer,
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    final type = ReportType.fromId(
                        state.uri.queryParameters['type']);
                    return PdfViewerScreen(projectId: id, reportType: type);
                  },
                ),
              ],
            ),
            GoRoute(
              path: ':id/settings',
              name: AppRouteNames.projectSettings,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return SettingsScreen(projectId: id);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

class _ProjectShell extends StatelessWidget {
  const _ProjectShell({required this.projectId, required this.child});

  final int projectId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(projectId: projectId),
    );
  }
}

class _BottomNav extends ConsumerStatefulWidget {
  const _BottomNav({required this.projectId});

  final int projectId;

  @override
  ConsumerState<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends ConsumerState<_BottomNav> {
  static const _tabs = [
    (icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    (icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Expenses'),
    (icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Materials'),
    (icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Reports'),
    (icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ];

  // Walkthrough spotlight keys per highlighted tab index.
  static final _navKeys = {
    1: WalkthroughKeys.navExpenses,
    2: WalkthroughKeys.navMaterials,
    3: WalkthroughKeys.navReports,
  };

  int _locationToIndex(String location) {
    if (location.contains('/dashboard')) return 0;
    if (location.contains('/expenses')) return 1;
    if (location.contains('/materials')) return 2;
    if (location.contains('/reports')) return 3;
    if (location.contains('/settings')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    final routes = [
      AppRouteNames.dashboard,
      AppRouteNames.expenses,
      AppRouteNames.materials,
      AppRouteNames.reports,
      AppRouteNames.projectSettings,
    ];
    context.goNamed(routes[index],
        pathParameters: {'id': widget.projectId.toString()});
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    // Spotlight the relevant tab when its walkthrough step is active.
    final step = ref.watch(walkthroughControllerProvider);
    final stepForKey = {
      WalkStep.expensesTab: WalkthroughKeys.navExpenses,
      WalkStep.materialsTab: WalkthroughKeys.navMaterials,
      WalkStep.reportsTab: WalkthroughKeys.navReports,
    };
    if (stepForKey.containsKey(step)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(walkthroughControllerProvider.notifier).maybeShowCoach(
              context,
              step,
              key: stepForKey[step]!,
              shape: ShapeLightFocus.Circle,
              align: ContentAlign.top,
            );
      });
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => _onTap(context, i),
      items: [
        for (var i = 0; i < _tabs.length; i++)
          BottomNavigationBarItem(
            icon: KeyedSubtree(
              key: _navKeys[i],
              child: Icon(_tabs[i].icon),
            ),
            activeIcon: Icon(_tabs[i].activeIcon),
            label: _tabs[i].label,
          ),
      ],
    );
  }
}
