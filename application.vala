public class GtkWidgetDemo : Gtk.Application {
    private GtkWidgetWindow window;
    const string GETTEXT_PACKAGE = "GtkWidgetDemo";
    
    public GtkWidgetDemo () {
        Object (application_id: "org.github.taozuhong.widget", flags: ApplicationFlags.HANDLES_OPEN);
    }

    protected override void activate () {
        Intl.bindtextdomain (GETTEXT_PACKAGE, "");
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

        this.window = new GtkWidgetWindow (this);
        this.window.present();
    }
}

int main (string[] args) {
    var app = new GtkWidgetDemo ();
    return app.run (args);
}
