import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';

class ReservationProvider extends ChangeNotifier {
  ReservationProvider({ReservationService? reservationService})
      : _reservationService = reservationService ?? ReservationService();

  final ReservationService _reservationService;

  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Reservation> get reservations => _reservations;
  List<Reservation> get activeReservations =>
      _reservations.where((r) => r.isActive).toList();
  List<Reservation> get historyReservations =>
      _reservations.where((r) => !r.isActive).toList();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyReservations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reservations = await _reservationService.getMyReservations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createReservation(int bookId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _reservationService.createReservation(bookId);
      await fetchMyReservations();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelReservation(int reservationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _reservationService.cancelReservation(reservationId);
      await fetchMyReservations();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
