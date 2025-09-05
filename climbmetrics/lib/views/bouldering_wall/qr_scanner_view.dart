import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/core/widgets/snackbar.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerView extends ConsumerStatefulWidget {
  const QrScannerView({super.key});

  @override
  ConsumerState<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends ConsumerState<QrScannerView> {
  
  late final ProviderSubscription<(ErrorState,BoulderingRouteModel?)> boulderingRouteSubscription;
  late final ProviderSubscription<dynamic> authSubscription;
  final _controller = MobileScannerController();
  bool _isTorchActive = false;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();

    final authStateCheck = StateCheck.auth();
    authSubscription = authStateCheck.check(
      context: context, 
      ref: ref
    );

    boulderingRouteSubscription = ref.listenManual(
      boulderingRouteNotifierProvider, 
      (previous, next) {
        final(
          ErrorState nextRouteErrorState,
          BoulderingRouteModel? nextBoulderingRoute
          ) = next;

        if (nextRouteErrorState.isNull() && nextBoulderingRoute != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(boulderingRouteRoute);
          });          
        }
      }
    );
  }

  void _toggleTorch() {
    setState(() {
      _isTorchActive = !_isTorchActive;
      _controller.toggleTorch();
    });
  }

  void _onDetect(BarcodeCapture capture) async {
    
    if (_hasScanned == true) {
      return;
    }
    
    final String? code = capture.barcodes.first.rawValue;
    if (code != null) {
      
      setState(() {
        _hasScanned = true;
      });
      
      String routeID = code.trim();
      
      BoulderingRouteNotifier routeNotifier = ref.read(boulderingRouteNotifierProvider.notifier);
      
      final (
        ErrorState boulderingRouteErrorState, 
        BoulderingRouteModel? boulderingRoute
        ) = await routeNotifier.fetchBoulderingRouteByBoulderingRouteID(routeID);
      
      if (!context.mounted) {
        return;
      }

      standardSnackBar(
        context: context, 
        nullCheckList: [boulderingRouteErrorState], 
        successText: 'Bouldering Route Scanned', 
        failureText: 'QR Code Not Recognised'
      );

      if (boulderingRouteErrorState.isNull() && boulderingRoute != null) {
        routeNotifier.selectBoulderingRoute(boulderingRoute);
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    boulderingRouteSubscription.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR scanner'),
        actions: [
          IconButton(
            onPressed: () {
              _toggleTorch();
            }, 
            icon: Icon(
              _isTorchActive ? Icons.flash_on_rounded : Icons.flash_off_rounded
            )
          )
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
      ),
    );
  }
}