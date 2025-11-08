import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/abastecimento_provider.dart';
import '../providers/veiculo_provider.dart';

class EstatisticasScreen extends StatefulWidget {
  const EstatisticasScreen({super.key});

  @override
  State<EstatisticasScreen> createState() => _EstatisticasScreenState();
}

class _EstatisticasScreenState extends State<EstatisticasScreen> {
  String? _veiculoSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    final authProvider = context.read<AuthProvider>();
    final veiculoProvider = context.read<VeiculoProvider>();
    final abastecimentoProvider = context.read<AbastecimentoProvider>();

    if (authProvider.user != null) {
      veiculoProvider.carregarVeiculos(authProvider.user!.uid);
      abastecimentoProvider.carregarAbastecimentos(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de veículo
            Consumer<VeiculoProvider>(
              builder: (context, veiculoProvider, _) {
                if (veiculoProvider.veiculos.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nenhum veículo cadastrado para exibir estatísticas.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      value: _veiculoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Selecione um veículo',
                        prefixIcon: Icon(Icons.directions_car),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todos os veículos'),
                        ),
                        ...veiculoProvider.veiculos.map((veiculo) {
                          return DropdownMenuItem(
                            value: veiculo.id,
                            child: Text('${veiculo.marca} ${veiculo.modelo}'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _veiculoSelecionado = value;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Gráfico de gastos mensais
            Text(
              'Gastos Mensais',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer<AbastecimentoProvider>(
              builder: (context, provider, _) {
                final abastecimentos = _veiculoSelecionado == null
                    ? provider.abastecimentos
                    : provider.abastecimentos
                        .where((a) => a.veiculoId == _veiculoSelecionado)
                        .toList();

                if (abastecimentos.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('Nenhum dado disponível'),
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 300,
                      child: _buildGraficoGastos(context, abastecimentos),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Gráfico de preço por litro
            Text(
              'Variação de Preço por Litro',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer<AbastecimentoProvider>(
              builder: (context, provider, _) {
                final abastecimentos = _veiculoSelecionado == null
                    ? provider.abastecimentos
                    : provider.abastecimentos
                        .where((a) => a.veiculoId == _veiculoSelecionado)
                        .toList();

                if (abastecimentos.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('Nenhum dado disponível'),
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 300,
                      child: _buildGraficoPrecoLitro(context, abastecimentos),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Consumo médio
            if (_veiculoSelecionado != null)
              FutureBuilder<double?>(
                future: context
                    .read<AbastecimentoProvider>()
                    .calcularConsumoMedio(_veiculoSelecionado!),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.speed,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Consumo Médio',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.data!.toStringAsFixed(2)} km/L',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoGastos(BuildContext context, List abastecimentos) {
    // Agrupar por mês
    final Map<String, double> gastosPorMes = {};
    for (var abast in abastecimentos) {
      final mes = DateFormat('MM/yy').format(abast.data);
      gastosPorMes[mes] = (gastosPorMes[mes] ?? 0) + abast.valorPago;
    }

    // Pegar últimos 6 meses
    final meses = gastosPorMes.keys.toList()..sort();
    final ultimos6 = meses.length > 6 ? meses.sublist(meses.length - 6) : meses;

    if (ultimos6.isEmpty) {
      return const Center(child: Text('Sem dados suficientes'));
    }

    final spots = ultimos6.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        gastosPorMes[entry.value]!,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < ultimos6.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      ultimos6[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  'R\$ ${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoPrecoLitro(BuildContext context, List abastecimentos) {
    // Ordenar por data
    final sorted = [...abastecimentos]..sort((a, b) => a.data.compareTo(b.data));
    
    // Pegar últimos 10 abastecimentos
    final ultimos = sorted.length > 10 ? sorted.sublist(sorted.length - 10) : sorted;

    if (ultimos.isEmpty) {
      return const Center(child: Text('Sem dados suficientes'));
    }

    final spots = ultimos.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.precoPorLitro,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < ultimos.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(ultimos[value.toInt()].data),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  'R\$ ${value.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}