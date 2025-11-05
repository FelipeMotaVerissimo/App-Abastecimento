import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/abastecimento_provider.dart';
import '../../providers/veiculo_provider.dart';
import '../../models/abastecimento.dart';
import '../../models/veiculo.dart';

class HistoricoAbastecimentoScreen extends StatefulWidget {
  const HistoricoAbastecimentoScreen({super.key});

  @override
  State<HistoricoAbastecimentoScreen> createState() =>
      _HistoricoAbastecimentoScreenState();
}

class _HistoricoAbastecimentoScreenState
    extends State<HistoricoAbastecimentoScreen> {
  String? _veiculoFiltro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    final authProvider = context.read<AuthProvider>();
    final abastecimentoProvider = context.read<AbastecimentoProvider>();
    final veiculoProvider = context.read<VeiculoProvider>();

    if (authProvider.user != null) {
      veiculoProvider.carregarVeiculos(authProvider.user!.uid);
      abastecimentoProvider.carregarAbastecimentos(authProvider.user!.uid);
    }
  }

  void _aplicarFiltro(String? veiculoId) {
    final authProvider = context.read<AuthProvider>();
    final abastecimentoProvider = context.read<AbastecimentoProvider>();

    setState(() {
      _veiculoFiltro = veiculoId;
    });

    if (veiculoId == null) {
      abastecimentoProvider.carregarAbastecimentos(authProvider.user!.uid);
    } else {
      abastecimentoProvider.carregarAbastecimentosPorVeiculo(
        authProvider.user!.uid,
        veiculoId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Abastecimentos'),
        actions: [
          Consumer<VeiculoProvider>(
            builder: (context, veiculoProvider, _) {
              return PopupMenuButton<String?>(
                icon: const Icon(Icons.filter_list),
                onSelected: _aplicarFiltro,
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: null,
                      child: Text('Todos os veículos'),
                    ),
                    const PopupMenuDivider(),
                    ...veiculoProvider.veiculos.map((veiculo) {
                      return PopupMenuItem(
                        value: veiculo.id,
                        child: Text('${veiculo.marca} ${veiculo.modelo}'),
                      );
                    }),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_veiculoFiltro != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Consumer<VeiculoProvider>(
                      builder: (context, provider, _) {
                        final veiculo = provider.veiculos.firstWhere(
                          (v) => v.id == _veiculoFiltro,
                          orElse: () => Veiculo(
                            modelo: '',
                            marca: '',
                            placa: '',
                            ano: 0,
                            tipoCombustivel: '',
                            userId: '',
                          ),
                        );
                        return Text(
                          'Filtrado: ${veiculo.marca} ${veiculo.modelo}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () => _aplicarFiltro(null),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Consumer<AbastecimentoProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.abastecimentos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum abastecimento registrado',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.abastecimentos.length,
                  itemBuilder: (context, index) {
                    final abastecimento = provider.abastecimentos[index];
                    return _buildAbastecimentoCard(
                      context,
                      abastecimento,
                      provider,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbastecimentoCard(
    BuildContext context,
    Abastecimento abastecimento,
    AbastecimentoProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            Icons.local_gas_station,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          'R\$ ${abastecimento.valorPago.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy').format(abastecimento.data),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () =>
              _confirmarExclusao(context, abastecimento, provider),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  Icons.local_gas_station,
                  'Combustível',
                  abastecimento.tipoCombustivel,
                ),
                const Divider(),
                _buildInfoRow(
                  context,
                  Icons.opacity,
                  'Quantidade',
                  '${abastecimento.quantidadeLitros.toStringAsFixed(2)}L',
                ),
                const Divider(),
                _buildInfoRow(
                  context,
                  Icons.speed,
                  'Quilometragem',
                  '${abastecimento.quilometragem.toStringAsFixed(0)} km',
                ),
                const Divider(),
                _buildInfoRow(
                  context,
                  Icons.monetization_on,
                  'Preço por litro',
                  'R\$ ${abastecimento.precoPorLitro.toStringAsFixed(3)}',
                ),
                if (abastecimento.observacao != null) ...[
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.note,
                    'Observação',
                    abastecimento.observacao!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    Abastecimento abastecimento,
    AbastecimentoProvider provider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Deseja realmente excluir este abastecimento de '
          'R\$ ${abastecimento.valorPago.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await provider.excluirAbastecimento(abastecimento.id!);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abastecimento excluído com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}