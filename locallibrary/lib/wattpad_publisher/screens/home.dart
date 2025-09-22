import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../widgets/aside.dart';
import '../widgets/content_router.dart';
import '../widgets/gradient_backdrop.dart';
import '../widgets/inner_shadow_gradient_pane.dart';
import '../widgets/nav_bar.dart';
import '../widgets/rounded_content_outer.dart';
import '../widgets/shadowed_panel.dart';
import '../widgets/single_window_activator_button.dart';
import '../widgets/two_pane_row.dart';

class WDHome extends StatelessWidget {
  const WDHome({super.key});

  @override
  Widget build(BuildContext context) {
    final marginW = MediaQuery.of(context).size.width / 20;
    final sideSize = MediaQuery.of(context).size.width / 5.5;

    return GradientBackdrop(
      // keep your original background gradient
      // gradient: const LinearGradient(
      //   colors: [Colors.white, AppPalette.secondary],
      //   begin: Alignment.topLeft,
      //   end: Alignment.bottomRight,
      // ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ShadowedPanel(
          margin: EdgeInsets.all(marginW),
          radius: const BorderRadius.all(Radius.circular(25)),
          shadow: const [
            BoxShadow(
              color: AppPalette.mainShadow,
              offset: Offset(-1, 6),
              blurRadius: 34.6,
              spreadRadius: -5,
            ),
          ],
          child: TwoPaneRow(
            // sidebar (keeps your Aside + NavBar.defaults)
            sidebar: Aside(
              width: sideSize,
              top: NavBar.defaults(),
              // bottom: const SizedBox.shrink(),
              bottom: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SingleWindowActivatorButton.settings(),
                    SingleWindowActivatorButton.scrape(),
                  ],
                ),
              ),
            ),

            // main content area (rounded outer, inner gradient + inner shadow)
            content: const RoundedContentOuter(
              child: InnerShadowGradientPane(child: ContentRouter()),
            ),
          ),
        ),
      ),
    );
  }
}
