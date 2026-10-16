import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../components/add_button.dart';
import '../components/cart_component.dart';
import '../components/customer_component.dart';
import '../components/hud.dart';

class ArabiaGame extends FlameGame {
  int customersServed = 0;
  int money = 0;
  final List<CustomerComponent> _activeCustomers = [];

  bool _worldBuilt = false;

  @override
  Color backgroundColor() => const Color(0xFF2A1F14);

  @override
  Future<void> onLoad() async {
    debugPrint('>>> ARABIA onLoad called');
    await Future.delayed(const Duration(milliseconds: 200));
    await _buildWorld();
  }

  Future<void> _buildWorld() async {
    if (_worldBuilt) return;

    debugPrint('>>> BUILDING WORLD, size: $size');

    // لو الحجم لسه صفر، نستنى
    if (size.x < 10 || size.y < 10) {
      debugPrint('>>> SIZE ZERO, retrying...');
      await Future.delayed(const Duration(milliseconds: 300));
      return _buildWorld();
    }

    _worldBuilt = true;

    try {
      // 1. خلفية الزقاق
      debugPrint('>>> Loading street_bg.png...');
      final bgImage = await Flame.images.load(
        'assets/images/arabia/street_bg.png',
      );
      add(SpriteComponent(
        sprite: Sprite(bgImage),
        size: size,
        priority: -100,
      ));
      debugPrint('>>> BG loaded ✅');

      // 2. العربية
      debugPrint('>>> Adding cart...');
      add(CartComponent(screenSize: size));
      debugPrint('>>> Cart added ✅');

      // 3. HUD
      debugPrint('>>> Adding HUD...');
      add(HudComponent(game: this));
      debugPrint('>>> HUD added ✅');

      // 4. زرار "زبون جديد"
      debugPrint('>>> Adding button...');
      add(AddCustomerButton(game: this, screenSize: size));
      debugPrint('>>> Button added ✅');

      debugPrint('>>> ✅✅✅ WORLD BUILD DONE ✅✅✅');
    } catch (e, st) {
      debugPrint('>>> ❌ ERROR: $e');
      debugPrint('>>> STACK: $st');

      // نضيف ErrorComponent عشان الخطأ يبان على الشاشة
      add(ErrorComponent(message: e.toString()));

      _worldBuilt = false;
    }
  }

  void addNewCustomer() {
    if (_activeCustomers.length >= 4) return;
    final variant = (_activeCustomers.length % 4) + 1;
    final c = CustomerComponent(
      game: this,
      variant: variant,
      slotIndex: _activeCustomers.length,
      screenSize: size,
    );
    _activeCustomers.add(c);
    add(c);
  }

  void removeCustomer(CustomerComponent c) {
    _activeCustomers.remove(c);
  }

  void serveCustomer(CustomerComponent c) {
    customersServed++;
    money += c.order.price;
    c.removeFromParent();
    _activeCustomers.remove(c);
  }
}

// ============================================================
// ERROR COMPONENT — يبان على الشاشة لو حصل خطأ
// ============================================================
class ErrorComponent extends PositionComponent {
  final String message;

  ErrorComponent({required this.message})
      : super(
          position: Vector2(20, 100),
          size: Vector2(700, 250),
          priority: 9999,
        );

  @override
  void render(Canvas canvas) {
    // خلفية حمرا
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.red.withOpacity(0.9),
    );

    // حدود
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // النص
    final tp = TextPainter(
      text: TextSpan(
        text: message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x - 20);

    tp.paint(canvas, const Offset(10, 10));
  }
}