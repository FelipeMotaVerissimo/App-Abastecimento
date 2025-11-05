import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/veiculo_provider.dart';
import '../../models/veiculo.dart';

class CadastroVeiculoScreen extends StatefulWidget {
  const CadastroVeiculoScreen({super.key});

  @override
  State<CadastroVeiculoScreen> createState() => _CadastroVeiculoScreenState();
}

class _CadastroVeiculoScreenState extends State<CadastroVeiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modeloController = TextEditingController();
  final _marcaController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();
  
  String _tipoCombustivel = 'Gasolina';
  
  final List<String> _tiposCombustivel = [
    'Gasolina',
    'Etanol',
    'Diesel',
    'GNV',
    'Flex',
    'Elétrico',
    'Híbrido',
  ];

  @override
  void dispose() {
    _modeloController.dispose();
    _marcaController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  Future<void> _salvarVeiculo() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final veiculoProvider = context.read<VeiculoProvider>();

      final veiculo = Veiculo(
        modelo: _modeloController.text.trim(),
        marca: _marcaController.text.trim(),
        placa: _placaController.text.trim().toUpperCase(),
        ano: int.parse(_anoController.text),
        tipoCombustivel: _tipoCombustivel,
        userId: authProvider.user!.uid,
      );

      final success = await veiculoProvider.adicionarVeiculo(veiculo);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veículo cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(veiculoProvider.errorMessage ?? 'Erro ao cadastrar veículo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Veículo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cadastro de Veículo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  prefixIcon: Icon(Icons.branding_watermark),
                  hintText: 'Ex: Toyota, Honda, Fiat',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a marca do veículo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  prefixIcon: Icon(Icons.directions_car),
                  hintText: 'Ex: Corolla, Civic, Uno',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o modelo do veículo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  prefixIcon: Icon(Icons.pin),
                  hintText: 'Ex: ABC1234 ou ABC1D23',
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(7),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a placa do veículo';
                  }
                  if (value.length != 7) {
                    return 'A placa deve ter 7 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _anoController,
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'Ex: 2020',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o ano do veículo';
                  }
                  final ano = int.tryParse(value);
                  if (ano == null) {
                    return 'Digite um ano válido';
                  }
                  final anoAtual = DateTime.now().year;
                  if (ano < 1900 || ano > anoAtual + 1) {
                    return 'Digite um ano entre 1900 e ${anoAtual + 1}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _tipoCombustivel,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustível',
                  prefixIcon: Icon(Icons.local_gas_station),
                ),
                items: _tiposCombustivel.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoCombustivel = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              Consumer<VeiculoProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return FilledButton(
                    onPressed: _salvarVeiculo,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Cadastrar Veículo'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}