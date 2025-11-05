import 'package:flutter/material.dart';
import '../models/veiculo.dart';
import '../services/firestore_service.dart';

class VeiculoProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Veiculo> _veiculos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Veiculo> get veiculos => _veiculos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carregar veículos
  void carregarVeiculos(String userId) {
    _firestoreService.listarVeiculos(userId).listen(
      (veiculos) {
        _veiculos = veiculos;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Erro ao carregar veículos: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Adicionar veículo
  Future<bool> adicionarVeiculo(Veiculo veiculo) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      await _firestoreService.criarVeiculo(veiculo);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar veículo: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Excluir veículo
  Future<bool> excluirVeiculo(String id) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      await _firestoreService.excluirVeiculo(id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir veículo: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Buscar veículo por ID
  Future<Veiculo?> buscarVeiculo(String id) async {
    return await _firestoreService.buscarVeiculo(id);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}