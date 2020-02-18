import 'phyiscal_component.dart';

abstract class Character extends PhysicalComponent {
  int health;

  Character({this.health = 10});
}
