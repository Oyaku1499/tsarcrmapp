import 'package:flutter/material.dart';
import 'api_client.dart';

ApiClient apiClientFromContext(BuildContext context) {
  // самый простой способ — пробросить через InheritedWidget или заменить на глобалку
  // Для простоты сейчас используем глобальный singleton:
  return globalApiClient;
}

final globalApiClient = ApiClient();

void main() {
  runApp(WaiterApp(apiClient: globalApiClient));
}

class WaiterApp extends StatefulWidget {
  const WaiterApp({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<WaiterApp> createState() => _WaiterAppState();
}

class _WaiterAppState extends State<WaiterApp> {
  AuthUser? _user;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4ADE80),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF050816),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF050816),
        elevation: 0,
      ),
      cardColor: const Color(0xFF020617),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tsar Waiter',
      theme: theme,
      home: _user == null
          ? LoginScreen(
              apiClient: widget.apiClient,
              onLoggedIn: (user) => setState(() => _user = user),
            )
          : HomeShell(
              apiClient: widget.apiClient,
              user: _user!,
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
      final user = await widget.apiClient.login(
        username: _loginCtrl.text.trim(),
        password: _passCtrl.text,
      );
      widget.onLoggedIn(user);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.15),
                        cs.secondary.withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.restaurant, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Вход в CRM',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Авторизуйтесь, чтобы работать со столами и заказами',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
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
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
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
                        validator: (v) =>
                            (v == null || v.isEmpty)
                                ? 'Введите пароль'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: cs.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  'Войти',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
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
    required this.onLogout,
  });

  final ApiClient apiClient;
  final AuthUser user;
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
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (_index) {
            0 => 'Столы',
            1 => 'Меню',
            2 => 'Профиль',
            _ => '',
          },
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: screens[_index],
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

class _TablesScreenState extends State<TablesScreen> {
  late Future<List<ApiOrder>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.apiClient.getOrders();
  }

  Future<void> _reload() async {
    setState(() {
      _future = widget.apiClient.getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<ApiOrder>>(
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
                      'Ошибка загрузки заказов',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              );
            }
            final orders = snapshot.data ?? [];
            // Группируем по номеру стола
            final Map<String, List<ApiOrder>> byTable = {};
            for (final o in orders) {
              final key = o.tableNumber ?? '—';
              byTable.putIfAbsent(key, () => []).add(o);
            }
            final entries = byTable.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key));

            return GridView.builder(
              itemCount: entries.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _TableCard(
                  tableNumber: entry.key,
                  orders: entry.value,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.tableNumber,
    required this.orders,
  });

  final String tableNumber;
  final List<ApiOrder> orders;

  String get _statusLabel {
    if (orders.isEmpty || tableNumber == '—') return 'Свободен';
    final hasNew = orders.any((o) => o.status == 'new');
    final hasPreparing = orders.any((o) => o.status == 'preparing');
    final hasWaiting =
        orders.any((o) => o.status == 'completed'); // условно "ждёт счёт"
    if (hasWaiting) return 'Ожидает счёт';
    if (hasPreparing) return 'Готовится';
    if (hasNew) return 'Новый заказ';
    return 'Заказ';
  }

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (orders.isEmpty || tableNumber == '—') {
      return const Color(0xFF16A34A);
    }
    if (orders.any((o) => o.status == 'completed')) {
      return const Color(0xFFF97316);
    }
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalGuests = orders.length; // можно позже заменить на реальное число

    return GestureDetector(
onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TableDetailsScreen(
        apiClient: apiClientFromContext(context),
        tableNumber: tableNumber,
      ),
    ),
  );
},
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _statusColor(context).withOpacity(0.6),
            width: 1.1,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tableNumber == '—' ? 'Без стола' : 'Стол $tableNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor(context).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 9,
                      color: _statusColor(context),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  totalGuests == 0
                      ? 'Нет заказов'
                      : '$totalGuests заказ(ов)',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  side: BorderSide(
                    color: cs.primary.withOpacity(0.6),
                    width: 0.9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
onPressed: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TableDetailsScreen(
        apiClient: apiClientFromContext(context),
        tableNumber: tableNumber,
      ),
    ),
  );
},
                child: Text(
                  orders.isEmpty ? 'Новый заказ' : 'Открыть заказ',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
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
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
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
          final menu = snap.data;
          if (menu == null) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                Center(child: Text('Меню пустое')),
              ],
            );
          }

          final byCategory = <String, List<MenuItem>>{};
          for (final item in menu.items) {
            if (!item.isActive || item.status == 'hidden') continue;
            byCategory.putIfAbsent(item.category, () => []).add(item);
          }

          final categories = byCategory.entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final entry = categories[index];
              return _MenuCategoryCard(
                title: entry.key,
                items: entry.value,
              );
            },
          );
        },
      ),
    );
  }
}

class _MenuCategoryCard extends StatelessWidget {
  const _MenuCategoryCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF1E293B),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          iconColor: cs.onSurfaceVariant,
          collapsedIconColor: cs.onSurfaceVariant,
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          children: [
            for (final item in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.name,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  '${item.price.toStringAsFixed(0)} ₽',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    // TODO: добавить в текущий заказ
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Добавлено: ${item.name}')),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'В заказ',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ----------------- PROFILE SCREEN -----------------

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  final AuthUser user;
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF1E293B),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: cs.primary.withOpacity(0.18),
                  child: const Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isEmpty ? user.username : user.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.roleName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Управление',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Настройки (заглушка)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Icon(
              Icons.logout,
              color: cs.error,
            ),
            title: Text(
              'Выйти из аккаунта',
              style: TextStyle(color: cs.error),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

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

  // menuItemId -> quantity
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

  void _changeQty(String itemId, int delta) {
    setState(() {
      final current = _selectedQty[itemId] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        _selectedQty.remove(itemId);
      } else {
        _selectedQty[itemId] = next;
      }
    });
  }

  Future<void> _submitOrder(List<MenuItem> allMenuItems) async {
    if (_selectedQty.values.where((q) => q > 0).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте хотя бы одну позицию')),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final items = <CreateOrderItem>[];
      _selectedQty.forEach((id, qty) {
        if (qty > 0) {
          items.add(CreateOrderItem(menuItemId: id, quantity: qty));
        }
      });

      final payload = CreateOrderPayload(
        customerName: 'Стол ${widget.tableNumber}',
        table: widget.tableNumber,
        items: items,
      );

      final res = await widget.apiClient.createOrder(payload);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заказ создан • ${res.order.total.toStringAsFixed(0)} ₽'),
        ),
      );

      setState(() {
        _selectedQty.clear();
        _reloadAll();
      });
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
            // Блок текущих заказов
            Text(
              'Текущие заказы',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<ApiOrder>>(
              future: _ordersFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Ошибка загрузки заказов',
                      style: TextStyle(color: cs.error),
                    ),
                  );
                }

                final allOrders = snap.data ?? [];
                final tableOrders = allOrders
                    .where((o) => (o.tableNumber ?? '') == widget.tableNumber)
                    .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (tableOrders.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: const Text(
                      'Пока нет заказов для этого стола',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final o in tableOrders)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020617),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    o.customerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Статус: ${o.status}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Создан: ${o.createdAt.toLocal()}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${o.total.toStringAsFixed(0)} ₽',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            Divider(color: cs.onSurface.withOpacity(0.1)),
            const SizedBox(height: 16),

            // Блок создания заказа
            Text(
              'Новый заказ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
            FutureBuilder<MenuResponse>(
              future: _menuFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError || snap.data == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Не удалось загрузить меню',
                      style: TextStyle(color: cs.error),
                    ),
                  );
                }

                final menu = snap.data!;
                final activeItems = menu.items
                    .where((i) => i.isActive && i.status != 'hidden')
                    .toList();

                if (activeItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Нет доступных позиций в меню',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    ),
                  );
                }

                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF020617),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeItems.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: cs.onSurface.withOpacity(0.05)),
                        itemBuilder: (context, index) {
                          final item = activeItems[index];
                          final qty = _selectedQty[item.id] ?? 0;

                          return ListTile(
                            title: Text(
                              item.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              '${item.price.toStringAsFixed(0)} ₽',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: qty > 0
                                      ? () => _changeQty(item.id, -1)
                                      : null,
                                ),
                                Text(
                                  '$qty',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => _changeQty(item.id, 1),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting
                            ? null
                            : () => _submitOrder(activeItems),
                        style: FilledButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Отправить заказ',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}