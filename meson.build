project(
  'redux',
  ['vala', 'c'],
  version: '0.1.0',
  meson_version: '>= 0.62.0',
  default_options: ['warning_level=2'],
)

gnome = import('gnome')
i18n = import('i18n')

config_data = configuration_data()
config_data.set_quoted('CONFIG_APP_ID', 'io.github.dprietob.redux')
config_data.set_quoted('CONFIG_GETTEXT_PACKAGE', meson.project_name())
config_data.set_quoted('CONFIG_LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('CONFIG_VERSION', meson.project_version())
configure_file(output: 'config.h', configuration: config_data)

add_project_arguments(
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  '-I' + meson.current_build_dir(),
  language: 'c',
)

subdir('data')
subdir('po')

# Business code shared by the application and the test suite.
redux_module_sources = files(
  'src/modules/Metadata/models/MetadataMode.vala',
  'src/modules/Metadata/models/MetadataCategory.vala',
  'src/modules/Metadata/models/MetadataTag.vala',
  'src/modules/Metadata/models/MetadataSelection.vala',
  'src/modules/Metadata/services/MetadataReaderService.vala',
  'src/modules/Metadata/services/MetadataWriterService.vala',
  'src/modules/Metadata/actions/LoadImageMetadataAction.vala',
  'src/modules/Metadata/actions/SetMetadataCategoryKeptAction.vala',
  'src/modules/Metadata/controllers/MetadataController.vala',
  'src/modules/Images/models/SourceImage.vala',
  'src/modules/Images/services/ImageFileService.vala',
  'src/modules/Images/validators/ImageDirectoryValidator.vala',
  'src/modules/Images/actions/ListImagesInDirectoryAction.vala',
  'src/modules/Images/actions/LoadImageFilesAction.vala',
  'src/modules/Images/controllers/ImageListController.vala',
  'src/modules/Conversion/models/OutputFormat.vala',
  'src/modules/Conversion/models/ResizeMode.vala',
  'src/modules/Conversion/models/ConversionSettings.vala',
  'src/modules/Conversion/models/ConversionResult.vala',
  'src/modules/Conversion/models/ConversionReport.vala',
  'src/modules/Conversion/services/SizeReductionService.vala',
  'src/modules/Conversion/services/OutputPathService.vala',
  'src/modules/Conversion/services/ImageResizeService.vala',
  'src/modules/Conversion/services/ImageEncoderService.vala',
  'src/modules/Conversion/validators/ConversionValidator.vala',
  'src/modules/Conversion/actions/ConvertImageAction.vala',
  'src/modules/Conversion/actions/BuildConversionReportAction.vala',
  'src/modules/Conversion/controllers/ConversionController.vala',
)

redux_ui_sources = files(
  'src/Main.vala',
  'src/Window.vala',
  'src/modules/Images/ui/ImageRow.vala',
  'src/modules/Images/ui/ImageListPanel.vala',
  'src/modules/Conversion/ui/ReportFormatter.vala',
  'src/modules/Conversion/ui/ConversionSettingsPanel.vala',
  'src/modules/Conversion/ui/ConversionProgressDialog.vala',
  'src/modules/Conversion/ui/ConversionResultRow.vala',
  'src/modules/Conversion/ui/ConversionReportDialog.vala',
  'src/modules/Metadata/ui/MetadataTagRow.vala',
  'src/modules/Metadata/ui/MetadataCategoryRow.vala',
  'src/modules/Metadata/ui/MetadataDialog.vala',
)

redux_vapis = files('src/Config.vapi')

# src/libwebp.vapi binds the libwebp encoder, found by valac as --pkg libwebp.
redux_vala_args = [
  '--target-glib=2.76',
  '--vapidir=' + meson.current_source_dir() / 'src',
]

redux_dependencies = [
  dependency('gtk4', version: '>= 4.12'),
  dependency('libadwaita-1', version: '>= 1.5'),
  dependency('gdk-pixbuf-2.0', version: '>= 2.42'),
  dependency('libwebp', version: '>= 1.0'),
  dependency('gexiv2-0.16'),
  meson.get_compiler('c').find_library('m'),
]

redux_resources = gnome.compile_resources(
  'redux-resources',
  'data/resources.gresource.xml',
  source_dir: '.',
)

executable(
  'redux',
  redux_module_sources + redux_ui_sources + redux_resources,
  redux_vapis,
  dependencies: redux_dependencies,
  vala_args: redux_vala_args,
  install: true,
)

subdir('tests')
