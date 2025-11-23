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
  });

  final String tableNumber;
  final List<ApiOrder> orders;
  final String tableStatus;

  String get _statusLabel {
    if (orders.isEmpty || tableNumber == '—') {
      // если заказов нет — используем статус стола из CRM
      switch (tableStatus) {
        case 'reserved':
          return 'Забронирован';
        case 'busy':
          return 'Занят';
        case 'free':
        default:
          return 'Свободен';
      }
    }
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
      switch (tableStatus) {
        case 'reserved':
          return const Color(0xFFFACC15); // жёлтый
        case 'busy':
          return const Color(0xFFEF4444); // красный
        case 'free':
        default:
          return const Color(0xFF16A34A); // зелёный
      }
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
                            color: cs.surfaceVariant,
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
