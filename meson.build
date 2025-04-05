project('GtkWidgetDemo', ['vala', 'c'])

libraries= [
  dependency('gtk4', version: '>= 4.12.0', static: false),
  dependency('libadwaita-1', version: '>= 1.5', static: false),
]

gnome=import('gnome')
resources = gnome.compile_resources('resources','widget.gresource.xml')

# Include the translations module
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language: 'c')

# 'odbc.vapi',

sourcefiles = [
    'boxed_toolbar.vala',
    'datetime_picker.vala',
    'widget.vala',
    'application.vala'
]

executable(meson.project_name(), sourcefiles, resources, dependencies: libraries, export_dynamic: true, install: true)
