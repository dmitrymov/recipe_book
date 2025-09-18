import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recipes_provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipesProvider>();
    final premium = provider.premiumService;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Premium'),
            subtitle: Text(premium.isPaid ? 'Purchased' : 'Not purchased'),
            trailing: ElevatedButton(
              onPressed: premium.isPaid
                  ? null
                  : () {
                      context.read<RecipesProvider>().purchasePremium();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Premium unlocked (stub).')),
                      );
                    },
              child: Text(premium.isPaid ? 'Owned' : 'Buy'),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Sync to cloud'),
            subtitle: const Text('Upload your recipes (premium only)'),
            trailing: ElevatedButton(
              onPressed: premium.isPaid ? provider.syncToCloud : null,
              child: const Text('Upload'),
            ),
          ),
          ListTile(
            title: const Text('Sync from cloud'),
            trailing: ElevatedButton(
              onPressed: premium.isPaid ? provider.syncFromCloud : null,
              child: const Text('Download'),
            ),
          ),
        ],
      ),
    );
  }
}
