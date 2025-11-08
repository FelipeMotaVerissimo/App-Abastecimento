import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/veiculos/veiculos_screen.dart';
import '../screens/abastecimentos/registro_abastecimento_screen.dart';
import '../screens/abastecimentos/historico_abastecimento_screen.dart';
import '../screens/estatisticas_screen.dart';
import '../utils/page_transitions.dart'; // ← ADICIONAR

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? 'Usuário',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Controle de Abastecimento',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Meus Veículos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                FadePageRoute(page: const VeiculosScreen()), // ← COM ANIMAÇÃO
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_gas_station),
            title: const Text('Registrar Abastecimento'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                SlidePageRoute(page: const RegistroAbastecimentoScreen()), // ← COM ANIMAÇÃO
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histórico de Abastecimentos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                FadePageRoute(page: const HistoricoAbastecimentoScreen()), // ← COM ANIMAÇÃO
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Estatísticas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                SlidePageRoute(page: const EstatisticasScreen()), // ← COM ANIMAÇÃO
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar'),
                  content: const Text('Deseja realmente sair?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await authProvider.signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}