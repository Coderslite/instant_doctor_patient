import 'package:get/get.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';

class SolonaController extends GetxController {
  final adapter = SolanaWalletAdapter(
    const AppIdentity(),
    // NOTE: CONNECT THE WALLET APPLICATION
    //       TO THE SAME NETWORK.
    cluster: Cluster.testnet,
  );
}
