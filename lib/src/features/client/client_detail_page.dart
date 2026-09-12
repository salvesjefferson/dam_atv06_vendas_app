import 'package:flutter/material.dart';
import 'package:vendas_app/src/models/client_model.dart';

class ClientDetailPage extends StatelessWidget {
  const ClientDetailPage({super.key});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final client =
        ModalRoute.of(context)!.settings.arguments as ClientModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Cliente'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      client.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    Text('E-mail: ${client.email}'),
                    const SizedBox(height: 12),

                    Text('Telefone: ${client.phone}'),
                    const SizedBox(height: 12),

                    if (client.birthDate != null) ...[
                      Text(
                        'Data de nascimento: ${_formatDate(client.birthDate!)}',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Idade: ${client.age} anos',
                      ),
                    ] else
                      const Text(
                        'Data de nascimento não informada',
                      ),
                  ],
                ),
              ),
          ),
        )
      ),
    );
  }
}