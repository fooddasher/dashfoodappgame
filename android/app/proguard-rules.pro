# ============================================================================
# Food Dash - ProGuard Rules
# ============================================================================
# These rules are used by R8 during release builds to optimize and obfuscate
# the app's code while preventing issues with missing classes.
# ============================================================================

# ============================================================================
# FLUTTER SPECIFIC RULES
# ============================================================================

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ============================================================================
# GOOGLE PLAY CORE - DEFERRED COMPONENTS FIX
# ============================================================================
# Flutter's Android build may reference Google Play Core classes for deferred
# components (dynamic feature modules). If our app does not use this feature
# and does not include the Play Core library, R8 will fail during release
# build because it cannot find those classes.
#
# These rules tell R8 to ignore the missing classes, which is safe because
# the deferred components functionality will not be used at runtime.
# ============================================================================

# Play Core deferred components
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Play Core common classes
-dontwarn com.google.android.play.core.common.IntentSenderForResultStarter
-dontwarn com.google.android.play.core.common.LocalTestingException
-dontwarn com.google.android.play.core.listener.StateUpdatedListener
-dontwarn com.google.android.play.core.review.**
-dontwarn com.google.android.play.core.appupdate.**
-dontwarn com.google.android.play.core.install.**
-dontwarn com.google.android.play.core.assetpacks.**

# ============================================================================
# FLAME GAME ENGINE
# ============================================================================

# Keep Flame classes (game engine)
-keep class com.flame.** { *; }
-keep class org.libsdl.** { *; }

# ============================================================================
# AUDIO PLAYERS
# ============================================================================

# Keep audioplayers classes
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# ============================================================================
# SHARED PREFERENCES
# ============================================================================

# Keep shared preferences plugin
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# ============================================================================
# GENERAL ANDROID RULES
# ============================================================================

# Keep annotations
-keepattributes *Annotation*

# Keep exception names
-keepattributes SourceFile,LineNumberTable

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# ============================================================================
# KOTLIN
# ============================================================================

# Keep Kotlin Metadata
-keepattributes RuntimeVisibleAnnotations
-keep class kotlin.Metadata { *; }

# Kotlin coroutines
-dontwarn kotlinx.coroutines.**

# ============================================================================
# OPTIMIZATION FLAGS
# ============================================================================

# Optimization - be aggressive but safe
-optimizationpasses 5
-allowaccessmodification
-repackageclasses ''

# Don't note about duplicate class definitions (common in multi-dex)
-dontnote **
