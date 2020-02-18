import 'package:flame_grab_bag/base_composed_component.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/gestures.dart';

class TouchInputHandler extends BaseComposedComponent {
  final TouchInputEventHandler eventHandler;

  TouchInputHandler(this.eventHandler) {
    GestureBinding.instance.pointerRouter.addGlobalRoute(handlePointerEvent);
    add(eventHandler);
  }

  // Only pay attention to the current pointer, ignore multi-touch
  int _currentPointer;

  void handlePointerEvent(PointerEvent evt) {
    if (_currentPointer != null && _currentPointer != evt.pointer) {
      return;
    }
    if (_currentPointer == null && !(evt is PointerDownEvent)) {
      // only start tracking a new pointer on pointer down
      return;
    }

    _currentPointer = evt.pointer;

    eventHandler.handleNewEvent(evt);
    if (evt is PointerUpEvent) {
      _currentPointer = null;
    }
  }

  @override
  bool isHud() => true;
}

mixin TouchInputEventHandler on Component {
  void handleNewEvent(PointerEvent evt);
}
