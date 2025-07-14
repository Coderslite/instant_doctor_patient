# Keep flutter_local_notifications classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Keep permission_handler classes
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Keep flutter_timezone classes
-keep class com.jworks.flutter_timezone.** { *; }
-dontwarn com.jworks.flutter_timezone.**

# Keep AndroidX dependencies used by flutter_local_notifications
-keep class androidx.core.app.** { *; }
-keep class androidx.work.** { *; }
-keep class androidx.annotation.** { *; }
-dontwarn androidx.**

# Keep notification-related Android classes
-keep class android.app.Notification** { *; }
-keep class android.service.notification.** { *; }

# Keep resources for notification sounds
-keep class **.R$raw { *; }

# Keep Zego-related classes
-keep class **.zego.** { *; }
-keep class com.hiennv.flutter_callkit_incoming.** { *; }
-keep class **.**.zego_zpns.** { *; }

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-ignorewarnings

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep AutoSafeParcelables (microG)
-keep public class * extends org.microg.safeparcel.AutoSafeParcelable {
    @org.microg.safeparcel.SafeParcelable.Field *;
    @org.microg.safeparcel.SafeParceled *;
}
-keepattributes InnerClasses
-keepclassmembers interface * extends android.os.IInterface {
    public static class *;
}
-keep public class * extends android.os.Binder { public static *; }

# Additional rules for reflection and tokens
-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * {
    @com.google.firebase.** *;
    @androidx.annotation.** *;
}
-keepnames class * {
    @com.google.firebase.** *;
    @androidx.annotation.** *;
}
-keep class * {
    public protected private *;
}

# Prevent R8 from removing methods used by reflection
-keepclassmembers,allowobfuscation class * {
    public <init>(...);
    public static <methods>;
}