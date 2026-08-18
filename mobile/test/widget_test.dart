import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:loteapp_movil/main.dart';

void main() {
  testWidgets('muestra el formulario de inicio de sesion', (WidgetTester tester) async {
    await tester.pumpWidget(const LoteApp());

    expect(find.text('LOTEAPP POS'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Usuario'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
