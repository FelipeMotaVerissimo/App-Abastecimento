import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== VEÍCULOS ==========

  // Criar veículo
  Future<void> criarVeiculo(Veiculo veiculo) async {
    await _firestore.collection('veiculos').add(veiculo.toMap());
  }

  // Listar veículos do usuário
  Stream<List<Veiculo>> listarVeiculos(String userId) {
    return _firestore
        .collection('veiculos')
        .where('userId', isEqualTo: userId)
        .orderBy('marca')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Veiculo.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Buscar veículo por ID
  Future<Veiculo?> buscarVeiculo(String id) async {
    final doc = await _firestore.collection('veiculos').doc(id).get();
    if (doc.exists) {
      return Veiculo.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Excluir veículo
  Future<void> excluirVeiculo(String id) async {
    // Excluir todos os abastecimentos do veículo primeiro
    final abastecimentos = await _firestore
        .collection('abastecimentos')
        .where('veiculoId', isEqualTo: id)
        .get();
    
    for (var doc in abastecimentos.docs) {
      await doc.reference.delete();
    }
    
    // Excluir o veículo
    await _firestore.collection('veiculos').doc(id).delete();
  }
  // Atualizar quilometragem do veículo
  Future<void> atualizarQuilometragem(String veiculoId, double quilometragem) async {
    await _firestore.collection('veiculos').doc(veiculoId).update({
      'quilometragemAtual': quilometragem,
    });
  }
  // ========== ABASTECIMENTOS ==========

  // Criar abastecimento
  Future<void> criarAbastecimento(Abastecimento abastecimento) async {
    await _firestore.collection('abastecimentos').add(abastecimento.toMap());
  }

  // Listar abastecimentos do usuário
  Stream<List<Abastecimento>> listarAbastecimentos(String userId) {
    return _firestore
        .collection('abastecimentos')
        .where('userId', isEqualTo: userId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Abastecimento.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Listar abastecimentos de um veículo específico
  Stream<List<Abastecimento>> listarAbastecimentosPorVeiculo(
    String userId,
    String veiculoId,
  ) {
    return _firestore
        .collection('abastecimentos')
        .where('userId', isEqualTo: userId)
        .where('veiculoId', isEqualTo: veiculoId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Abastecimento.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Excluir abastecimento
  Future<void> excluirAbastecimento(String id) async {
    await _firestore.collection('abastecimentos').doc(id).delete();
  }

  // Calcular consumo médio de um veículo
  Future<double?> calcularConsumoMedio(String veiculoId) async {
    final abastecimentos = await _firestore
        .collection('abastecimentos')
        .where('veiculoId', isEqualTo: veiculoId)
        .orderBy('quilometragem')
        .get();

    if (abastecimentos.docs.length < 2) {
      return null;
    }

    final lista = abastecimentos.docs
        .map((doc) => Abastecimento.fromMap(doc.data(), doc.id))
        .toList();

    double totalLitros = 0;
    double kmRodados = 0;

    for (int i = 1; i < lista.length; i++) {
      totalLitros += lista[i].quantidadeLitros;
      kmRodados += lista[i].quilometragem - lista[i - 1].quilometragem;
    }

    if (totalLitros == 0) return null;
    return kmRodados / totalLitros;
  }

  // Obter estatísticas gerais
  Future<Map<String, dynamic>> obterEstatisticas(String userId) async {
    final abastecimentos = await _firestore
        .collection('abastecimentos')
        .where('userId', isEqualTo: userId)
        .get();

    if (abastecimentos.docs.isEmpty) {
      return {
        'totalGasto': 0.0,
        'totalLitros': 0.0,
        'totalAbastecimentos': 0,
        'mediaPrecoLitro': 0.0,
      };
    }

    double totalGasto = 0;
    double totalLitros = 0;

    for (var doc in abastecimentos.docs) {
      final abast = Abastecimento.fromMap(doc.data(), doc.id);
      totalGasto += abast.valorPago;
      totalLitros += abast.quantidadeLitros;
    }

    return {
      'totalGasto': totalGasto,
      'totalLitros': totalLitros,
      'totalAbastecimentos': abastecimentos.docs.length,
      'mediaPrecoLitro': totalLitros > 0 ? totalGasto / totalLitros : 0.0,
    };
  }
}