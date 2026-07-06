import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:build_wise/features/onboarding/presentation/walkthrough_card.dart';
import 'package:build_wise/features/onboarding/presentation/walkthrough_step.dart';

void main() {
  testWidgets('card does not overflow when height-capped on a short/wide screen',
      (tester) async {
    // Mimic the coach content slot: full-width SizedBox, only a top anchor,
    // so height is unbounded — exactly how tutorial_coach_mark lays it out.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: 727.6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: WalkthroughCard(
                      step: WalkStep.budget,
                      onSkip: () {},
                      onNext: () {},
                      maxHeight: 242.9,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
