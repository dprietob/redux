desktop_file = i18n.merge_file(
  input: 'io.github.dprietob.redux.desktop.in',
  output: 'io.github.dprietob.redux.desktop',
  type: 'desktop',
  po_dir: '../po',
  install: true,
  install_dir: get_option('datadir') / 'applications',
)

desktop_file_validate = find_program('desktop-file-validate', required: false)
if desktop_file_validate.found()
  test('validate-desktop', desktop_file_validate,
    args: [desktop_file.full_path()],
    depends: desktop_file,
  )
endif

metainfo_file = i18n.merge_file(
  input: 'io.github.dprietob.redux.metainfo.xml.in',
  output: 'io.github.dprietob.redux.metainfo.xml',
  po_dir: '../po',
  install: true,
  install_dir: get_option('datadir') / 'metainfo',
)

appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
  test('validate-metainfo', appstreamcli,
    args: ['validate', '--no-net', '--explain', metainfo_file.full_path()],
    depends: metainfo_file,
  )
endif

foreach size : ['64', '128', '256', '512']
  install_data(
    'icons/hicolor' / size + 'x' + size / 'apps/io.github.dprietob.redux.png',
    install_dir: get_option('datadir') / 'icons/hicolor' / size + 'x' + size / 'apps',
  )
endforeach

install_data(
  'icons/hicolor/scalable/apps/io.github.dprietob.redux.svg',
  install_dir: get_option('datadir') / 'icons/hicolor/scalable/apps',
)

install_data(
  'io.github.dprietob.redux.gschema.xml',
  install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
)

# Compile the schema into the build tree so the app runs uninstalled, and
# recompile the installed schemas after `ninja install`.
compiled_schemas = gnome.compile_schemas(
  build_by_default: true,
  depend_files: files('io.github.dprietob.redux.gschema.xml'),
)
gnome.post_install(glib_compile_schemas: true)