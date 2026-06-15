import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/scoring/grand_jeux.dart';
import '../../../providers/locale_provider.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.infoTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(s.combinationValues, _CombinationTable(s: s)),
          _Section(s.mahjongBonusesSection, _MahjongBonuses(s: s)),
          _Section(s.multipliersSection, _Multipliers(s: s)),
          _Section(s.specialExplanations, _SpecialExplanations(s: s)),
          _Section(s.pointsDistribution, _DistributionExplanation(s: s)),
          _Section(s.grandJeuxSection, _GrandJeuxList(s: s)),
          _LanguageSection(s: s),
          _CreatorSection(s: s),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.content);
  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
        const Divider(),
        content,
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CombinationTable extends StatelessWidget {
  const _CombinationTable({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final rows = s.combinationRows;
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        _header(context, [s.colCombination, s.colExposed, s.colHidden]),
        ...rows.map((r) => _row(r[0], r[1], r[2])),
      ],
    );
  }

  TableRow _header(BuildContext context, List<String> labels) => TableRow(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest),
        children: labels
            .map((l) => TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(l,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                )))
            .toList(),
      );

  TableRow _row(String name, String exp, String cach) => TableRow(
        children: [
          TableCell(
              child:
                  Padding(padding: const EdgeInsets.all(6), child: Text(name))),
          TableCell(
              child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(exp, textAlign: TextAlign.center))),
          TableCell(
              child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(cach, textAlign: TextAlign.center))),
        ],
      );
}

class _MahjongBonuses extends StatelessWidget {
  const _MahjongBonuses({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return _BulletList(s.mahjongBonusesList);
  }
}

class _Multipliers extends StatelessWidget {
  const _Multipliers({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return _BulletList(s.multipliersList);
  }
}

class _SpecialExplanations extends StatelessWidget {
  const _SpecialExplanations({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(title: s.vocabTitle, body: s.vocabBody),
        const SizedBox(height: 8),
        _InfoCard(title: s.assocTitle, body: s.assocBody),
        const SizedBox(height: 8),
        _InfoCard(title: s.capTitle, body: s.capBody),
        const SizedBox(height: 8),
        _InfoCard(title: s.callingHandTitle, body: s.callingHandBody),
        const SizedBox(height: 8),
        _InfoCard(title: s.moonTitle, body: s.moonBody),
        const SizedBox(height: 8),
        _InfoCard(title: s.stealKongTitle, body: s.stealKongBody),
        const SizedBox(height: 8),
        _InfoCard(title: s.firstDealTitle, body: s.firstDealBody),
      ],
    );
  }
}

class _DistributionExplanation extends StatelessWidget {
  const _DistributionExplanation({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(title: s.eastRuleTitle, body: s.eastRuleBody),
        const SizedBox(height: 8),
        _InfoCard(title: s.mahjongPaymentTitle, body: s.mahjongPaymentBody),
        const SizedBox(height: 8),
        _InfoCard(title: s.differentialTitle, body: s.differentialBody),
      ],
    );
  }
}

class _GrandJeuxList extends StatelessWidget {
  const _GrandJeuxList({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: GrandJeux.all.map((gj) {
        final desc = s.isEn ? gj.descriptionEn : gj.description;
        return ExpansionTile(
          dense: true,
          tilePadding: EdgeInsets.zero,
          title: Row(
            children: [
              Expanded(child: Text(s.isEn ? gj.nameEn : gj.name)),
              Text(
                '${gj.points} pts',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  desc,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// Language toggle section
class _LanguageSection extends ConsumerWidget {
  const _LanguageSection({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          s.languageSection,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: cs.primary),
        ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('🇫🇷  Français'),
                selected: locale == AppLocale.fr || locale == null,
                onSelected: (_) =>
                    ref.read(localeProvider.notifier).setLocale(AppLocale.fr),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('🇬🇧  English'),
                selected: locale == AppLocale.en,
                onSelected: (_) =>
                    ref.read(localeProvider.notifier).setLocale(AppLocale.en),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// Creator/X link section
class _CreatorSection extends StatelessWidget {
  const _CreatorSection({required this.s});
  final AppStrings s;

  static final Uri _xUri = Uri.parse('https://x.com/Lockast');
  static final Uri _gitHubUri = Uri.parse('https://github.com/Lockast');

  Future<void> _openUri(BuildContext context, Uri uri, String errorMsg) async {
    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(s.creatorSection,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: cs.primary)),
        const Divider(),
        // "Vibecoded avec/with Claude Code" label above the cards
        Text(
          s.vibecoded,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.onSurface.withAlpha(120)),
        ),
        const SizedBox(height: 8),
        // X profile card
        Card(
          margin: EdgeInsets.zero,
          color: cs.surfaceContainerHighest.withAlpha(120),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openUri(context, _xUri, s.xLinkError),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const _XLogo(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('@Lockast',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(s.followOnX, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.open_in_new, size: 18),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // GitHub profile card
        Card(
          margin: EdgeInsets.zero,
          color: cs.surfaceContainerHighest.withAlpha(120),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openUri(context, _gitHubUri, s.gitHubLinkError),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const _GitHubLogo(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Lockast',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(s.followOnGitHub,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.open_in_new, size: 18),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Small circular X (Twitter) logo.
class _XLogo extends StatelessWidget {
  const _XLogo();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 18,
      backgroundColor: cs.onSurface,
      child: Text(
        '𝕏',
        style: TextStyle(
          color: cs.surface,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

/// Small circular GitHub logo.
class _GitHubLogo extends StatelessWidget {
  const _GitHubLogo();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 36,
        height: 36,
        color: const Color(0xFF24292E),
        padding: const EdgeInsets.all(5),
        child: Image.asset(
          'assets/app_icon/GitHub.png',
          color: Colors.white,
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _BulletList extends StatelessWidget {
  const _BulletList(this.items);
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $item'),
              ))
          .toList(),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(body),
          ],
        ),
      ),
    );
  }
}
