-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.google.firebase.** { *; }

-dontwarn io.flutter.embedding.**
-dontwarn android.**
-dontwarn com.google.android.material.**
-dontwarn androidx.**

-keep class * extends androidx.fragment.app.Fragment{}

-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

-keep class androidx.lifecycle.DefaultLifecycleObserver
