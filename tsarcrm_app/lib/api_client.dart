import 'dart:convert';
import 'package:http/http.dart' as http;

/// Базовый URL API CRM.
/// Для эмулятора Android: http://10.0.2.2:4000/api
/// Для реального сервера — подставь свой домен/IP.
const String kDefaultApiBaseUrl = 'http://192.168.3.17:4000/api';

class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? kDefaultApiBaseUrl;

  final String baseUrl;
  String? _token;

  String? get token => _token;

  void setToken(String? token) {
    _token = token;
  }

  Uri _buildUri(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl/$normalized');
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response res) async {
    final text = res.body.isEmpty ? '{}' : res.body;
    Map<String, dynamic> data;
    try {
      final decoded = json.decode(text);
      data = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      data = <String, dynamic>{};
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    final error = data['error'] ??
        data['message'] ??
        'Ошибка запроса (${res.statusCode})';
    throw ApiException(error.toString(), statusCode: res.statusCode);
  }

  // ---------- AUTH ----------

  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    final uri = _buildUri('/auth/login');
    final res = await http.post(
      uri,
      headers: _headers(),
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
    final data = await _handleResponse(res);
    final token = data['token'] as String?;
    if (token == null) {
      throw ApiException('Не удалось получить токен авторизации');
    }
    _token = token;

    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw ApiException('Не удалось получить информацию о пользователе');
    }
    return AuthUser.fromJson(userJson);
  }

  Future<AuthUser> currentUser() async {
    final uri = _buildUri('/auth/me');
    final res = await http.get(uri, headers: _headers());
    final data = await _handleResponse(res);
    return AuthUser.fromJson(data);
  }

  // ---------- MENU ----------

  Future<MenuResponse> getMenu() async {
    final uri = _buildUri('/menu');
    final res = await http.get(uri, headers: _headers());
    final data = await _handleResponse(res);
    return MenuResponse.fromJson(data);
  }

  // ---------- ORDERS ----------

  Future<List<ApiOrder>> getOrders() async {
    final uri = _buildUri('/orders');
    final res = await http.get(uri, headers: _headers());
    final data = await _handleResponse(res);
    final list = data['orders'] as List<dynamic>? ?? const [];
    return list.map((e) => ApiOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderResponse> createOrder(CreateOrderPayload payload) async {
    final uri = _buildUri('/orders');
    final res = await http.post(
      uri,
      headers: _headers(),
      body: json.encode(payload.toJson()),
    );
    final data = await _handleResponse(res);
    return OrderResponse.fromJson(data);
  }
  Future<void> deleteOrder(String id) async {
    final uri = _buildUri('/orders/$id');
    final res = await http.delete(
      uri,
      headers: _headers(),
    );
    await _handleResponse(res);
  }

}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ApiException(${statusCode ?? '-'}): $message';
}

// ---------- MODELS -----------

class AuthUser {
  final String id;
  final String username;
  final String fullName;
  final String? email;
  final String role;
  final String roleName;

  AuthUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.roleName,
    this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String? ?? '',
      roleName: json['roleName'] as String? ?? '',
    );
  }
}

// ---------- MENU ----------

class MenuResponse {
  final List<MenuItem> items;
  final List<MenuCategory> categories;

  MenuResponse({required this.items, required this.categories});

  factory MenuResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final categories = (json['categories'] as List<dynamic>? ?? [])
        .map((e) => MenuCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    return MenuResponse(items: items, categories: categories);
  }
}

class MenuItem {
  final String id;
  final String name;
  final String category;
  final String categoryId;
  final double price;
  final int stockQuantity;
  final bool isActive;
  final String status;

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.price,
    required this.stockQuantity,
    required this.isActive,
    required this.status,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      status: json['status'] as String? ?? 'visible',
    );
  }
}

class MenuCategory {
  final String id;
  final String name;
  final String description;

  MenuCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
    );
  }
}

// ---------- ORDERS ----------

class ApiOrder {
  final String id;
  final String customerName;
  final String? customerPhone;
  final String? tableNumber;
  final String? notes;
  final String status;
  final double total;
  final DateTime createdAt;

  ApiOrder({
    required this.id,
    required this.customerName,
    required this.status,
    required this.total,
    required this.createdAt,
    this.customerPhone,
    this.tableNumber,
    this.notes,
  });

  
  factory ApiOrder.fromJson(Map<String, dynamic> json) {
    String? tableNumber;
    final tn = json['tableNumber'];
    if (tn != null) {
      tableNumber = tn.toString();
    } else {
      final table = json['table'];
      if (table is Map<String, dynamic>) {
        final numVal = table['number'] ?? table['tableNumber'];
        if (numVal != null) {
          tableNumber = numVal.toString();
        }
      } else if (table != null) {
        tableNumber = table.toString();
      }
    }

    return ApiOrder(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String?,
      tableNumber: tableNumber,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

}

class CreateOrderPayload {
  final String customerName;
  final String? phone;
  final String? table;
  final String? notes;
  final List<CreateOrderItem> items;

  CreateOrderPayload({
    required this.customerName,
    required this.items,
    this.phone,
    this.table,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer': {
        'name': customerName,
        if (phone != null) 'phone': phone,
        if (table != null) 'table': table,
        if (notes != null) 'notes': notes,
      },
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class CreateOrderItem {
  final String menuItemId;
  final int quantity;

  CreateOrderItem({required this.menuItemId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'menuItemId': menuItemId,
        'quantity': quantity,
      };
}


// ---------- TABLES ----------


class TableReservation {
  final DateTime? dateTime;
  final String? rawDateTime;
  final String? name;
  final String? contacts;
  final int? guests;
  final String? preOrder;

  TableReservation({
    this.dateTime,
    this.rawDateTime,
    this.name,
    this.contacts,
    this.guests,
    this.preOrder,
  });

  factory TableReservation.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    String? raw;
    final dtValue = json['dateTime'] ??
        json['datetime'] ??
        json['date'] ??
        json['reservedAt'];
    if (dtValue is String) {
      raw = dtValue;
      try {
        parsedDate = DateTime.parse(dtValue);
      } catch (_) {
        // ignore parse errors, keep raw string
      }
    } else if (dtValue != null) {
      raw = dtValue.toString();
    }

    int? guests;
    final gVal = json['guests'] ?? json['persons'] ?? json['people'];
    if (gVal is num) {
      guests = gVal.toInt();
    } else if (gVal is String) {
      guests = int.tryParse(gVal);
    }

    return TableReservation(
      dateTime: parsedDate,
      rawDateTime: raw,
      name: json['name'] as String? ?? json['customerName'] as String?,
      contacts: json['contacts'] as String? ??
          json['phone'] as String? ??
          json['phoneNumber'] as String?,
      guests: guests,
      preOrder: json['preorder'] as String? ??
          json['preOrder'] as String? ??
          json['pre_order'] as String? ??
          json['order'] as String?,
    );
  }

  String get dateTimeDisplay {
    if (dateTime != null) {
      return dateTime.toString();
    }
    return rawDateTime ?? 'Не указано';
  }
}

class ApiTable {
  final String id;
  final String number;
  final String? zone;
  final int seats;
  final String status;
  final TableReservation? reservation;

  ApiTable({
    required this.id,
    required this.number,
    this.zone,
    required this.seats,
    required this.status,
    this.reservation,
  });

  ApiTable.fromJson(Map<String, dynamic> json) {
    TableReservation? reservation;

    // 1. Пытаемся взять reservation с верхнего уровня
    dynamic resJson = json['reservation'];

    // 2. Если нет — пробуем достать из data.reservation (как в веб-CRM)
    final data = json['data'];
    if (resJson == null && data is Map<String, dynamic>) {
      resJson = data['reservation'];
    }

    if (resJson is Map<String, dynamic>) {
      reservation = TableReservation.fromJson(resJson);
    }

    return ApiTable(
      id: json['id'] as String,
      number: json['number']?.toString() ?? '',
      zone: json['zone'] as String?,
      seats: (json['seats'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'free',
      reservation: reservation,
    );
  }
}


extension TablesApi on ApiClient {
  Future<List<ApiTable>> getTables() async {
    final uri = _buildUri('/tables');
    final res = await http.get(uri, headers: _headers());
    final data = await _handleResponse(res);
    final list = data['tables'] as List<dynamic>? ?? const [];
    return list
        .map((e) => ApiTable.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ApiTable> createTable({
    required String number,
    required String zone,
    int seats = 2,
    String status = 'free',
  }) async {
    final uri = _buildUri('/tables');
    final res = await http.post(
      uri,
      headers: _headers(),
      body: json.encode({
        'number': number,
        'zone': zone,
        'seats': seats,
        'status': status,
      }),
    );
    final data = await _handleResponse(res);
    final tableJson =
        data['table'] as Map<String, dynamic>? ?? data;
    return ApiTable.fromJson(tableJson);
  }
}


class OrderResponse {
  final ApiOrder order;

  OrderResponse({required this.order});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final orderJson = json['order'] as Map<String, dynamic>;
    return OrderResponse(order: ApiOrder.fromJson(orderJson));
  }
}
