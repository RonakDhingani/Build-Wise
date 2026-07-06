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
import '../features/settings/presentation/screens/web_view_screen.dart';
import '../features/contact_support/screens/contact_support_screen.dart';
import '../constants/app_constants.dart';
import '../features/stage/presentation/screens/stages_screen.dart';
import '../features/stage/presentation/screens/stage_detail_screen.dart';
import '../features/stage/presentation/screens/add_edit_stage_screen.dart';
import '../features/photo/presentation/screens/photos_screen.dart';
import '../features/photo/presentation/screens/photo_detail_screen.dart';

part 'route_names.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

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
          builder: (context, state) => const WebViewScreen(
            title: 'Privacy Policy',
            url: AppConstants.privacyPolicyUrl,
          ),
        ),
        GoRoute(
          path: ':id/terms',
          name: AppRouteNames.terms,
          builder: (context, state) => const WebViewScreen(
            title: 'Terms & Conditions',
            url: AppConstants.termsUrl,
          ),
        ),
        GoRoute(
          path: ':id/contact-support',
          name: AppRouteNames.contactSupport,
          builder: (context, state) => const ContactSupportScreen(),
        ),
        // StatefulShellRoute (not plain ShellRoute): each branch gets its own
        // persistent Navigator held in an IndexedStack, and `_ProjectShell`
        // (the Scaffold + bottom nav) is built ONCE by go_router and never
        // torn down/recreated on navigation — including when switching the
        // active project's `:id` (switchTo/delete). A plain ShellRoute rebuilds
        // the shell as part of each leaf page, so switching `:id` produced a
        // real (if brief) page transition with TWO `_ProjectShell`/`_BottomNav`
        // instances alive at once, both claiming the same static
        // `WalkthroughKeys.nav*` GlobalKeys (and Flutter's own internal
        // per-item bottom-nav keys) → "Duplicate GlobalKeys" / PopScope
        // reactivate crashes. A persistent shell has no such transition.
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            final id = int.parse(state.pathParameters['id'] ?? '0');
            return _ProjectShell(projectId: id, navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              // go_router can't derive a param-free default location for a
              // branch whose first route needs `:id`, so it must be given
              // explicitly. Only used as a fallback if this branch is ever
              // switched to via goBranch() before being visited — the app
              // always navigates here with a concrete id via goNamed, so
              // this placeholder is never actually rendered.
              initialLocation: '/projects/0/dashboard',
              routes: [
                GoRoute(
                  path: ':id/dashboard',
                  name: AppRouteNames.dashboard,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return DashboardScreen(projectId: id);
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              initialLocation: '/projects/0/expenses',
              routes: [
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
                        return ExpenseDetailScreen(
                          projectId: id,
                          expenseId: expId,
                        );
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
              ],
            ),
            StatefulShellBranch(
              initialLocation: '/projects/0/materials',
              routes: [
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
                        final matId =
                            int.parse(state.pathParameters['materialId']!);
                        return MaterialDetailScreen(
                          projectId: id,
                          materialId: matId,
                        );
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
              ],
            ),
            StatefulShellBranch(
              initialLocation: '/projects/0/reports',
              routes: [
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
              ],
            ),
            StatefulShellBranch(
              initialLocation: '/projects/0/settings',
              routes: [
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
    ),
  ],
);

class _ProjectShell extends StatelessWidget {
  const _ProjectShell({required this.projectId, required this.navigationShell});

  final int projectId;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final onDashboard = navigationShell.currentIndex == 0;
    // System back: from any non-Dashboard tab, first switch to Dashboard;
    // from Dashboard, allow the pop (exit the project → project list).
    return PopScope(
      canPop: onDashboard,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Guard against a back event arriving while this shell is being torn
        // down by a project switch/delete — navigating on a deactivated context
        // throws ("Looking up a deactivated widget's ancestor is unsafe").
        if (!context.mounted) return;
        context.goNamed(
          AppRouteNames.dashboard,
          pathParameters: {'id': projectId.toString()},
        );
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: _BottomNav(
          projectId: projectId,
          navigationShell: navigationShell,
        ),
      ),
    );
  }
}

class _BottomNav extends ConsumerStatefulWidget {
  const _BottomNav({required this.projectId, required this.navigationShell});

  final int projectId;
  final StatefulNavigationShell navigationShell;

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

  // Which tab index each walkthrough step spotlights.
  static const _stepTabIndex = {
    WalkStep.expensesTab: 1,
    WalkStep.materialsTab: 2,
    WalkStep.reportsTab: 3,
  };

  // Keyed on the whole nav bar so we can compute an individual tab's rect
  // (icon + label) for a proper rounded-rect spotlight instead of a bare
  // circle around just the icon.
  final GlobalKey _navBarKey = GlobalKey(debugLabel: 'wt_bottomNav');

  void _onTap(BuildContext context, int index) {
    // Already on this tab — no-op (goNamed to the current location is
    // unnecessary and, pre-StatefulShellRoute, used to cause duplicate
    // GlobalKeys; harmless now but still wasted work).
    if (index == widget.navigationShell.currentIndex) return;

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
    final currentIndex = widget.navigationShell.currentIndex;

    // Spotlight the relevant tab when its walkthrough step is active. The
    // highlight covers the entire tab cell (icon + label) as a rounded rect,
    // computed from the nav bar's own geometry so it lines up on every device.
    final step = ref.watch(walkthroughControllerProvider);
    if (_stepTabIndex.containsKey(step)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final navBox =
            _navBarKey.currentContext?.findRenderObject() as RenderBox?;
        if (navBox == null || !navBox.hasSize) return;
        final origin = navBox.localToGlobal(Offset.zero);
        final tabWidth = navBox.size.width / _tabs.length;
        final index = _stepTabIndex[step]!;
        final tabPosition = TargetPosition(
          Size(tabWidth, navBox.size.height),
          Offset(origin.dx + tabWidth * index, origin.dy),
        );
        ref.read(walkthroughControllerProvider.notifier).maybeShowCoach(
              context,
              step,
              targetPosition: tabPosition,
              shape: ShapeLightFocus.RRect,
              radius: 16,
              focusPadding: 6,
            );
      });
    }

    return BottomNavigationBar(
      key: _navBarKey,
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
