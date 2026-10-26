import 'package:carwash_manager/features/auth/models/manager_profile_model.dart';
import 'package:carwash_manager/features/auth/services/profile_service.dart';
import 'package:carwash_manager/features/auth/viewmodels/profile_viewmodel.dart';
import 'package:carwash_manager/features/branch/models/branch_models.dart';
import 'package:carwash_manager/features/branch/services/branch_service.dart';
import 'package:carwash_manager/features/branch/viewmodels/branch_viewmodel.dart';
import 'package:carwash_manager/features/customer/models/customer_models.dart';
import 'package:carwash_manager/features/customer/services/customer_service.dart';
import 'package:carwash_manager/features/customer/viewmodels/customer_viewmodel.dart';
import 'package:carwash_manager/features/vehicle/models/vehicle_models.dart';
import 'package:carwash_manager/features/vehicle/services/vehicle_service.dart';
import 'package:carwash_manager/features/vehicle/viewmodels/vehicle_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Test data ─────────────────────────────────────────────────────────────────

const _vehicleJson = {
  'id': 4,
  'customer': 15,
  'customer_details': {
    'id': 15,
    'username': 'salman_k',
    'first_name': 'Salman',
    'last_name': 'Khan',
    'phone': '971501234567',
  },
  'branch': 1,
  'branch_details': {
    'id': 1,
    'name': 'Al Sewar Muscat Main Branch',
    'code': 'MCT01',
  },
  'plate_number': 'DXB-A-12345',
  'make': 'Toyota',
  'model': 'Camry',
  'year': 2022,
  'color': 'Silver',
  'vin': '1HGCR2F83HA000000',
  'is_active': true,
  'created_at': '2026-10-10T12:00:00Z',
  'updated_at': '2026-10-10T12:00:00Z',
};

const _vehicleHistoryJson = {
  'visit_count': 1,
  'last_visit_date': '2026-10-12T14:30:00Z',
  'visits': [
    {
      'id': 12,
      'visit_number': 'SV-V1-002',
      'branch': {
        'id': 2,
        'name': 'Salalah Branch',
        'code': 'SLL-01',
        'city': 'Salalah',
      },
      'current_stage': {
        'id': 3,
        'name': 'Completed',
        'code': 'COMPLETED',
        'is_terminal': true,
      },
      'services': [
        {
          'id': 2,
          'name': 'Brake Inspection',
          'description': 'Front & rear brake check',
        },
      ],
      'notes': 'Brake inspection at Branch B',
      'created_at': '2026-10-12T14:30:00Z',
      'updated_at': '2026-10-12T16:00:00Z',
    },
  ],
};

const _customerListItemJson = {
  'id': 101,
  'username': 'customer_ali',
  'first_name': 'Ali',
  'last_name': 'Hassan',
  'email': 'ali@example.com',
  'phone': '+971509876543',
  'is_active': true,
  'date_joined': '2026-01-10T12:00:00Z',
};

const _customerDetailJson = {
  'id': 101,
  'username': 'customer_ali',
  'first_name': 'Ali',
  'last_name': 'Hassan',
  'email': 'ali@example.com',
  'phone': '+971509876543',
  'is_active': true,
  'date_joined': '2026-01-10T12:00:00Z',
  'vehicles': [
    {
      'id': 1,
      'make': 'Toyota',
      'model': 'Land Cruiser',
      'year': 2023,
      'license_plate': 'DXB-A-12345',
      'color': 'Pearl White',
    },
  ],
};

const _branchJson = {
  'id': 1,
  'name': 'Dubai Downtown Flagship',
  'code': 'DXB-DT-01',
  'address': 'Sheikh Zayed Road, Building 4',
  'city': 'Dubai',
  'phone': '+97141234567',
  'email': 'downtown@alsewar.com',
  'latitude': '25.2048493',
  'longitude': '55.2707828',
  'is_active': true,
  'created_at': '2026-10-09T10:00:00Z',
  'updated_at': '2026-10-09T10:00:00Z',
};

const _hourJson = {
  'id': 10,
  'day_of_week': 0,
  'day_name': 'Monday',
  'opening_time': '09:00:00',
  'closing_time': '18:00:00',
  'is_closed': false,
};

const _closedHourJson = {
  'id': 16,
  'day_of_week': 6,
  'day_name': 'Sunday',
  'opening_time': null,
  'closing_time': null,
  'is_closed': true,
};

const _profileJson = {
  'id': 5,
  'username': 'mgr_dubai',
  'first_name': 'Ahmed',
  'last_name': 'Al Rashid',
  'email': 'ahmed@alsewar.com',
  'role': 'MANAGER',
  'is_active': true,
  'phone': '+971501234567',
  'profile_image': null,
  'date_joined': '2024-03-01T09:00:00Z',
};

// ── BranchModel tests ─────────────────────────────────────────────────────────

void main() {
  group('BranchModel.fromJson', () {
    test('parses all fields correctly', () {
      final branch = BranchModel.fromJson(_branchJson);
      expect(branch.id, 1);
      expect(branch.name, 'Dubai Downtown Flagship');
      expect(branch.code, 'DXB-DT-01');
      expect(branch.address, 'Sheikh Zayed Road, Building 4');
      expect(branch.city, 'Dubai');
      expect(branch.phone, '+97141234567');
      expect(branch.email, 'downtown@alsewar.com');
      expect(branch.latitude, '25.2048493');
      expect(branch.longitude, '55.2707828');
      expect(branch.isActive, true);
    });

    test('handles null latitude and longitude', () {
      final json = Map<String, dynamic>.from(_branchJson);
      json['latitude'] = null;
      json['longitude'] = null;
      final branch = BranchModel.fromJson(json);
      expect(branch.latitude, isNull);
      expect(branch.longitude, isNull);
    });
  });

  // ── BusinessHourModel tests ───────────────────────────────────────────────

  group('BusinessHourModel.fromJson', () {
    test('parses open day correctly', () {
      final hour = BusinessHourModel.fromJson(_hourJson);
      expect(hour.id, 10);
      expect(hour.dayOfWeek, 0);
      expect(hour.dayName, 'Monday');
      expect(hour.openingTime, '09:00:00');
      expect(hour.closingTime, '18:00:00');
      expect(hour.isClosed, false);
    });

    test('parses closed day with null times', () {
      final hour = BusinessHourModel.fromJson(_closedHourJson);
      expect(hour.dayOfWeek, 6);
      expect(hour.isClosed, true);
      expect(hour.openingTime, isNull);
      expect(hour.closingTime, isNull);
    });

    test('hoursDisplay returns "Closed" for closed day', () {
      final hour = BusinessHourModel.fromJson(_closedHourJson);
      expect(hour.hoursDisplay, 'Closed');
    });

    test('hoursDisplay formats times correctly', () {
      final hour = BusinessHourModel.fromJson(_hourJson);
      expect(hour.hoursDisplay, '9:00 AM – 6:00 PM');
    });

    test('hoursDisplay handles null times gracefully', () {
      final json = Map<String, dynamic>.from(_hourJson)
        ..['opening_time'] = null
        ..['closing_time'] = null
        ..['is_closed'] = false;
      final hour = BusinessHourModel.fromJson(json);
      expect(hour.hoursDisplay, 'Hours unavailable');
    });
  });

  // ── ManagerProfileModel tests ─────────────────────────────────────────────

  group('ManagerProfileModel.fromJson', () {
    test('parses all fields correctly', () {
      final profile = ManagerProfileModel.fromJson(_profileJson);
      expect(profile.id, 5);
      expect(profile.username, 'mgr_dubai');
      expect(profile.firstName, 'Ahmed');
      expect(profile.lastName, 'Al Rashid');
      expect(profile.email, 'ahmed@alsewar.com');
      expect(profile.role, 'MANAGER');
      expect(profile.isActive, true);
      expect(profile.phone, '+971501234567');
      expect(profile.dateJoined, '2024-03-01T09:00:00Z');
    });

    test('displayName returns full name when both names present', () {
      final profile = ManagerProfileModel.fromJson(_profileJson);
      expect(profile.displayName, 'Ahmed Al Rashid');
    });

    test('displayName falls back to username when names are absent', () {
      final json = Map<String, dynamic>.from(_profileJson);
      json['first_name'] = null;
      json['last_name'] = null;
      final profile = ManagerProfileModel.fromJson(json);
      expect(profile.displayName, 'mgr_dubai');
    });

    test('accepts user_role field as alternative to role', () {
      final json = Map<String, dynamic>.from(_profileJson);
      json.remove('role');
      json['user_role'] = 'MANAGER';
      final profile = ManagerProfileModel.fromJson(json);
      expect(profile.role, 'MANAGER');
    });

    test('defaults is_active to true when field absent', () {
      final json = Map<String, dynamic>.from(_profileJson);
      json.remove('is_active');
      final profile = ManagerProfileModel.fromJson(json);
      expect(profile.isActive, true);
    });
  });

  // ── BranchService error handling ──────────────────────────────────────────

  group('BranchService error handling', () {
    BranchService makeService(int statusCode, {dynamic body}) {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: statusCode,
                  data: body ?? {'detail': 'error'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );
      return BranchService(dio);
    }

    test('401 throws session-expired message', () async {
      final service = makeService(401);
      expect(
        () => service.getMyAssignedBranch(),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('session has expired'),
          ),
        ),
      );
    });

    test('403 throws access-denied message', () async {
      final service = makeService(403);
      expect(
        () => service.getMyAssignedBranch(),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('Access denied')),
        ),
      );
    });

    test('404 throws no-branch-assigned message', () async {
      final service = makeService(
        404,
        body: {'detail': 'No branch is currently assigned to this manager.'},
      );
      expect(
        () => service.getMyAssignedBranch(),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('No branch')),
        ),
      );
    });

    test('network error throws connection message', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );
      final service = BranchService(dio);
      expect(
        () => service.getMyAssignedBranch(),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('Cannot reach')),
        ),
      );
    });
  });

  // ── ProfileService error handling ─────────────────────────────────────────

  group('ProfileService error handling', () {
    ProfileService makeService(int statusCode, {dynamic body}) {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: statusCode,
                  data: body ?? {'detail': 'error'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );
      return ProfileService(dio);
    }

    test('401 throws session-expired message', () {
      final service = makeService(401);
      expect(
        () => service.getMyProfile(),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('session has expired'),
          ),
        ),
      );
    });

    test('404 throws not-found message', () {
      final service = makeService(404);
      expect(
        () => service.getMyProfile(),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('not found')),
        ),
      );
    });

    test('network error throws connection message', () {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );
      final service = ProfileService(dio);
      expect(
        () => service.getMyProfile(),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('Cannot reach')),
        ),
      );
    });
  });

  // ── BranchViewModel state tests ───────────────────────────────────────────

  group('BranchViewModel', () {
    ProviderContainer makeContainer(BranchService service) {
      return ProviderContainer(
        overrides: [branchServiceProvider.overrideWithValue(service)],
      );
    }

    BranchService successService() {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('hours')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [_hourJson, _closedHourJson],
                ),
              );
            } else {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: _branchJson,
                ),
              );
            }
          },
        ),
      );
      return BranchService(dio);
    }

    test('starts in loading state', () {
      final container = makeContainer(successService());
      addTearDown(container.dispose);
      final state = container.read(branchViewModelProvider);
      expect(state, isA<AsyncLoading>());
    });

    test('resolves to data state with correct branch name', () async {
      final container = makeContainer(successService());
      addTearDown(container.dispose);
      final data = await container.read(branchViewModelProvider.future);
      expect(data.branch.name, 'Dubai Downtown Flagship');
      expect(data.hours.length, 2);
    });

    test('resolves to error state on 404', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 404,
                  data: {'detail': 'No branch is currently assigned.'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );
      final container = makeContainer(BranchService(dio));
      addTearDown(container.dispose);

      await expectLater(
        container.read(branchViewModelProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(branchViewModelProvider), isA<AsyncError>());
    });
  });

  // ── ProfileViewModel state tests ──────────────────────────────────────────

  group('ProfileViewModel', () {
    ProviderContainer makeContainer(ProfileService service) {
      return ProviderContainer(
        overrides: [profileServiceProvider.overrideWithValue(service)],
      );
    }

    test('starts in loading state', () {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: _profileJson,
              ),
            );
          },
        ),
      );
      final container = makeContainer(ProfileService(dio));
      addTearDown(container.dispose);
      final state = container.read(profileViewModelProvider);
      expect(state, isA<AsyncLoading>());
    });

    test('resolves to data with correct username', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: _profileJson,
              ),
            );
          },
        ),
      );
      final container = makeContainer(ProfileService(dio));
      addTearDown(container.dispose);
      final profile = await container.read(profileViewModelProvider.future);
      expect(profile.username, 'mgr_dubai');
      expect(profile.displayName, 'Ahmed Al Rashid');
      expect(profile.role, 'MANAGER');
    });

    test('resolves to error on 401', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'detail': 'Token is invalid.'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );
      final container = makeContainer(ProfileService(dio));
      addTearDown(container.dispose);
      await expectLater(
        container.read(profileViewModelProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(profileViewModelProvider), isA<AsyncError>());
    });
  });

  // ── Customer model tests ──────────────────────────────────────────────────

  group('CustomerListItem.fromJson', () {
    test('parses all fields correctly', () {
      final customer = CustomerListItem.fromJson(_customerListItemJson);
      expect(customer.id, 101);
      expect(customer.username, 'customer_ali');
      expect(customer.displayName, 'Ali Hassan');
      expect(customer.email, 'ali@example.com');
      expect(customer.phone, '+971509876543');
      expect(customer.isActive, true);
      expect(customer.dateJoined, '2026-01-10T12:00:00Z');
    });

    test('displayName falls back to username when names are absent', () {
      final json = Map<String, dynamic>.from(_customerListItemJson)
        ..['first_name'] = null
        ..['last_name'] = null;
      final customer = CustomerListItem.fromJson(json);
      expect(customer.displayName, 'customer_ali');
    });
  });

  group('CustomerVehicle.fromJson', () {
    test('parses all fields and formats summary', () {
      final vehicle = CustomerVehicle.fromJson(
        (_customerDetailJson['vehicles'] as List).first as Map<String, dynamic>,
      );
      expect(vehicle.id, 1);
      expect(vehicle.make, 'Toyota');
      expect(vehicle.model, 'Land Cruiser');
      expect(vehicle.year, '2023');
      expect(vehicle.licensePlate, 'DXB-A-12345');
      expect(vehicle.color, 'Pearl White');
      expect(vehicle.summary, '2023 Toyota Land Cruiser');
    });

    test('summary falls back to license plate or ID', () {
      final vehicle = CustomerVehicle.fromJson({
        'id': 99,
        'license_plate': 'SHJ-123',
      });
      expect(vehicle.summary, 'SHJ-123');

      final vehicleEmpty = CustomerVehicle.fromJson({'id': 99});
      expect(vehicleEmpty.summary, 'Vehicle #99');
    });
  });

  group('CustomerDetailModel.fromJson', () {
    test('parses customer detail with vehicles', () {
      final detail = CustomerDetailModel.fromJson(_customerDetailJson);
      expect(detail.id, 101);
      expect(detail.username, 'customer_ali');
      expect(detail.displayName, 'Ali Hassan');
      expect(detail.vehicles.length, 1);
      expect(detail.vehicles.first.make, 'Toyota');
    });

    test('parses customer detail with empty or missing vehicles', () {
      final json = Map<String, dynamic>.from(_customerDetailJson)
        ..remove('vehicles');
      final detail = CustomerDetailModel.fromJson(json);
      expect(detail.vehicles, isEmpty);
    });
  });

  // ── CustomerService error handling ────────────────────────────────────────

  group('CustomerService', () {
    test('getCustomers handles list and paginated response', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'results': [_customerListItemJson],
                },
              ),
            );
          },
        ),
      );
      final service = CustomerService(dio);
      final list = await service.getCustomers();
      expect(list.length, 1);
      expect(list.first.username, 'customer_ali');
    });

    test('getCustomers passes search parameter', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.queryParameters['search'], 'ali');
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [_customerListItemJson],
              ),
            );
          },
        ),
      );
      final service = CustomerService(dio);
      final list = await service.getCustomers(search: 'ali');
      expect(list.length, 1);
    });

    test('getCustomer parses single customer detail', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: _customerDetailJson,
              ),
            );
          },
        ),
      );
      final service = CustomerService(dio);
      final detail = await service.getCustomer(101);
      expect(detail.id, 101);
      expect(detail.vehicles.length, 1);
    });

    test(
      'registerCustomer sends required fields and parses response',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final data = options.data as Map<String, dynamic>;
              expect(data['username'], 'customer_ali');
              expect(data['email'], 'ali@example.com');
              expect(data['password'], 'secret123');
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: _customerDetailJson,
                ),
              );
            },
          ),
        );
        final service = CustomerService(dio);
        final registered = await service.registerCustomer(
          username: 'customer_ali',
          email: 'ali@example.com',
          password: 'secret123',
        );
        expect(registered.id, 101);
      },
    );

    test('handles 400 validation error gracefully', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 400,
                  data: {
                    'username': ['A user with that username already exists.'],
                  },
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );
      final service = CustomerService(dio);
      expect(
        () => service.registerCustomer(
          username: 'existing',
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('already exists')),
        ),
      );
    });
  });

  // ── Customer ViewModels ───────────────────────────────────────────────────

  group('CustomerListViewModel', () {
    test('loads and filters customer list', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [_customerListItemJson],
              ),
            );
          },
        ),
      );
      final service = CustomerService(dio);
      final container = ProviderContainer(
        overrides: [customerServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);

      final state = await container.read(customerListViewModelProvider.future);
      expect(state.customers.length, 1);
      expect(state.customers.first.displayName, 'Ali Hassan');
    });
  });

  group('CustomerRegisterViewModel', () {
    test('starts idle, then transitions through loading to success', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: _customerDetailJson,
              ),
            );
          },
        ),
      );
      final service = CustomerService(dio);
      final container = ProviderContainer(
        overrides: [customerServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);

      expect(
        container.read(customerRegisterViewModelProvider),
        isA<RegisterIdle>(),
      );

      await container
          .read(customerRegisterViewModelProvider.notifier)
          .register(
            username: 'customer_ali',
            email: 'ali@example.com',
            password: 'password123',
          );

      final state = container.read(customerRegisterViewModelProvider);
      expect(state, isA<RegisterSuccess>());
      expect((state as RegisterSuccess).customer.username, 'customer_ali');
    });
  });

  // ── Vehicle model tests ───────────────────────────────────────────────────

  group('VehicleModel.fromJson', () {
    test(
      'parses all fields correctly including nested customer and branch',
      () {
        final vehicle = VehicleModel.fromJson(_vehicleJson);
        expect(vehicle.id, 4);
        expect(vehicle.customerId, 15);
        expect(vehicle.customerDetails?.username, 'salman_k');
        expect(vehicle.customerDetails?.displayName, 'Salman Khan');
        expect(vehicle.branchId, 1);
        expect(vehicle.branchDetails?.code, 'MCT01');
        expect(vehicle.plateNumber, 'DXB-A-12345');
        expect(vehicle.make, 'Toyota');
        expect(vehicle.model, 'Camry');
        expect(vehicle.year, 2022);
        expect(vehicle.color, 'Silver');
        expect(vehicle.vin, '1HGCR2F83HA000000');
        expect(vehicle.name, 'Toyota Camry');
        expect(vehicle.titleWithYear, '2022 Toyota Camry');
        expect(vehicle.isActive, true);
      },
    );

    test('handles missing year, color, vin gracefully', () {
      final json = Map<String, dynamic>.from(_vehicleJson)
        ..remove('year')
        ..remove('color')
        ..remove('vin');
      final vehicle = VehicleModel.fromJson(json);
      expect(vehicle.year, isNull);
      expect(vehicle.color, isNull);
      expect(vehicle.vin, isNull);
      expect(vehicle.titleWithYear, 'Toyota Camry');
    });
  });

  group('VehicleServiceHistoryModel.fromJson', () {
    test('parses history visits and nested services', () {
      final history = VehicleServiceHistoryModel.fromJson(_vehicleHistoryJson);
      expect(history.visitCount, 1);
      expect(history.lastVisitDate, '2026-10-12T14:30:00Z');
      expect(history.visits.length, 1);

      final visit = history.visits.first;
      expect(visit.id, 12);
      expect(visit.visitNumber, 'SV-V1-002');
      expect(visit.branch?.name, 'Salalah Branch');
      expect(visit.currentStage?.code, 'COMPLETED');
      expect(visit.currentStage?.isTerminal, true);
      expect(visit.services.length, 1);
      expect(visit.services.first.name, 'Brake Inspection');
      expect(visit.notes, 'Brake inspection at Branch B');
    });
  });

  // ── VehicleService tests ──────────────────────────────────────────────────

  group('VehicleService', () {
    test('getVehicles handles response and passes query parameters', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.queryParameters['search'], 'camry');
            expect(options.queryParameters['customer_id'], 15);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [_vehicleJson],
              ),
            );
          },
        ),
      );
      final service = VehicleService(dio);
      final list = await service.getVehicles(search: 'camry', customerId: 15);
      expect(list.length, 1);
      expect(list.first.plateNumber, 'DXB-A-12345');
    });

    test('getVehicle parses single vehicle detail', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: _vehicleJson,
              ),
            );
          },
        ),
      );
      final service = VehicleService(dio);
      final vehicle = await service.getVehicle(4);
      expect(vehicle.id, 4);
      expect(vehicle.make, 'Toyota');
    });

    test('registerVehicle posts correct payload', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final data = options.data as Map<String, dynamic>;
            expect(data['customer'], 15);
            expect(data['customer_id'], 15);
            expect(data['plate_number'], 'DXB-A-12345');
            expect(data['make'], 'Toyota');
            expect(data['model'], 'Camry');
            expect(data['year'], 2022);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: _vehicleJson,
              ),
            );
          },
        ),
      );
      final service = VehicleService(dio);
      final created = await service.registerVehicle(
        customerId: 15,
        plateNumber: 'dxb-a-12345',
        make: 'Toyota',
        model: 'Camry',
        year: 2022,
      );
      expect(created.id, 4);
    });

    test(
      'registerVehicle with required fields only omits optional fields',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final data = options.data as Map<String, dynamic>;
              expect(data['customer'], 15);
              expect(data['customer_id'], 15);
              expect(data['plate_number'], 'DXB-B-99999');
              expect(data['make'], 'Nissan');
              expect(data['model'], 'Patrol');
              expect(data.containsKey('year'), false);
              expect(data.containsKey('color'), false);
              expect(data.containsKey('vin'), false);
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: {..._vehicleJson, 'plate_number': 'DXB-B-99999'},
                ),
              );
            },
          ),
        );
        final service = VehicleService(dio);
        final created = await service.registerVehicle(
          customerId: 15,
          plateNumber: 'dxb-b-99999',
          make: 'Nissan',
          model: 'Patrol',
        );
        expect(created.plateNumber, 'DXB-B-99999');
      },
    );

    test(
      'registerVehicle with all optional fields includes year, color, vin',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final data = options.data as Map<String, dynamic>;
              expect(data['customer'], 15);
              expect(data['customer_id'], 15);
              expect(data['plate_number'], 'DXB-C-11111');
              expect(data['make'], 'BMW');
              expect(data['model'], 'X5');
              expect(data['year'], 2024);
              expect(data['color'], 'Midnight Black');
              expect(data['vin'], 'WBA00000000000000');
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: _vehicleJson,
                ),
              );
            },
          ),
        );
        final service = VehicleService(dio);
        final created = await service.registerVehicle(
          customerId: 15,
          plateNumber: 'DXB-C-11111',
          make: 'BMW',
          model: 'X5',
          year: 2024,
          color: 'Midnight Black',
          vin: 'WBA00000000000000',
        );
        expect(created.id, 4);
      },
    );

    test('updateVehicle sends PATCH and receives updated vehicle', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'PATCH');
            final data = options.data as Map<String, dynamic>;
            expect(data['color'], 'Dark Blue');
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {..._vehicleJson, 'color': 'Dark Blue'},
              ),
            );
          },
        ),
      );
      final service = VehicleService(dio);
      final updated = await service.updateVehicle(4, color: 'Dark Blue');
      expect(updated.color, 'Dark Blue');
    });

    test('deleteVehicle sends DELETE request', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'DELETE');
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'detail': 'Vehicle deleted successfully.'},
              ),
            );
          },
        ),
      );
      final service = VehicleService(dio);
      await expectLater(service.deleteVehicle(4), completes);
    });

    test('getVehicleHistory parses service history response', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path.contains('/history/'), true);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: _vehicleHistoryJson,
              ),
            );
          },
        ),
      );
      final service = VehicleService(dio);
      final history = await service.getVehicleHistory(4);
      expect(history.visitCount, 1);
      expect(history.visits.first.visitNumber, 'SV-V1-002');
    });

    test(
      'handles duplicate plate 400 error with field-specific message',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 400,
                    data: {
                      'plate_number': [
                        'A vehicle with this plate number already exists.',
                      ],
                    },
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            },
          ),
        );
        final service = VehicleService(dio);
        expect(
          () => service.registerVehicle(
            customerId: 15,
            plateNumber: 'DXB-A-12345',
            make: 'Toyota',
            model: 'Camry',
          ),
          throwsA(
            predicate<Exception>(
              (e) =>
                  e.toString().contains('Plate Number:') &&
                  e.toString().contains('already exists'),
            ),
          ),
        );
      },
    );

    test(
      'handles missing required field 400 error displaying field name',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 400,
                    data: {
                      'customer': ['This field is required.'],
                    },
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            },
          ),
        );
        final service = VehicleService(dio);
        expect(
          () => service.registerVehicle(
            customerId: 0,
            plateNumber: 'DXB-A-12345',
            make: 'Toyota',
            model: 'Camry',
          ),
          throwsA(
            predicate<Exception>(
              (e) =>
                  e.toString().contains('Customer:') &&
                  e.toString().contains('This field is required.'),
            ),
          ),
        );
      },
    );

    test('handles invalid customer selection 400 error', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 400,
                  data: {
                    'customer': ['Selected user is not a valid customer.'],
                  },
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );
      final service = VehicleService(dio);
      expect(
        () => service.registerVehicle(
          customerId: 999,
          plateNumber: 'DXB-A-12345',
          make: 'Toyota',
          model: 'Camry',
        ),
        throwsA(
          predicate<Exception>(
            (e) =>
                e.toString().contains('Customer:') &&
                e.toString().contains('Selected user is not a valid customer.'),
          ),
        ),
      );
    });
  });

  // ── Vehicle ViewModels tests ──────────────────────────────────────────────

  group('VehicleListViewModel', () {
    test('fetches and searches vehicles', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [_vehicleJson],
              ),
            );
          },
        ),
      );
      final service = VehicleService(dio);
      final container = ProviderContainer(
        overrides: [vehicleServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);

      final state = await container.read(vehicleListViewModelProvider.future);
      expect(state.vehicles.length, 1);
      expect(state.vehicles.first.plateNumber, 'DXB-A-12345');
    });
  });

  group('VehicleFormViewModel', () {
    test('register transitions through loading to success', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: _vehicleJson,
              ),
            );
          },
        ),
      );
      final service = VehicleService(dio);
      final container = ProviderContainer(
        overrides: [vehicleServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);

      expect(
        container.read(vehicleFormViewModelProvider),
        isA<VehicleFormIdle>(),
      );

      await container
          .read(vehicleFormViewModelProvider.notifier)
          .register(
            customerId: 15,
            plateNumber: 'DXB-A-12345',
            make: 'Toyota',
            model: 'Camry',
          );

      final state = container.read(vehicleFormViewModelProvider);
      expect(state, isA<VehicleFormSuccess>());
      expect((state as VehicleFormSuccess).vehicle.plateNumber, 'DXB-A-12345');
    });

    test('delete transitions to delete success', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'detail': 'Vehicle deleted successfully.'},
              ),
            );
          },
        ),
      );
      final service = VehicleService(dio);
      final container = ProviderContainer(
        overrides: [vehicleServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);

      await container.read(vehicleFormViewModelProvider.notifier).delete(4);

      final state = container.read(vehicleFormViewModelProvider);
      expect(state, isA<VehicleFormDeleteSuccess>());
    });
  });
}
