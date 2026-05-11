import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/CurrencyModel.dart';
import 'package:instant_doctor/services/CurrencyService.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../controllers/UserController.dart';

class CurrencyPickerSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const CurrencyPickerSheet({super.key, required this.onSaved});

  static void showIfNeeded(BuildContext context) {
    return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => CurrencyPickerSheet(
        onSaved: () => Navigator.pop(context),
      ),
    );
  }

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  final UserController userController = Get.find();
  List<CurrencyModel> currencies = [];
  List<CurrencyModel> filtered = [];
  String? selected;
  bool isLoading = true;
  bool isSaving = false;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    handleGetCurrencies();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  handleGetCurrencies() async {
    var currencyService = Get.find<CurrencyService>();
    currencies = await currencyService.getAvailableCurrencies();
    filtered = [...currencies];
    isLoading = false;
    setState(() {});
  }

  void _filter(String q) {
    final lower = q.toLowerCase();
    setState(() {
      filtered = currencies
          .where((c) =>
              c.symbol!.toLowerCase().contains(lower) ||
              c.symbol!.toLowerCase().contains(lower))
          .toList();
    });
  }

  Future<void> _save() async {
    if (selected == null || isSaving) return;
    HapticFeedback.mediumImpact();
    setState(() => isSaving = true);
    await userService.updateProfile(
      data: {"currency": selected},
      userId: userController.userId.value,
    );
    setState(() => isSaving = false);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 32 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Header ───────────────────────────────────────────────────────
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.currency_exchange_rounded,
                  color: kPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Select Currency',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: ink,
                      letterSpacing: -0.3)),
              const SizedBox(height: 2),
              Text('Required to display pricing',
                  style: TextStyle(fontSize: 12, color: slate)),
            ]),
          ]),
          const SizedBox(height: 20),

          // ── Search ───────────────────────────────────────────────────────
          TextField(
            controller: _search,
            onChanged: _filter,
            style: const TextStyle(fontSize: 13.5, color: ink),
            decoration: InputDecoration(
              hintText: 'Search currency…',
              hintStyle: const TextStyle(fontSize: 13, color: slate),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: slate, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: kPrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── List ─────────────────────────────────────────────────────────
          if (isLoading)
            const _CurrencyShimmer()
          else if (filtered.isEmpty)
            _EmptySearch()
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.36,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final c = filtered[i];
                  final isOn = selected == c.symbol;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => selected = c.symbol);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isOn
                            ? kPrimary.withOpacity(0.04)
                            : const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isOn ? kPrimary : border,
                          width: isOn ? 1.8 : 1.2,
                        ),
                        boxShadow: isOn
                            ? [
                                BoxShadow(
                                    color: kPrimary.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ]
                            : [],
                      ),
                      child: Row(children: [
                        // Symbol chip
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isOn
                                ? kPrimary.withOpacity(0.12)
                                : const Color(0xFFEEF2F8),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Center(
                            child: Text(
                              c.symbol.validate(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isOn ? kPrimary : slate,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Container()),
                        // Check circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOn ? kPrimary : Colors.transparent,
                            border: Border.all(
                              color: isOn ? kPrimary : border,
                              width: 2,
                            ),
                          ),
                          child: isOn
                              ? const Icon(Icons.check_rounded,
                                  size: 13, color: white)
                              : null,
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),

          // ── Save button ──────────────────────────────────────────────────
          GestureDetector(
            onTap: selected != null ? _save : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: selected != null
                    ? LinearGradient(colors: [kPrimary, kPrimaryDark])
                    : null,
                color: selected != null ? null : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(14),
                boxShadow: selected != null
                    ? [
                        BoxShadow(
                            color: kPrimary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4))
                      ]
                    : [],
              ),
              child: Center(
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: white),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selected != null
                                ? 'Confirm Currency'
                                : 'Select a currency',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: white,
                                letterSpacing: 0.1),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer ──────────────────────────────────────────────────────────────────
class _CurrencyShimmer extends StatefulWidget {
  const _CurrencyShimmer();
  @override
  State<_CurrencyShimmer> createState() => _CurrencyShimmerState();
}

class _CurrencyShimmerState extends State<_CurrencyShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300))
      ..repeat();
    _anim = Tween<double>(begin: -2.0, end: 2.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (_) => AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment(_anim.value - 1, 0),
                end: Alignment(_anim.value + 1, 0),
                colors: const [
                  Color(0xFFEEF2F8),
                  Color(0xFFF8FAFF),
                  Color(0xFFEEF2F8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty search state ───────────────────────────────────────────────────────
class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(children: [
          Icon(Icons.search_off_rounded,
              size: 32, color: slate.withOpacity(0.5)),
          const SizedBox(height: 8),
          const Text('No currencies found',
              style: TextStyle(fontSize: 13, color: slate)),
        ]),
      ),
    );
  }
}
