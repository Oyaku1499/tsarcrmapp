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
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode
        ? ThemeData(
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
          )
        : ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF8C3A),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFFFFFFF),
              elevation: 0,
              foregroundColor: Colors.black,
            ),
            cardColor: const Color(0xFFFFFFFF),
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
              isDarkMode: _isDarkMode,
              onToggleTheme: () => setState(() => _isDarkMode = !_isDarkMode),
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


class _TablesData {
  final List<ApiTable> tables;
  final List<ApiOrder> orders;

  _TablesData(this.tables, this.orders);
}

class _TablesScreenState extends State<TablesScreen> {
  late Future<_TablesData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_TablesData> _load() async {
    final results = await Future.wait([
      widget.apiClient.getTables(),
      widget.apiClient.getOrders(),
    ]);
    return _TablesData(
      results[0] as List<ApiTable>,
      results[1] as List<ApiOrder>,
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
                return ListView(
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Text(
                        'Ошибка загрузки столов',
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

              final byTable = <String, List<ApiOrder>>{};
              for (final o in data.orders) {
                final key = o.tableNumber ?? '';
                if (key.isEmpty) continue;
                byTable.putIfAbsent(key, () => []).add(o);
              }

              final tables = [...data.tables]
                ..sort((a, b) {
                  final an = int.tryParse(a.number);
                  final bn = int.tryParse(b.number);
                  if (an != null && bn != null) return an.compareTo(bn);
                  return a.number.compareTo(b.number);
                });

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tables.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final table = tables[index];
                  final orders = byTable[table.number] ?? const [];
                  return _TableCard(
                    tableNumber: table.number,
                    orders: orders,
                    tableStatus: table.status,
                    reservation: table.reservation,
                    onChanged: _reload,
                  );
                },
              );
            },
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _showAddTableDialog,
            icon: const Icon(Icons.add),
            label: const Text('Новый стол'),
          ),
        ),
      ],
    );
  }
}


class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.tableNumber,
    required this.orders,
    required this.tableStatus,
    this.reservation,
    this.onChanged,
  });

  final String tableNumber;
  final List<ApiOrder> orders;
  final String tableStatus;
    final TableReservation? reservation;
  final VoidCallback? onChanged;

  String get _statusLabel {
    // Если есть бронь или статус стола — reserved
    if (reservation != null || tableStatus == 'reserved') {
      return 'Забронирован';
    }

    // Занят: учитываем и busy, и occupied (как приходит из CRM)
    if (tableStatus == 'busy' || tableStatus == 'occupied') {
      return 'Занят';
    }

    final hasNew = orders.any((o) => o.status == 'new');
    final hasPreparing = orders.any((o) => o.status == 'preparing');
    final hasWaiting =
        orders.any((o) => o.status == 'completed'); // условно "ждёт счёт"

    // Нет заказов или "без стола"
    if (orders.isEmpty || tableNumber == '—') {
      return switch (tableStatus) {
        'busy' || 'occupied' => 'Занят',
        'free' => 'Свободен',
        'reserved' => 'Забронирован',
        _ => 'Свободен',
      };
    }

    if (hasWaiting) return 'Ожидает счёт';
    if (hasPreparing) return 'Готовится';
    if (hasNew) return 'Новый заказ';
    return 'Заказ';
  }

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Зарезервирован (бронь)
    if (reservation != null || tableStatus == 'reserved') {
      return cs.secondary;
    }

    // Занят — busy или occupied
    if (tableStatus == 'busy' || tableStatus == 'occupied') {
      return cs.error;
    }

    // Есть завершённый заказ — условно "ждёт счёт"
    if (orders.any((o) => o.status == 'completed')) {
      return cs.tertiary;
    }

    // Остальные варианты — свободен / новый заказ / готовится
    return cs.primary;
  }

  Future<void> _closeOrder(BuildContext context, ApiOrder order) async {
    final apiClient = apiClientFromContext(context);
    try {
      await apiClient.deleteOrder(order.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заказ ${order.id} закрыт')),
      );
      onChanged?.call();
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final totalGuests = orders.length;

    ApiOrder? lastOrder;
    if (orders.isNotEmpty) {
      final sorted = [...orders]
        ..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
      lastOrder = sorted.first;
    }

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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(0.6),
            width: 1.1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // заголовок + статус
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
                    color: _statusColor(context).withOpacity(0.16),
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
            if (reservation != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 16,
                    color: cs.secondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Бронь: ${reservation!.dateTimeDisplay}',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            // краткая инфа по гостям / заказам
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  totalGuests == 0 ? 'Нет заказов' : '$totalGuests заказ(ов)',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (lastOrder != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surfaceVariant.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Заказ #${lastOrder.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Сумма: ${lastOrder.total.toStringAsFixed(0)} ₽',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _closeOrder(context, lastOrder!),
                        child: const Text('Закрыть заказ'),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                'Заказов пока нет',
                style: TextStyle(
                  fontSize: 11,
                  color: cs.outline,
                ),
              ),
            const Spacer(),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                'Меню',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Поиск блюда…',
                  border: const OutlineInputBorder(),
                  isDense: true,
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
                        final selected = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Выберите категорию'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (final c in menu.categories)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(c.id),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(c.name),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop('all'),
                                  child: const Text('Сбросить'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(null),
                                  child: const Text('Отмена'),
                                ),
                              ],
                            );
                          },
                        );
                        if (selected != null) {
                          setState(() => _selectedCategoryId = selected);
                        }
                      },
                      icon: const Icon(Icons.filter_list),
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
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.image_outlined),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 12, top: 12, bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    item.category.isNotEmpty
                                        ? item.category
                                        : 'Категория',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'В наличии: ${item.stockQuantity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        cs.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            '${item.price.toStringAsFixed(0)} ₽',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
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

class _MenuCategoryCard extends StatelessWidget {
  const _MenuCategoryCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
          splashColor: cs.primary.withOpacity(0.05),
          highlightColor: cs.primary.withOpacity(0.03),
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
          Text(
            'Профиль',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
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
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: cs.primary.withOpacity(0.15),
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.fullName.isNotEmpty ? user.fullName : user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
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
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _ProfileInfoRow(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  value: user.email ?? 'Не указан',
                ),
                const SizedBox(height: 8),
                _ProfileInfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Логин',
                  value: user.username,
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
            ),
            child: Row(
              children: [
                Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Тема оформления',
                        style: TextStyle(fontWeight: FontWeight.w600),
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
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Это демо-версия CRM системы. Данные могут быть тестовыми и '
              'очищаться при обновлении или переустановке приложения.',
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
  late Future<ApiTable?> _tableFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _ordersFuture = widget.apiClient.getOrders();
    _tableFuture = _loadTable();
  }

  Future<ApiTable?> _loadTable() async {
    try {
      final tables = await widget.apiClient.getTables();
      return tables.firstWhere((t) => t.number == widget.tableNumber);
    } catch (_) {
      return null;
    }
  }

  Future<void> _refresh() async {
    setState(_reload);
  }

  Future<void> _openCreateOrderDialog() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CreateOrderDialog(
        apiClient: widget.apiClient,
        tableNumber: widget.tableNumber,
      ),
    );
    if (created == true) {
      _refresh();
    }
  }

  
  Widget _buildReservationRow(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
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
            FutureBuilder<ApiTable?>(
              future: _tableFuture,
              builder: (context, tsnap) {
                final table = tsnap.data;
                final reservation = table?.reservation;
                final isReserved =
                    (table?.status == 'reserved') || reservation != null;
                
                if (tsnap.connectionState == ConnectionState.waiting) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: const Center(
                      child: SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                if (!isReserved) {
                  return const SizedBox.shrink();
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Бронь',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (reservation != null) ...[
                        _buildReservationRow(
                          'Дата и время',
                          reservation.dateTimeDisplay,
                        ),
                        _buildReservationRow(
                          'Имя',
                          reservation.name ?? 'Не указано',
                        ),
                        _buildReservationRow(
                          'Контакты',
                          reservation.contacts ?? 'Не указано',
                        ),
                        _buildReservationRow(
                          'Количество гостей',
                          reservation.guests != null
                              ? reservation.guests.toString()
                              : 'Не указано',
                        ),
                        _buildReservationRow(
                          'Предзаказ',
                          (reservation.preOrder?.isNotEmpty ?? false)
                              ? reservation.preOrder!
                              : 'Нет',
                        ),
                      ] else
                        Text(
                          'Информация о брони недоступна',
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
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
                final orders = snap.data ?? const [];
                final tableOrders = orders
                    .where((o) => (o.tableNumber ?? '') == widget.tableNumber)
                    .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (tableOrders.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Text(
                      'Пока нет заказов для этого стола',
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
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
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Заказ #${o.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Статус: ${o.status}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Создан: ${o.createdAt.toLocal()}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cs.outline,
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
            const SizedBox(height: 24),
            Text(
              'Создание заказа',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Откройте модальное окно, чтобы добавить позиции и блюда в заказ.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.outline,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openCreateOrderDialog,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Создать заказ'),
              ),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 12),
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
    );
  }
}
