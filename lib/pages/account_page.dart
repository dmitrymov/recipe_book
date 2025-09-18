import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recipes_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipesProvider>();
    final premium = provider.premiumService;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.account),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language selector
          ListTile(
            title: Text(AppLocalizations.of(context)!.language),
            trailing: DropdownButton<Locale?>(
              value: context.watch<LocaleProvider>().locale,
              hint: Text(AppLocalizations.of(context)!.system_default),
              onChanged: (loc) => context.read<LocaleProvider>().setLocale(loc),
              items: const [
                DropdownMenuItem<Locale?>(value: null, child: Text('System')),
                DropdownMenuItem<Locale?>(value: Locale('en'), child: Text('English')),
                DropdownMenuItem<Locale?>(value: Locale('fr'), child: Text('Français')),
                DropdownMenuItem<Locale?>(value: Locale('he'), child: Text('עברית')),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context)!.premium),
            subtitle: Text(premium.isPaid ? AppLocalizations.of(context)!.premium_purchased : AppLocalizations.of(context)!.premium_not_purchased),
            trailing: ElevatedButton(
              onPressed: premium.isPaid
                  ? null
                  : () {
                      context.read<RecipesProvider>().purchasePremium();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Premium unlocked (stub).')),
                      );
                    },
              child: Text(premium.isPaid ? AppLocalizations.of(context)!.owned : AppLocalizations.of(context)!.buy),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context)!.sync_to_cloud),
            subtitle: Text('${AppLocalizations.of(context)!.upload} your recipes (premium only)'),
            trailing: ElevatedButton(
              onPressed: premium.isPaid ? provider.syncToCloud : null,
              child: Text(AppLocalizations.of(context)!.upload),
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.sync_from_cloud),
            trailing: ElevatedButton(
              onPressed: premium.isPaid ? provider.syncFromCloud : null,
              child: Text(AppLocalizations.of(context)!.download),
            ),
          ),
        ],
      ),
    );
  }
}
