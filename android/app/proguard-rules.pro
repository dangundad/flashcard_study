# Flutter/Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Core
-dontwarn com.google.android.play.core.**

# Google Mobile Ads and UMP
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-keep class com.google.android.ump.** { *; }
-dontwarn com.google.android.ump.**

# AdMob mediation adapters
-keep class com.applovin.** { *; }
-dontwarn com.applovin.**
-keep class com.bytedance.** { *; }
-dontwarn com.bytedance.**
-keep class com.unity3d.** { *; }
-dontwarn com.unity3d.**

# In-App Purchase
-keep class com.android.vending.billing.** { *; }

# Facebook Infer annotations
-dontwarn com.facebook.infer.annotation.*

# javax.xml (used by some dependencies)
-dontwarn javax.xml.stream.**
