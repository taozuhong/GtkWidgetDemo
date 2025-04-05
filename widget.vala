using Gtk;

[GtkTemplate (ui = "/taozuhong/widgets/widget.ui")]
public class GtkWidgetWindow : Gtk.ApplicationWindow {
    public GtkWidgetWindow(Gtk.Application app) {
        Object (application: app);

        this.add_css_class("devel");
    }
}
