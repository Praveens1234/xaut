# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# App classes
-keep class com.xaut.app.** { *; }

# Hive
-keep class * extends com.google.flatbuffers.Table { *; }
-keep class * implements io.objectbox.annotation.Entity { *; }

# WorkManager
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

# Keep widget classes
-keep public class * extends android.appwidget.AppWidgetProvider { *; }

# Keep service classes
-keep public class * extends android.app.Service { *; }
-keep public class * extends android.content.BroadcastReceiver { *; }

# Keep parcelables
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }
