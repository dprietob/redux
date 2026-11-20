redux_tests = executable(
  'redux-tests',
  redux_module_sources + files(
    'TestMain.vala',
    'TestImages.vala',
    'Conversion/unit/ImageResizeServiceTest.vala',
    'Conversion/unit/OutputPathServiceTest.vala',
    'Conversion/unit/SizeReductionServiceTest.vala',
    'Conversion/unit/BuildConversionReportActionTest.vala',
    'Conversion/unit/ConversionValidatorTest.vala',
    'Conversion/feature/ConvertImageTest.vala',
    'Conversion/feature/ConversionControllerTest.vala',
    'Images/feature/ListImagesInDirectoryTest.vala',
  ),
  redux_vapis,
  dependencies: [
    dependency('gio-2.0'),
    dependency('gdk-pixbuf-2.0', version: '>= 2.42'),
    dependency('libwebp', version: '>= 1.0'),
    meson.get_compiler('c').find_library('m'),
  ],
  vala_args: redux_vala_args,
)

# The controller reads the compiled schema from the build tree and keeps its
# preferences in memory, so the tests never touch the user's settings.
test('redux-tests', redux_tests,
  env: [
    'GSETTINGS_SCHEMA_DIR=' + meson.project_build_root() / 'data',
    'GSETTINGS_BACKEND=memory',
  ],
  depends: compiled_schemas,
  timeout: 120,
)
