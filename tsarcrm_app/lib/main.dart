
import 'package:flutter/material.dart';
import 'api_client.dart';

final globalApiClient = ApiClient();

void main() {
  runApp(WaiterApp(apiClient: globalApiClient));
}

/// Корневой виджет приложения.
class WaiterApp extends StatefulWidget {
  const WaiterApp({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<WaiterApp> createState() => _WaiterAppState();
}

class _WaiterAppState extends State<WaiterApp> {
  AuthUser? _user;
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFFF8A00); // тёплый оранжевый как в web-прототипе
    const darkBackground = Color(0xFF0C1B2E);
    const darkSurface = Color(0xFF12253B);
    const lightBackground = Color(0xFFF7F7FA);

    final ThemeData theme = _isDarkMode
        ? ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.dark,
            ).copyWith(
              surface: darkSurface,
              background: darkBackground,
            ),
            scaffoldBackgroundColor: darkBackground,
            cardColor: darkSurface,
            appBarTheme: const AppBarTheme(
              backgroundColor: darkBackground,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: seed, width: 1.6),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: seed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: darkSurface,
              indicatorColor: seed,
              iconTheme: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const IconThemeData(color: Colors.white);
                }
                return IconThemeData(color: Colors.white.withOpacity(0.7));
              }),
              labelTextStyle: MaterialStateProperty.all(
                const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: darkSurface,
              surfaceTintColor: Colors.transparent,
            ),
          )
        : ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.light,
            ).copyWith(
              surface: Colors.white,
              background: lightBackground,
            ),
            scaffoldBackgroundColor: lightBackground,
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: seed, width: 1.6),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: seed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: seed,
              iconTheme: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const IconThemeData(color: Colors.white);
                }
                return const IconThemeData(color: Color(0xFF9CA3AF));
              }),
              labelTextStyle: MaterialStateProperty.all(
                const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
          );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant CRM',
      theme: theme,
      home: _user == null
          ? LoginScreen(
              apiClient: widget.apiClient,
              onLoggedIn: (user) => setState(() => _user = user),
            )
          : HomeShell(
              apiClient: widget.apiClient,
              user: _user!,
              isDarkMode: _isDarkMode,
              onToggleTheme: () =>
                  setState(() => _isDarkMode = !_isDarkMode),
              onLogout: () => setState(() => _user = null),
            ),
    );
  }
}

// ----------------- LOGIN -----------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.apiClient,
    required this.onLoggedIn,
  });

  final ApiClient apiClient;
  final ValueChanged<AuthUser> onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await widget.apiClient
          .login(username: _loginCtrl.text.trim(), password: _passCtrl.text);
      if (!mounted) return;
      widget.onLoggedIn(user);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Не удалось выполнить вход');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 44,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Вход в CRM',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Авторизуйтесь, чтобы работать со столами и заказами',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: cs.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _loginCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Логин',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Введите логин'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Пароль',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Введите пароль'
                            : null,
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: cs.error),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Войти'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- HOME SHELL -----------------

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.apiClient,
    required this.user,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onLogout,
  });

  final ApiClient apiClient;
  final AuthUser user;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      TablesScreen(apiClient: widget.apiClient),
      MenuScreen(apiClient: widget.apiClient),
      ProfileScreen(
        user: widget.user,
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onToggleTheme,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Restaurant CRM',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.table_bar_outlined),
            selectedIcon: Icon(Icons.table_bar),
            label: 'Столы',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Меню',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

// ----------------- TABLES SCREEN -----------------

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesData {
  final List<ApiTable> tables;
  final List<ApiOrder> orders;

  _TablesData(this.tables, this.orders);
}

class _TablesScreenState extends State<TablesScreen> {
  late Future<_TablesData> _future;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<_TablesData> _load() async {
    // Загружаем только карту столов (TableMap) из CRM.
    final tables = await widget.apiClient.getTables();

     // Дополнительно загружаем список заказов, чтобы иметь возможность
    // закрывать их прямо из модального окна деталей заказа.
    final orders = await widget.apiClient.getOrders();

    return _TablesData(
      tables,
      orders,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _showAddTableDialog() async {
    final numberCtrl = TextEditingController();
    final zoneCtrl = TextEditingController();
    final seatsCtrl = TextEditingController(text: '2');
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Новый стол'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: numberCtrl,
                  decoration: const InputDecoration(labelText: 'Номер стола'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Укажите номер' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: zoneCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Зона (зал, терраса...)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Укажите зону' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: seatsCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Количество мест'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('Создать'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final seats = int.tryParse(seatsCtrl.text) ?? 2;

    try {
      await widget.apiClient.createTable(
        number: numberCtrl.text.trim(),
        zone: zoneCtrl.text.trim(),
        seats: seats,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Стол создан')),
      );
      _reload();
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось создать стол')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<_TablesData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                String message = 'Ошибка загрузки столов';
                final error = snapshot.error;
                if (error is ApiException && error.statusCode == 401) {
                  message = 'Ошибка авторизации (401). Проверьте логин и пароль в CRM.';
                }
                return ListView(
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.error),
                      ),
                    ),
                  ],
                );
              }
              final data = snapshot.data;
              if (data == null || data.tables.isEmpty) {
                return ListView(
                  children: const [
                    SizedBox(height: 80),
                    Center(child: Text('Столов пока нет')),
                  ],
                );
              }

              const closedStatuses = {'completed', 'cancelled', 'deleted'};
              final byTable = <String, List<ApiOrder>>{};
              for (final o in data.orders) {
                if (closedStatuses.contains(o.status)) continue;
                final key = o.tableNumber ?? '';
                if (key.isEmpty) continue;
                byTable.putIfAbsent(key, () => []).add(o);
              }

              final tables = [...data.tables]
                ..sort((a, b) => a.number.compareTo(b.number));

              final query = _searchQuery.trim();
              final filteredTables = query.isEmpty
                  ? tables
                  : tables
                      .where((t) => t.number.toLowerCase().contains(query.toLowerCase()))
                      .toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Управление столами',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Следите за статусом и создавайте заказы',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: cs.onSurface.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Поиск по номеру стола',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTables.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82
                      ),
                      itemBuilder: (context, index) {
                        final table = filteredTables[index];
                        final tableOrders = byTable[table.number] ?? const <ApiOrder>[];
                        return _TableCard(
                          apiClient: widget.apiClient,
                          table: table,
                          orders: tableOrders,
                          onChanged: _reload,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.apiClient,
    required this.table,
    required this.orders,
    required this.onChanged,
  });

  final ApiClient apiClient;
  final ApiTable table;
  final List<ApiOrder> orders;
  final VoidCallback onChanged;

  String get tableNumber => table.number;

  bool _isOrderActive(ApiOrder order) {
    const closedStatuses = {'completed', 'cancelled', 'deleted'};
    return !closedStatuses.contains(order.status);
  }

  List<ApiOrder> get _activeOrders =>
      orders.where((order) => _isOrderActive(order)).toList();

  bool get hasActiveApiOrder => _activeOrders.isNotEmpty;

  Future<bool> _confirmCloseOrder(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Закрытие заказа'),
        content: const Text('Подтверждаете закрытие заказа?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Да'),
          ),
        ],
      ),
    );

    return result == true;
  }

  String get _statusLabel {
    switch (table.status) {
      case 'occupied':
        return 'Занят';
      case 'reserved':
        return 'Забронирован';
      case 'free':
      default:
        return 'Свободен';
    }
  }

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (table.status) {
      case 'occupied':
        return cs.error;
      case 'reserved':
        return cs.tertiary;
      case 'free':
      default:
        return const Color(0xFF16A34A);
    }
  }

  String _formatReservationTime(String raw) {
    if (raw.isEmpty) return '';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    final dt = parsed.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  Future<void> _openCreateOrder(BuildContext context) async {
    if (tableNumber == '—') return;

    // Новый заказ можно создавать только для свободного стола
    if (table.status != 'free') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Новый заказ можно создать только для свободного стола'),
        ),
      );
      return;
    }

    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CreateOrderDialog(
        apiClient: apiClient,
        tableNumber: tableNumber,
      ),
    );

    if (created == true) {
      onChanged();
    }
  }

  Future<void> _closeOrder(BuildContext context, ApiOrder order) async {
    try {
      // Меняем статус заказа на completed (закрыт) вместо удаления
      await apiClient.updateOrderStatus(order.id, 'completed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заказ ${order.id} закрыт')),
      );
      onChanged();
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось закрыть заказ')),
      );
    }
  }


  Future<void> _openOrderDetails(BuildContext context) async {
    final items = table.orders;
    final total = table.totalAmount ??
        items.fold<double>(0, (sum, item) => sum + item.amount);

    final hasCrmOrderOrReservation =
        items.isNotEmpty || total > 0 || table.reservation != null || table.status != 'free';

    if (!hasCrmOrderOrReservation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет данных о заказе для этого стола')),
      );
      return;
    }

    // Ищем активный заказ из общего списка заказов (/orders)
    final active = _activeOrders;
    ApiOrder? activeOrder;
    if (hasCrmOrderOrReservation && active.isNotEmpty) {
      active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      activeOrder = active.first;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B1728),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            final mutedTextColor = Colors.white.withOpacity(0.7);
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tableNumber == '—'
                              ? 'Заказ'
                              : 'Заказ для стола $tableNumber',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${item.amount.toStringAsFixed(0)} ₽',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${item.quantity} × ${item.price.toStringAsFixed(0)} ₽',
                              style: TextStyle(color: mutedTextColor),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.08)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Итого',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${total.toStringAsFixed(0)} ₽',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        // TODO: реализовать редактирование заказа через API таблиц/заказов
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Редактирование заказа пока не реализовано'),
                          ),
                        );
                      },
                      child: const Text('Редактировать заказ'),
                    ),
                  ),
                  if (activeOrder != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.08),
                        ),
                        onPressed: () async {
                          final confirmed = await _confirmCloseOrder(context);
                          if (confirmed) {
                            Navigator.of(context).pop();
                            await _closeOrder(context, activeOrder!);
                          }
                        },
                        child: const Text('Закрыть заказ'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openReservationDetails(BuildContext context) async {
    final reservation = table.reservation;
    

    if (reservation == null) return;

    final formattedTime = _formatReservationTime(reservation.time);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            tableNumber == '—' ? 'Бронь' : 'Бронь стола $tableNumber',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Дата и время',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(formattedTime.isEmpty ? reservation.time : formattedTime),
              const SizedBox(height: 8),
              const Text(
                'Контакт (имя/телефон)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(reservation.contact ?? '—'),
              const SizedBox(height: 8),
              const Text(
                'Количество гостей',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(reservation.guests.toString()),
              const SizedBox(height: 8),
              const Text(
                'Комментарий / предзаказ',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(reservation.preorder ?? '—'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Данные карты столов из CRM (используем только бронь)
    final reservation = table.reservation;
    final tableItems = table.orders;
    final tableTotal = table.totalAmount ??
        tableItems.fold<double>(0, (sum, item) => sum + item.amount);
    final hasTableOrder = tableItems.isNotEmpty || tableTotal > 0;
    final crmHasOrderOrReservation =
        hasTableOrder || reservation != null || table.status != 'free';

    // Заказ из общего списка заказов (API /orders)
    final apiOrders = crmHasOrderOrReservation ? _activeOrders : const <ApiOrder>[];
    final hasApiOrder = apiOrders.isNotEmpty;
    ApiOrder? lastOrder;
    if (hasApiOrder) {
      final sorted = [...apiOrders]..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
      lastOrder = sorted.first;
    }

    final statusColor = _statusColor(context);
    final formattedReservationTime =
        reservation != null ? _formatReservationTime(reservation.time) : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      _statusLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  if (hasApiOrder && lastOrder != null) {
                    _openOrderDetails(context);
                  } else if (reservation != null) {
                    _openReservationDetails(context);
                  } else {
                    _openCreateOrder(context);
                  }
                },
                icon: const Icon(Icons.more_horiz),
                tooltip: 'Детали',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tableNumber == '—' ? 'Без стола' : 'Стол $tableNumber',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (hasApiOrder && lastOrder != null)
            _OrderBadge(
              title: 'Активный заказ',
              subtitle: 'Итого: ${lastOrder.total.toStringAsFixed(0)} ₽',
              accent: cs.error,
              onTap: () => _openOrderDetails(context),
            )
          else if (hasTableOrder)
            _OrderBadge(
              title: 'Заказ CRM',
              subtitle: 'Сумма: ${tableTotal.toStringAsFixed(0)} ₽',
              accent: cs.primary,
              onTap: () => _openOrderDetails(context),
            )
          else if (reservation != null)
            _OrderBadge(
              title: 'Бронь',
              subtitle:
                   '${formattedReservationTime.isEmpty ? reservation.time : formattedReservationTime} • Гостей: ${reservation.guests}',
              accent: cs.tertiary,
              onTap: () => _openReservationDetails(context),
            )
          else
            Text(
              'Заказов пока нет',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (hasActiveApiOrder && lastOrder != null) {
                      _confirmCloseOrder(context).then((confirmed) {
                        if (confirmed) _closeOrder(context, lastOrder!);
                      });
                    } else if (hasApiOrder || hasTableOrder) {
                      _openOrderDetails(context);
                    } else if (reservation != null) {
                      _openReservationDetails(context);
                    } else {
                      _openCreateOrder(context);
                    }
                  },
                  icon: Icon(
                    hasActiveApiOrder
                        ? Icons.close_rounded
                        : Icons.receipt_long_outlined,
                    size: 18,
                  ),
                  label: Text(
                    hasActiveApiOrder
                        ? 'Закрыть заказ'
                        : hasApiOrder || hasTableOrder || reservation != null
                            ? 'Детали'
                            : 'Создать заказ',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderBadge extends StatelessWidget {
  const _OrderBadge({
    required this.title,
    required this.subtitle,
    required this.accent,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: accent.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }
}
class _PositionItem {
  _PositionItem({required this.menuItem, this.quantity = 1});

  final MenuItem menuItem;
  int quantity;

  double get total => menuItem.price * quantity;
}

class _OrderPositionModel {
  _OrderPositionModel({required this.index});

  final int index;
  final List<_PositionItem> items = [];
}

class _MenuSelection {
  _MenuSelection({required this.menuItem, required this.quantity});

  final MenuItem menuItem;
  final int quantity;
}

class _CreateOrderDialog extends StatefulWidget {
  const _CreateOrderDialog({
    required this.apiClient,
    required this.tableNumber,
  });

  final ApiClient apiClient;
  final String tableNumber;

  @override
  State<_CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends State<_CreateOrderDialog> {
  final List<_OrderPositionModel> _positions = [
    _OrderPositionModel(index: 1),
  ];
  bool _submitting = false;
  String? _error;

  double get _total {
    double sum = 0;
    for (final pos in _positions) {
      for (final item in pos.items) {
        sum += item.total;
      }
    }
    return sum;
  }

  Future<void> _addItemsToPosition(int index) async {
    final result = await showDialog<List<_MenuSelection>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MenuPickerDialog(apiClient: widget.apiClient),
    );
    if (result == null || result.isEmpty) return;

    setState(() {
      final position = _positions.firstWhere((p) => p.index == index);
      for (final sel in result) {
        final existing = position.items
            .where((i) => i.menuItem.id == sel.menuItem.id)
            .toList();
        if (existing.isEmpty) {
          position.items.add(
            _PositionItem(menuItem: sel.menuItem, quantity: sel.quantity),
          );
        } else {
          existing.first.quantity += sel.quantity;
        }
      }
    });
  }

  void _addPosition() {
    setState(() {
      _positions.add(
        _OrderPositionModel(index: _positions.length + 1),
      );
    });
  }

  void _removeItem(_OrderPositionModel pos, _PositionItem item) {
    setState(() {
      pos.items.remove(item);
    });
  }

  Future<void> _submit() async {
    final Map<String, int> totals = {};
    for (final pos in _positions) {
      for (final item in pos.items) {
        totals[item.menuItem.id] =
            (totals[item.menuItem.id] ?? 0) + item.quantity;
      }
    }
    if (totals.isEmpty) {
      setState(() {
        _error = 'Добавьте хотя бы одно блюдо';
      });
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    try {
      final items = totals.entries
          .map(
            (e) => CreateOrderItem(
              menuItemId: e.key,
              quantity: e.value,
            ),
          )
          .toList();
      final payload = CreateOrderPayload(
        customerName: 'Стол ${widget.tableNumber}',
        table: widget.tableNumber,
        items: items,
      );

      final res = await widget.apiClient.createOrder(payload);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Заказ ${res.order.id} создан • ${res.order.total.toStringAsFixed(0)} ₽',
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Не удалось создать заказ';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Заказ для стола ${widget.tableNumber}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed:
                        _submitting ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(color: cs.error, fontSize: 13),
                  ),
                ),
              Expanded(
                child: ListView(
                  children: [
                    for (final pos in _positions) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPositionCard(pos),
                      ),
                    ],
                    TextButton.icon(
                      onPressed: _addPosition,
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить позицию'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Общая сумма: ${_total.toStringAsFixed(0)} ₽',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Создать заказ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionCard(_OrderPositionModel pos) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Позиция ${pos.index}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (pos.items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Пока нет блюд',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            )
          else
            ...pos.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.menuItem.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.quantity} x ${item.menuItem.price.toStringAsFixed(0)} ₽ = ${item.total.toStringAsFixed(0)} ₽',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Theme.of(context).colorScheme.error,
                      onPressed: () => _removeItem(pos, item),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _addItemsToPosition(pos.index),
            icon: const Icon(Icons.add),
            label: const Text('Добавить блюдо...'),
          ),
        ],
      ),
    );
  }
}

class _MenuPickerDialog extends StatefulWidget {
  const _MenuPickerDialog({required this.apiClient});

  final ApiClient apiClient;

  @override
  State<_MenuPickerDialog> createState() => _MenuPickerDialogState();
}

class _MenuPickerDialogState extends State<_MenuPickerDialog> {
  late Future<MenuResponse> _future;
  final Map<String, int> _selectedQty = {};
  String _search = '';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _future = widget.apiClient.getMenu();
  }

  int get _totalSelected =>
      _selectedQty.values.fold(0, (prev, e) => prev + e);

  void _changeQty(String id, int delta) {
    setState(() {
      final current = _selectedQty[id] ?? 0;
      final next = (current + delta).clamp(0, 99);
      if (next == 0) {
        _selectedQty.remove(id);
      } else {
        _selectedQty[id] = next;
      }
    });
  }

  List<_MenuSelection> _buildResult(MenuResponse menu) {
    final Map<String, MenuItem> byId = {
      for (final item in menu.items) item.id: item,
    };
    final List<_MenuSelection> result = [];
    _selectedQty.forEach((id, qty) {
      final item = byId[id];
      if (item != null && qty > 0) {
        result.add(_MenuSelection(menuItem: item, quantity: qty));
      }
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Выбор блюда',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Поиск блюда...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _search = value.trim().toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                      child: const Text('Полное меню'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final menu = await _future;
                        final categories = menu.categories;
                        if (!mounted) return;
                        final selected = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'Выберите категорию',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  Flexible(
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: [
                                        for (final cat in categories)
                                          ListTile(
                                            title: Text(cat.name),
                                            onTap: () => Navigator.of(context)
                                                .pop(cat.id),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                        if (selected != null) {
                          setState(() {
                            _selectedCategoryId = selected;
                          });
                        }
                      },
                      icon: const Icon(Icons.tune),
                      label: const Text('Категории'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<MenuResponse>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                        child: Text('Не удалось загрузить меню'),
                      );
                    }
                    final menu = snapshot.data!;
                    final items = menu.items.where((item) {
                      if (!item.isActive || item.status == 'hidden') {
                        return false;
                      }
                      if (_selectedCategoryId != null &&
                          item.categoryId != _selectedCategoryId) {
                        return false;
                      }
                      if (_search.isNotEmpty &&
                          !item.name.toLowerCase().contains(_search)) {
                        return false;
                      }
                      return true;
                    }).toList();

                    if (items.isEmpty) {
                      return const Center(
                        child: Text('Блюда не найдены'),
                      );
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final qty = _selectedQty[item.id] ?? 0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: cs.surface.withOpacity(0.5),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.image_outlined),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.category.isNotEmpty
                                                ? item.category
                                                : 'Без категории',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: cs.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.price.toStringAsFixed(0)} ₽',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: qty > 0
                                          ? () => _changeQty(item.id, -1)
                                          : null,
                                    ),
                                    Text('$qty'),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.add_circle_outline),
                                      onPressed: () => _changeQty(item.id, 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _totalSelected == 0
                      ? null
                      : () async {
                          final menu = await _future;
                          final result = _buildResult(menu);
                          if (!mounted) return;
                          Navigator.of(context).pop(result);
                        },
                  child: Text('Добавить ($_totalSelected)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
// ----------------- MENU SCREEN -----------------

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<MenuResponse> _future;
  String _selectedCategoryId = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = widget.apiClient.getMenu();
  }

  Future<void> _reload() async {
    setState(() {
      _future = widget.apiClient.getMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<MenuResponse>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Text(
                    'Ошибка загрузки меню',
                    style: TextStyle(color: cs.error),
                  ),
                ),
              ],
            );
          }

          final menu = snapshot.data;
          if (menu == null) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                Center(child: Text('Меню пусто')),
              ],
            );
          }

          final activeItems = menu.items.where((item) {
            if (!item.isActive || item.status == 'hidden') return false;
            return true;
          }).toList();

          List<MenuItem> filtered = activeItems.where((item) {
            final matchesCategory =
                _selectedCategoryId == 'all' ||
                item.categoryId == _selectedCategoryId;
            final matchesSearch = _searchQuery.isEmpty ||
                item.name.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesCategory && matchesSearch;
          }).toList();

          filtered.sort((a, b) => a.name.compareTo(b.name));

          final selectedCategoryName = _selectedCategoryId == 'all'
              ? 'Категории'
              : (menu.categories
                      .firstWhere(
                        (c) => c.id == _selectedCategoryId,
                        orElse: () => MenuCategory(
                          id: '',
                          name: 'Категория',
                          description: '',
                        ),
                      )
                      .name);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant_menu, color: cs.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Меню',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Быстрый доступ к блюдам и категориям',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.onSurface.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Поиск блюда…',
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() => _selectedCategoryId = 'all');
                      },
                      child: const Text('Полное меню'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (menu.categories.isEmpty) return;
                        final selected = await showModalBottomSheet<String>(
                          context: context,
                          backgroundColor: Theme.of(context).cardColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Выберите категорию',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 12),
                                    ...menu.categories.map(
                                      (c) => Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: cs.surface.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          title: Text(c.name),
                                          onTap: () =>
                                              Navigator.of(context).pop(c.id),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop('all'),
                                            child: const Text('Сбросить'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: FilledButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Закрыть'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        if (selected != null) {
                          setState(() => _selectedCategoryId = selected);
                        }
                      },
                      icon: const Icon(Icons.tune),
                      label: Text(selectedCategoryName),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text(
                      'Блюда не найдены',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                )
              else
                ...filtered.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 74,
                          height: 74,
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.surfaceVariant.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.image_outlined),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 12, top: 14, bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.category.isNotEmpty
                                      ? item.category
                                      : 'Блюдо ресторана',
                                  style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.75),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cs.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        item.category.isNotEmpty
                                            ? item.category
                                            : 'Категория',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cs.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.stockQuantity} в наличии',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurface.withOpacity(0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${item.price.toStringAsFixed(0)} ₽',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }
}

// ----------------- PROFILE SCREEN -----------------

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onLogout,
  });

  final AuthUser user;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: cs.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName.isNotEmpty
                            ? user.fullName
                            : user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.roleName.isNotEmpty ? user.roleName : user.role,
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ProfileInfoRow(
                            icon: Icons.mail_outline,
                            label: 'Email',
                            value: user.email ?? 'Не указан',
                          ),
                          _ProfileInfoRow(
                            icon: Icons.badge_outlined,
                            label: 'Логин',
                            value: user.username,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Тема оформления',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDarkMode ? 'Тёмная' : 'Светлая',
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (_) => onToggleTheme(),
                ),
              ],
            ),
          ),  
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(
                Icons.logout,
                color: cs.error,
              ),
              label: Text(
                'Выйти из аккаунта',
                style: TextStyle(color: cs.error),
              ),
              onPressed: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- TABLE DETAILS SCREEN -----------------

class TableDetailsScreen extends StatefulWidget {
  const TableDetailsScreen({
    super.key,
    required this.apiClient,
    required this.tableNumber,
  });

  final ApiClient apiClient;
  final String tableNumber;

  @override
  State<TableDetailsScreen> createState() => _TableDetailsScreenState();
}

class _TableDetailsScreenState extends State<TableDetailsScreen> {
  late Future<List<ApiOrder>> _ordersFuture;
  late Future<MenuResponse> _menuFuture;
  final Map<String, int> _selectedQty = {};
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reloadAll();
  }

  void _reloadAll() {
    _ordersFuture = widget.apiClient.getOrders();
    _menuFuture = widget.apiClient.getMenu();
  }

  Future<void> _refresh() async {
    setState(_reloadAll);
  }

  Future<void> _submitOrder() async {
    final items = <CreateOrderItem>[];
    _selectedQty.forEach((id, qty) {
      if (qty > 0) {
        items.add(CreateOrderItem(menuItemId: id, quantity: qty));
      }
    });

    if (items.isEmpty) {
      setState(() {
        _error = 'Добавьте блюда в заказ';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final payload = CreateOrderPayload(
        customerName: 'Стол ${widget.tableNumber}',
        table: widget.tableNumber,
        items: items,
      );

      final res = await widget.apiClient.createOrder(payload);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заказ ${res.order.id} создан')),
      );

      setState(() {
        _selectedQty.clear();
      });
      await _refresh();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Не удалось создать заказ');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Стол ${widget.tableNumber}'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              'Текущие заказы',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<ApiOrder>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Ошибка загрузки заказов',
                    style: TextStyle(color: cs.error),
                  );
                }
                final orders = snapshot.data
                        ?.where((o) =>
                            (o.tableNumber ?? '') == widget.tableNumber)
                        .toList() ??
                    [];
                if (orders.isEmpty) {
                  return const Text('Для этого стола ещё нет заказов');
                }
                return Column(
                  children: orders.map((o) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              o.customerName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${o.total.toStringAsFixed(0)} ₽',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Новый заказ',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            FutureBuilder<MenuResponse>(
              future: _menuFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Ошибка загрузки меню',
                    style: TextStyle(color: cs.error),
                  );
                }
                final menu = snapshot.data;
                if (menu == null || menu.items.isEmpty) {
                  return const Text('Меню пусто');
                }

                final items = menu.items
                    .where((i) => i.isActive && i.status != 'hidden')
                    .toList();

                return Column(
                  children: items.map((item) {
                    final qty = _selectedQty[item.id] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.price.toStringAsFixed(0)} ₽',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: qty > 0
                                ? () {
                                    setState(() {
                                      final current =
                                          _selectedQty[item.id] ?? 0;
                                      if (current > 1) {
                                        _selectedQty[item.id] = current - 1;
                                      } else {
                                        _selectedQty.remove(item.id);
                                      }
                                    });
                                  }
                                : null,
                          ),
                          Text('$qty'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                _selectedQty[item.id] = qty + 1;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: cs.error),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submitOrder,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Создать заказ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}