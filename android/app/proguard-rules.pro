# Règles R8 / ProGuard pour la build release.
#
# Le code Dart est compilé en code natif : il n'est pas concerné par R8.
# Ces règles protègent le code Java/Kotlin (moteur Flutter + plugins) qui peut
# être appelé par réflexion et donc supprimé/renommé à tort par R8.

# --- Moteur Flutter ---
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# --- Plugin alarm (déclenchement / service / réception au reboot) ---
-keep class com.gdelataillade.alarm.** { *; }

# --- just_audio / media3 (ExoPlayer) : lecture audio ---
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# --- Divers : garder les classes annotées Keep et les enums (réflexion) ---
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers enum * { *; }
