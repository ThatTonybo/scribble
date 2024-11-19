project('com.thattonybo.scribble',
    'vala', 'c',
    meson_version: '>= 0.57.0',
    version: '0.1.0'
)

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language: 'c')

gresource = gnome.compile_resources(
    'gresource',
    'data' / 'gresource.xml',
    source_dir: 'data'
)

executable(
    meson.project_name(),
    gresource,
    'src' / 'Application.vala',
    'src' / 'MainWindow.vala',
    'src' / 'Handler.vala',
    dependencies: [
        dependency('granite-7'),
        dependency('gtk4'),
        dependency('sqlite3')
    ],
    install: true
)

subdir('data')
subdir('po')

gnome.post_install(glib_compile_schemas: true)
