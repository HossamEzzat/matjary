import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double totalPayables; // What we owe suppliers
  final double totalReceivables; // What customers owe us

  const DashboardLoaded({
    required this.totalPayables,
    required this.totalReceivables,
  });

  @override
  List<Object> get props => [totalPayables, totalReceivables];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
