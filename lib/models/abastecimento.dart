import 'package:cloud_firestore/cloud_firestore.dart';

class Abastecimento {
  final String? id;
  final DateTime data;
  final double quantidadeLitros;
  final double valorPago;
  final double quilometragem;
  final String tipoCombustivel;
  final String veiculoId;
  final double? consumo;
  final String? observacao;
  final String userId;

  Abastecimento({
    this.id,
    required this.data,
    required this.quantidadeLitros,
    required this.valorPago,
    required this.quilometragem,
    required this.tipoCombustivel,
    required this.veiculoId,
    this.consumo,
    this.observacao,
    required this.userId,
  });

  // Preço por litro
  double get precoPorLitro => valorPago / quantidadeLitros;

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'data': Timestamp.fromDate(data),
      'quantidadeLitros': quantidadeLitros,
      'valorPago': valorPago,
      'quilometragem': quilometragem,
      'tipoCombustivel': tipoCombustivel,
      'veiculoId': veiculoId,
      'consumo': consumo,
      'observacao': observacao,
      'userId': userId,
    };
  }

  // Criar instância a partir do Map (do Firestore)
  factory Abastecimento.fromMap(Map<String, dynamic> map, String id) {
    return Abastecimento(
      id: id,
      data: (map['data'] as Timestamp).toDate(),
      quantidadeLitros: (map['quantidadeLitros'] ?? 0).toDouble(),
      valorPago: (map['valorPago'] ?? 0).toDouble(),
      quilometragem: (map['quilometragem'] ?? 0).toDouble(),
      tipoCombustivel: map['tipoCombustivel'] ?? '',
      veiculoId: map['veiculoId'] ?? '',
      consumo: map['consumo']?.toDouble(),
      observacao: map['observacao'],
      userId: map['userId'] ?? '',
    );
  }

  // Copiar com alterações
  Abastecimento copyWith({
    String? id,
    DateTime? data,
    double? quantidadeLitros,
    double? valorPago,
    double? quilometragem,
    String? tipoCombustivel,
    String? veiculoId,
    double? consumo,
    String? observacao,
    String? userId,
  }) {
    return Abastecimento(
      id: id ?? this.id,
      data: data ?? this.data,
      quantidadeLitros: quantidadeLitros ?? this.quantidadeLitros,
      valorPago: valorPago ?? this.valorPago,
      quilometragem: quilometragem ?? this.quilometragem,
      tipoCombustivel: tipoCombustivel ?? this.tipoCombustivel,
      veiculoId: veiculoId ?? this.veiculoId,
      consumo: consumo ?? this.consumo,
      observacao: observacao ?? this.observacao,
      userId: userId ?? this.userId,
    );
  }
}