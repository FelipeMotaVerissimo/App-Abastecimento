import 'package:flutter/material.dart';
import '../models/abastecimento.dart';
import '../services/firestore_service.dart';

class AbastecimentoProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Abastecimento> _abastecimentos = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _estatisticas;

  List<Abastecimento> get abastecimentos => _abastecimentos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get estatisticas => _estatisticas;

  // Carregar abastecimentos
  void carregarAbastecimentos(String userId) {
    _firestoreService.listarAbastecimentos(userId).listen(
      (abastecimentos) {
        _abastecimentos = abastecimentos;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Erro ao carregar abastecimentos: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Carregar abastecimentos por veículo
  void carregarAbastecimentosPorVeiculo(String userId, String veiculoId) {
    _firestoreService.listarAbastecimentosPorVeiculo(userId, veiculoId).listen(
      (abastecimentos) {
        _abastecimentos = abastecimentos;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Erro ao carregar abastecimentos: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Adicionar abastecimento
  Future<bool> adicionarAbastecimento(Abastecimento abastecimento) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      await _firestoreService.criarAbastecimento(abastecimento);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar abastecimento: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Excluir abastecimento
  Future<bool> excluirAbastecimento(String id) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      await _firestoreService.excluirAbastecimento(id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir abastecimento: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Calcular consumo médio
  Future<double?> calcularConsumoMedio(String veiculoId) async {
    return await _firestoreService.calcularConsumoMedio(veiculoId);
  }

  // Carregar estatísticas
  Future<void> carregarEstatisticas(String userId) async {
    try {
      _estatisticas = await _firestoreService.obterEstatisticas(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar estatísticas: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}