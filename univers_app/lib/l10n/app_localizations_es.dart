// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get soundSection => 'Sonido';

  @override
  String get backgroundMusic => 'Música de fondo';

  @override
  String get textToSpeech => 'Lectura de voz';

  @override
  String get languageSection => 'Idioma';

  @override
  String get guidedAccessSection => 'Acceso guiado';

  @override
  String get loading => 'Cargando...';

  @override
  String get errorOccurred => '¡Ups! Se produjo un error';

  @override
  String get noImagesAvailable => 'No hay imágenes disponibles';

  @override
  String get untitled => 'Sin título';

  @override
  String get iosLockInstructions =>
      '**Bloquear pantalla para niños (iPhone)**\n\n1. Ajustes → Accesibilidad\n2. Acceso guiado (Aprendizaje)\n3. Activar Acceso guiado\n4. Establecer código\n5. (Recomendado) Funciones rápidas → marcar Acceso guiado\n\nBloquear en el juego:\n• Abrir el juego\n• Pulsar 3 veces rápido el botón lateral\n• Tocar Empezar\n\nSalir: triple pulsación → código → Finalizar';

  @override
  String get androidLockInstructions =>
      '**Bloquear pantalla para niños (Android)**\n\n1. Ajustes → Seguridad y privacidad → Más seguridad → Fijar app\n   (o buscar «Fijar»)\n2. Activar y marcar «Pedir PIN antes de desanclar»\n\nBloquear en el juego:\n• Abrir el juego\n• Botón apps recientes (cuadrado)\n• Tocar icono arriba → Fijar\n\nSalir: mantener Vista general + Encendido → introducir PIN';
}
