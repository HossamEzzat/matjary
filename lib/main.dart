import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/suppliers/data/models/supplier_model.dart';
import 'features/customers/data/models/customer_model.dart';
import 'features/transactions/data/models/transaction_model.dart';

import 'features/suppliers/data/datasources/supplier_local_data_source.dart';
import 'features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'features/suppliers/domain/repositories/supplier_repository.dart';

import 'features/customers/data/datasources/customer_local_data_source.dart';
import 'features/customers/data/repositories/customer_repository_impl.dart';
import 'features/customers/domain/repositories/customer_repository.dart';

import 'features/transactions/data/datasources/transaction_local_data_source.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';

import 'core/constants/app_constants.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(SupplierModelAdapter());
  Hive.registerAdapter(CustomerModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  final supplierBox = await Hive.openBox<SupplierModel>(
    AppConstants.kSuppliersBox,
  );
  final customerBox = await Hive.openBox<CustomerModel>(
    AppConstants.kCustomersBox,
  );
  final transactionBox = await Hive.openBox<TransactionModel>(
    AppConstants.kTransactionsBox,
  );

  runApp(
    KhazinaApp(
      supplierBox: supplierBox,
      customerBox: customerBox,
      transactionBox: transactionBox,
    ),
  );
}

class KhazinaApp extends StatelessWidget {
  final Box<SupplierModel> supplierBox;
  final Box<CustomerModel> customerBox;
  final Box<TransactionModel> transactionBox;

  const KhazinaApp({
    super.key,
    required this.supplierBox,
    required this.customerBox,
    required this.transactionBox,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SupplierRepository>(
          create: (context) => SupplierRepositoryImpl(
            localDataSource: SupplierLocalDataSourceImpl(
              supplierBox: supplierBox,
            ),
          ),
        ),
        RepositoryProvider<CustomerRepository>(
          create: (context) => CustomerRepositoryImpl(
            localDataSource: CustomerLocalDataSourceImpl(
              customerBox: customerBox,
            ),
          ),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(
            localDataSource: TransactionLocalDataSourceImpl(
              transactionBox: transactionBox,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Khazina - خزينة',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppConstants.kBackgroundColor,
          primaryColor: AppConstants.kPrimaryColor,
          colorScheme: const ColorScheme.dark(
            primary: AppConstants.kPrimaryColor,
            secondary: AppConstants.kSecondaryColor,
            surface: AppConstants.kSurfaceColor,
            error: AppConstants.kErrorColor,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.kSurfaceColor,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
