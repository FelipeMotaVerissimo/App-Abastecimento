import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/veiculo.dart';

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
    await _firestore.collection('veiculos').doc(id).delete();
  }
}