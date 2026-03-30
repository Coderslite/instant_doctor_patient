// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/OrderModel.dart';
import 'package:instant_doctor/screens/drug/TrackOrder.dart';
import 'package:instant_doctor/screens/pharmacy/Pharmacies.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/check_country.dart';
import '../../component/check_internet.dart';
import '../../component/eachOrder.dart';
import '../../services/OrderService.dart';

// ─── Palette ───────────────────────────────────────────────────────────────────
const _obsidian = Color(0xFF0A1628);
const _pageGray = Color(0xFFF0F4FA);
const _white    = Colors.white;
const _ink      = Color(0xFF0F2744);
const _slate    = Color(0xFF5E7A99);
const _border   = Color(0xFFE5EAF4);

// ─────────────────────────────────────────────────────────────────────────────
class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});
  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory>
    with TickerProviderStateMixin {

  final orderService = Get.find<OrderService>();

  late final AnimationController _shimCtrl;
  late final Animation<double>   _shimAnim;
  late final AnimationController _fabCtrl;
  late final Animation<double>   _fabPulse;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _shimCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1300))..repeat();
    _shimAnim = Tween<double>(begin: -2.0, end: 2.0).animate(
        CurvedAnimation(parent: _shimCtrl, curve: Curves.linear));

    _fabCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _fabPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fabCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shimCtrl.dispose();
    _fabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageGray,
      body: Column(children: [

        // ── Obsidian header ──────────────────────────────────────────────
        Container(
          color: _obsidian,
          child: SafeArea(
            bottom: false,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                child: Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order History',
                          style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: _white, letterSpacing: -0.5,
                          )),
                      const SizedBox(height: 4),
                      Text('Track and manage your pharmacy orders',
                          style: TextStyle(
                              fontSize: 12,
                              color: _white.withOpacity(0.4))),
                    ],
                  )),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _white.withOpacity(0.12), width: 1),
                    ),
                    child: Icon(Icons.shopping_bag_outlined,
                        color: _white.withOpacity(0.8), size: 19),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              // Bridge curve into page background
              Container(
                height: 26,
                decoration: const BoxDecoration(
                  color: _pageGray,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(26)),
                ),
              ),
            ]),
          ),
        ),

        internetCheck(),
        countryCheck(),

        // ── List ─────────────────────────────────────────────────────────
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: orderService.getMyOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _ShimmerList(shimAnim: _shimAnim);
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _EmptyState(
                    onOrder: () => PharmaciesScreen().launch(context));
              }
              final data = snapshot.data!;
              return AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (_, i) =>
                      AnimationConfiguration.staggeredList(
                        position: i,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          verticalOffset: 30,
                          child: FadeInAnimation(
                            child: eachOrder(context, data[i], onTap: () {
                              HapticFeedback.selectionClick();
                              OrderTracker(
                                orderId: data[i].id.validate(),
                              ).launch(context);
                            }),
                          ),
                        ),
                      ),
                ),
              );
            },
          ),
        ),
      ]),

      // ── Glowing FAB ──────────────────────────────────────────────────────
      floatingActionButton: AnimatedBuilder(
        animation: _fabPulse,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64 + _fabPulse.value * 10,
              height: 64 + _fabPulse.value * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary
                    .withOpacity(0.16 * (1 - _fabPulse.value)),
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                PharmaciesScreen().launch(context);
              },
              backgroundColor: kPrimary,
              elevation: 0,
              child: const Icon(Icons.add_rounded,
                  color: _white, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHIMMER LOADING
// =============================================================================
class _ShimmerList extends StatelessWidget {
  final Animation<double> shimAnim;
  const _ShimmerList({required this.shimAnim});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedBuilder(
          animation: shimAnim,
          builder: (_, __) => Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment(shimAnim.value - 1, 0),
                end: Alignment(shimAnim.value + 1, 0),
                colors: const [
                  Color(0xFFE8EDF5),
                  Colors.white,
                  Color(0xFFE8EDF5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================
class _EmptyState extends StatelessWidget {
  final VoidCallback onOrder;
  const _EmptyState({required this.onOrder});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(alignment: Alignment.center, children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withOpacity(0.06),
                ),
              ),
              Container(
                width: 74, height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withOpacity(0.10),
                ),
              ),
              Icon(Icons.shopping_bag_outlined,
                  size: 36, color: kPrimary.withOpacity(0.55)),
            ]),
            const SizedBox(height: 24),
            const Text('No Orders Yet',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: _ink, letterSpacing: -0.4,
                )),
            const SizedBox(height: 10),
            Text(
              'Your pharmacy orders will appear here.\nBrowse our catalogue and place your first order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.5, color: _slate, height: 1.55),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onOrder();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [kPrimary, kPrimaryDark]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_outlined,
                        color: _white, size: 18),
                    SizedBox(width: 8),
                    Text('Browse Pharmacy',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _white,
                          letterSpacing: 0.1,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}