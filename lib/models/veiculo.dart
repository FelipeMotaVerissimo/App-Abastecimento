class Veiculo {
  final String? id;
  final String modelo;
  final String marca;
  final String placa;
  final int ano;
  final String tipoCombustivel;
  final String userId;
  final double quilometragemAtual; // ← NOVO CAMPO

  Veiculo({
    this.id,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.ano,
    required this.tipoCombustivel,
    required this.userId,
    this.quilometragemAtual = 0, // ← VALOR PADRÃO
  });

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'modelo': modelo,
      'marca': marca,
      'placa': placa,
      'ano': ano,
      'tipoCombustivel': tipoCombustivel,
      'userId': userId,
      'quilometragemAtual': quilometragemAtual, // ← ADICIONAR
    };
  }

  // Criar instância a partir do Map (do Firestore)
  factory Veiculo.fromMap(Map<String, dynamic> map, String id) {
    return Veiculo(
      id: id,
      modelo: map['modelo'] ?? '',
      marca: map['marca'] ?? '',
      placa: map['placa'] ?? '',
      ano: map['ano'] ?? 0,
      tipoCombustivel: map['tipoCombustivel'] ?? '',
      userId: map['userId'] ?? '',
      quilometragemAtual: (map['quilometragemAtual'] ?? 0).toDouble(), // ← ADICIONAR
    );
  }

  // Copiar com alterações
  Veiculo copyWith({
    String? id,
    String? modelo,
    String? marca,
    String? placa,
    int? ano,
    String? tipoCombustivel,
    String? userId,
    double? quilometragemAtual, // ← ADICIONAR
  }) {
    return Veiculo(
      id: id ?? this.id,
      modelo: modelo ?? this.modelo,
      marca: marca ?? this.marca,
      placa: placa ?? this.placa,
      ano: ano ?? this.ano,
      tipoCombustivel: tipoCombustivel ?? this.tipoCombustivel,
      userId: userId ?? this.userId,
      quilometragemAtual: quilometragemAtual ?? this.quilometragemAtual, // ← ADICIONAR
    );
  }
}