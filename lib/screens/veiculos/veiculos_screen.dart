import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/veiculo_provider.dart';
import '../../models/veiculo.dart';
import 'cadastro_veiculo_screen.dart';

class VeiculosScreen extends StatefulWidget {
  const VeiculosScreen({super.key});

  @override
  State<VeiculosScreen> createState() => _VeiculosScreenState();
}

class _VeiculosScreenState extends State<VeiculosScreen> {
  @override
  void initState() {
    super.initState();
    _carregarVeiculos();
  }

  void _carregarVeiculos() {
    final authProvider = context.read<AuthProvider>();
    final veiculoProvider = context.read<VeiculoProvider>();
    
    if (authProvider.user != null) {
      veiculoProvider.carregarVeiculos(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Veículos'),
      ),
      body: Consumer<VeiculoProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.veiculos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum veículo cadastrado',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione seu primeiro veículo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.veiculos.length,
            itemBuilder: (context, index) {
              final veiculo = provider.veiculos[index];
              return _buildVeiculoCard(context, veiculo, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CadastroVeiculoScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Veículo'),
      ),
    );
  }

  Widget _buildVeiculoCard(
    BuildContext context,
    Veiculo veiculo,
    VeiculoProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.directions_car,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          '${veiculo.marca} ${veiculo.modelo}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Placa: ${veiculo.placa}'),
            Text('Ano: ${veiculo.ano}'),
            Text('Combustível: ${veiculo.tipoCombustivel}'),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmarExclusao(context, veiculo, provider),
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    Veiculo veiculo,
    VeiculoProvider provider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Deseja realmente excluir o veículo ${veiculo.marca} ${veiculo.modelo}?',
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
      final success = await provider.excluirVeiculo(veiculo.id!);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veículo excluído com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}