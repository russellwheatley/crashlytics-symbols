## The Problem

Multi-environment (e.g development, production, etc) setup causes de-obfuscation of stack traces to fail on the Firebase console. It works fine when using default Firebase app configuration.

## To Reproduce

1. Clone this repository.
2. Run `flutter pub get` in root of project.
3. Run `cd ios` && `xed .` to open Xcode and ensure code signing is setup appropriately for your Apple account.
4. Install FlutterFire CLI (If you have it installed already , drop the `--overwrite` argument).
```bash
dart pub global activate flutterfire_cli 0.3.0-dev.19 --overwrite
```
5. Run cd `..` to get back to root of project.
6. Run configuration command to configure Firebase iOS app (be sure to use your own Firebase project):
```bash
flutterfire configure --yes --project=[FIREBASE PROJECT NAME] --platforms=ios --ios-build-config=Debug-development --ios-bundle-id=com.example.verygoodcore.crashlytics-symbols.dev --ios-out=ios/development-environment
```

## Check it works as intended without obfuscation

1. Run the app:
```bash
flutter run --debug --flavor=development --target=lib/main_production.dart
```
2. Press the button `Test Crashlytics reproduction` a couple of times.
3. Head over to the Firebase console and open the relevant app in the crashlytics part and see the crash reports and stack traces.


## Try with obfuscated build

1. Configure app for the build type "release" and flavor "production" (be sure to use your own Firebase project):
```bash
flutterfire configure --yes --project=[FIREBASE PROJECT NAME] --platforms=ios --ios-build-config=Release-production --ios-bundle-id=com.example.verygoodcore.crashlytics-symbols --ios-out=ios/release-environment
```
2. Build app and obfuscate (be sure to update `--split-debug-info` argument):
```bash
flutter build ios --flavor=production --release --obfuscate --split-debug-info=[ABSOLUTE PATH TO A DIRECTORY IN THE PROJECT] --target=lib/main_production.dart --verbose | tee release.logs
```
> The above command will also create a "release.logs" with all the Xcode build logs for viewing. You can see the logs contain output which indicates uploading the symbols was a success.

3. Connect your iPhone and install the just created built app on your device:
```bash
flutter install --flavor=production --release
```

This will install the app on your phone. Open it and press the button `Test Crashlytics reproduction` to send crash reports (should occur immediately as they are set to "fatal").
Open the Firebase console and see that the dSYMs have been uploaded successfully (You can check the debug symbol ID in the console against the ID that was output in the "release.logs").

**The stack traces are not deobfuscated. This is the issue**

## Further Information

1. You can check the stack trace is successfully deobfuscated. Grab the `TXT` version of an obfuscated stack trace from the Firebase console for the `com.example.verygoodcore.crashlytics-symbols` app and create a new file in the project, paste into a file called `stacktrace.txt`. Now run this command (be sure to update the path specified earlier for "--split-debug-info" argument):
```bash
flutter symbolize -i stacktrace.txt  -d [PATH TO "--split-debug-info" ARG SPECIFIED EARLIER]/app.ios-arm64.symbol]
```

You will see it successfully de-obfuscate the stack trace.


2. If you want to see what FlutterFire is running under the hood and the arguments it is passing to the environment variables. You can check out the script in "script/upload.dart" in this project. Here is how you can populate the arguments in that script:

- [Clone the FlutterFire CLI repository](https://github.com/invertase/flutterfire_cli) and [checkout this PR](https://github.com/invertase/flutterfire_cli/pull/260). This PR prints out the arguments passed to the script that uploads the debug symbols.
- From the root of the FlutterFire CLI, run `dart pub global activate --source="path" . --executable="flutterfire" --overwrite` which will now point to the local version of FlutterFire CLI.
- From within the project, run the same build command from earlier (be sure to update `--split-debug-info` argument):
```bash
flutter build ios --flavor=production --release --obfuscate --split-debug-info=[ABSOLUTE PATH TO A DIRECTORY IN THE PROJECT] --target=lib/main_production.dart --verbose | tee release.logs
```
- Now check out "release.logs" which will print out all the arguments passed to the script which you can copy/paste into the variables in `script/upload.dart`. 
- You can now run `dart script/upload.dart` to replicate what FlutterFire CLI is doing under the hood. You can also check the path variables are correct by rooting to them from your terminal. They all appear to be correct.
