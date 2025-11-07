import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/veiculo_provider.dart';
import '../../providers/abastecimento_provider.dart';
import '../../models/abastecimento.dart';

class RegistroAbastecimentoScreen extends StatefulWidget {
  const RegistroAbastecimentoScreen({super.key});

  @override
  State<RegistroAbastecimentoScreen> createState() =>
      _RegistroAbastecimentoScreenState();
}

class _RegistroAbastecimentoScreenState
    extends State<RegistroAbastecimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeLitrosController = TextEditingController();
  final _valorPagoController = TextEditingController();
  final _quilometragemController = TextEditingController();
  final _observacaoController = TextEditingController();

  DateTime _dataSelecionada = DateTime.now();
  String? _veiculoIdSelecionado;
  String _tipoCombustivel = 'Gasolina';

  final List<String> _tiposCombustivel = [
    'Gasolina',
    'Etanol',
    'Diesel',
    'GNV',
  ];

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
  void dispose() {
    _quantidadeLitrosController.dispose();
    _valorPagoController.dispose();
    _quilometragemController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  Future<void> _salvarAbastecimento() async {
    if (_formKey.currentState!.validate()) {
      if (_veiculoIdSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um veículo'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final abastecimentoProvider = context.read<AbastecimentoProvider>();

      final abastecimento = Abastecimento(
        data: _dataSelecionada,
        quantidadeLitros: double.parse(_quantidadeLitrosController.text),
        valorPago: double.parse(_valorPagoController.text),
        quilometragem: double.parse(_quilometragemController.text),
        tipoCombustivel: _tipoCombustivel,
        veiculoId: _veiculoIdSelecionado!,
        observacao: _observacaoController.text.isEmpty
            ? null
            : _observacaoController.text,
        userId: authProvider.user!.uid,
      );

      final success =
          await abastecimentoProvider.adicionarAbastecimento(abastecimento);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abastecimento registrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(abastecimentoProvider.errorMessage ??
                'Erro ao registrar abastecimento'),
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
        title: const Text('Registrar Abastecimento'),
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
                        Icons.local_gas_station,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Novo Abastecimento',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<VeiculoProvider>(
                builder: (context, provider, _) {
                  if (provider.veiculos.isEmpty) {
                    return Card(
                      color: Colors.orange[100],
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Você precisa cadastrar um veículo primeiro!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _veiculoIdSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Veículo',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                    items: provider.veiculos.map((veiculo) {
                      return DropdownMenuItem(
                        value: veiculo.id,
                        child: Text('${veiculo.marca} ${veiculo.modelo}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _veiculoIdSelecionado = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione um veículo';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data do Abastecimento',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_dataSelecionada),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeLitrosController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade (Litros)',
                  prefixIcon: Icon(Icons.local_gas_station),
                  hintText: 'Ex: 45.5',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a quantidade de litros';
                  }
                  final litros = double.tryParse(value);
                  if (litros == null || litros <= 0) {
                    return 'Digite uma quantidade válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorPagoController,
                decoration: const InputDecoration(
                  labelText: 'Valor Pago (R\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'Ex: 250.00',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o valor pago';
                  }
                  final valor = double.tryParse(value);
                  if (valor == null || valor <= 0) {
                    return 'Digite um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quilometragemController,
                decoration: const InputDecoration(
                  labelText: 'Quilometragem (Km)',
                  prefixIcon: Icon(Icons.speed),
                  hintText: 'Ex: 15000',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a quilometragem';
                  }
                  final km = double.tryParse(value);
                  if (km == null || km < 0) {
                    return 'Digite uma quilometragem válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _tipoCombustivel,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Combustível',
                  prefixIcon: Icon(Icons.oil_barrel),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacaoController,
                decoration: const InputDecoration(
                  labelText: 'Observação (Opcional)',
                  prefixIcon: Icon(Icons.note),
                  hintText: 'Ex: Posto X, promoção',
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),
              Consumer<AbastecimentoProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return FilledButton(
                    onPressed: _salvarAbastecimento,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Registrar Abastecimento'),
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