## Mobile

### Android

- Set `$ANDROID_HOME` and `$ANDROID_NDK_HOME` or add a `ndk-bundle` symlink in
  `$ANDROID_HOME` pointing to the NDK path

```
ebitenmobile bind -target android -androidapi 21 -javapkg com.example.game -o ./mobile/android/mobile/mobile.aar ./mobile
```

### iOS

```
ebitenmobile bind -target ios -o ./mobile/ios/Mobile.xcframework ./mobile
```
