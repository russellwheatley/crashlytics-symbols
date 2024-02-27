import 'dart:io';

main() async {
  // UPDATE THESE ARGUMENTS
  const uploadSymbolsScriptPath = '';
  const appIdFilePath = '';
  const envPlatformName = '';
  const envConfiguration = '';
  const envProjectDir = '';
  const envDwarfDsymFolderPath = '';
  const envDwarfDsymFileName = '';
  const envInfoPlistPath = '';
  const envBuildProductsDir = '';

  final uploadScript = await Process.run(
    uploadSymbolsScriptPath,
    [
      '--flutter-project',
      appIdFilePath,
    ],
    environment: {
      'PLATFORM_NAME': envPlatformName,
      'CONFIGURATION': envConfiguration,
      'PROJECT_DIR': envProjectDir,
      'DWARF_DSYM_FOLDER_PATH': envDwarfDsymFolderPath,
      'DWARF_DSYM_FILE_NAME': envDwarfDsymFileName,
      'INFOPLIST_PATH': envInfoPlistPath,
      'BUILT_PRODUCTS_DIR': envBuildProductsDir,
    },
  );

  if (uploadScript.exitCode != 0) {
    throw Exception(uploadScript.stderr);
  }

  if (uploadScript.stdout != null) {
    print(uploadScript.stdout as String);
  }
}
