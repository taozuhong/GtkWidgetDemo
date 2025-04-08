using Gtk;

[GtkTemplate (ui = "/taozuhong/widgets/widget.ui")]
public class GtkWidgetWindow : Gtk.ApplicationWindow {
    [GtkChild]
    private unowned ViewSwitcher tabbar;
    [GtkChild]
    private unowned Adw.ViewStack view_client;

    public GtkWidgetWindow(Gtk.Application app) {
        Object (application: app);

        this.add_css_class("devel");
    }

    [GtkCallback]
    private void page_close_handler(Adw.ViewStackPage page)
    {
        this.view_client.remove(page.child);

        for(int i = 1; i < Random.int_range(1, 5); i++) {
            this.view_client.add(new Gtk.Label("Label %d".printf(1000 + i)));
        }
    }
}
