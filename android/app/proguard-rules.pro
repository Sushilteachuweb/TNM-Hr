-keep class com.google.android.gms.auth.api.credentials.** { *; }
-keep class com.google.android.apps.nbu.paisa.inapp.** { *; }
-keep class com.razorpay.** { *; }
-keepclassmembers class * {
    @proguard.annotation.Keep *;
}
-keep @proguard.annotation.Keep class *
-keepclassmembers class * {
    @proguard.annotation.KeepClassMembers *;
}
-dontwarn com.google.android.gms.auth.api.credentials.**
-dontwarn com.google.android.apps.nbu.paisa.inapp.**
-dontwarn proguard.annotation.**
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

