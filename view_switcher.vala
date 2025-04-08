/*
* Copyright(C) Taozuhong(https://github.com/taozuhong)
* Important:
*   These functions are a part of the Kangaroo tool suite;
*   Copyright(C) 2019-present Taozuhong. All rights reserved.
*
* Author:    taozuhong
* Created:   2025-04-07
*/
using Gee;
using Gtk;

public enum ViewSwitcherPolicy {
    WIDE,
    NARROW,
    ICON
}

[GtkTemplate(ui = "/taozuhong/widgets/view_switcher_button.ui")]
public class ViewSwitcherButton : Gtk.Widget {
    [GtkChild]
    private unowned Gtk.Box content;
    [GtkChild]
    private unowned Gtk.Image image;
    [GtkChild]
    private unowned Gtk.Label label;
    [GtkChild]
    private unowned Gtk.Button button;

    private bool m_active = false;
    private ViewSwitcherPolicy m_policy;
    private Adw.ViewStackPage m_stack_page;

    public signal void close_page(Adw.ViewStackPage page);
    public signal void activate_page(Adw.ViewStackPage page);

    public bool active {
        get { return m_active; }
        set {
            m_active = value;
            this.update_content();
        }
    }

    public ViewSwitcherPolicy policy {
        get { return m_policy; }
        set {
            m_policy = value;
            this.update_layout();
        }
    }

    public Adw.ViewStackPage page {
        get { return m_stack_page; }
        set {
            m_stack_page = value;
            this.update_content();
            if (null != m_stack_page) {
                m_stack_page.notify.connect((page, spec) => {
                    this.update_content();
                });
            }
        }
    }
    
    static construct {
        set_layout_manager_type(typeof(Gtk.BoxLayout));
        set_css_name("button");
    }

    construct {
        (this.layout_manager as Gtk.BoxLayout).spacing = 5;

        this.update_layout();
    }

    public ViewSwitcherButton() {
        m_policy = ViewSwitcherPolicy.WIDE;
    }

    public ViewSwitcherButton.with_policy(ViewSwitcherPolicy _policy) {
        m_policy = _policy;
    }

    public override void dispose ()
    {
        Gtk.Widget widget = this.get_first_child();
        while(null != widget) {
            widget.unparent();
            widget = this.get_first_child();
        }
        m_stack_page = null;
        base.dispose ();
    }

    [GtkCallback]
    private void close_clicked_handler()
    {
        this.close_page(m_stack_page);
        GLib.message("Fire event: close_page");
    }

    [GtkCallback]
    private void mouse_pressed_handler(Gtk.GestureClick gesture, int press, double x, double y)
    {
        if ((Gdk.BUTTON_PRIMARY == gesture.get_current_button()) && (1 == press)) {
            this.activate_page(m_stack_page);
        }
    }

    [GtkCallback]
    private void enter_handler(double x, double y)
    {
        this.button.opacity = 1.0;
    }

    [GtkCallback]
    private void leave_handler()
    {
        if (! m_active) {
            this.button.opacity = 0.0;
        }
    }

    private void update_layout() {
        switch(m_policy) {
        case ViewSwitcherPolicy.WIDE:
            this.content.orientation = Gtk.Orientation.HORIZONTAL;
            this.image.visible = true;
            this.label.visible = true;
            this.button.visible = true;
            break;
        case ViewSwitcherPolicy.NARROW:
            this.content.orientation = Gtk.Orientation.VERTICAL;
            this.image.visible = true;
            this.label.visible = true;
            this.button.visible = true;
            break;
        case ViewSwitcherPolicy.ICON:
            this.content.orientation = Gtk.Orientation.HORIZONTAL;
            this.image.visible = true;
            this.label.visible = false;
            this.button.visible = false;
            break;
        default:
            break;
        }
    }

    private void update_content() {
        GLib.return_if_fail(m_stack_page != null);

        this.image.icon_name = m_stack_page.icon_name;
        this.label.label = m_stack_page.title;
        this.label.use_underline = m_stack_page.use_underline;
        this.visible = m_stack_page.visible && ((null != m_stack_page.title) || (null != m_stack_page.icon_name));

        if (m_stack_page.needs_attention) {
            this.add_css_class("needs-attention");
        } else {
            this.remove_css_class("needs-attention");
        }

        if (m_active) {
            this.button.opacity = 1.0;
            this.add_css_class("toggle");
        } else {
            this.remove_css_class("toggle");
            this.button.opacity = 0.0;
        }
    }
}

public class ViewSwitcher : Gtk.Widget {
    private ViewSwitcherPolicy m_policy;
    private Adw.ViewStack m_view_stack;
    private Gtk.SelectionModel m_pages;
    private ArrayList<ViewSwitcherButton> m_buttons;

    public signal void close_page(Adw.ViewStackPage page);

    public ViewSwitcherPolicy policy {
        get { return m_policy; }
        set {
            m_policy = value;
            foreach(var button in m_buttons) {
                button.policy = value;
            }
        }
    }

    public Adw.ViewStack stack {
        get { return m_view_stack; }
        set {
            if (null != m_view_stack) {
                m_pages.items_changed.disconnect(items_changed_handler);
                m_pages.selection_changed.disconnect(selection_changed_handler);
                this.clear_switcher();
            }

            m_view_stack = value;
            m_pages = m_view_stack.pages;
            if (null != m_view_stack) {
                this.update_switcher();
                m_pages.items_changed.connect(items_changed_handler);
                m_pages.selection_changed.connect(selection_changed_handler);
            }
        }
    }

    static construct {
        set_layout_manager_type(typeof(Gtk.BoxLayout));
        set_css_name("viewswitcher");
    }

    construct {
        m_buttons = new ArrayList<ViewSwitcherButton>();
        this.add_css_class("linked");
    }

    public ViewSwitcher() {
        m_policy = ViewSwitcherPolicy.WIDE;
    }

    public ViewSwitcher.with_policy(ViewSwitcherPolicy _policy) {
        m_policy = _policy;
    }

    public override void dispose () {
        this.clear_switcher();
    
        base.dispose ();
    }

    private void add_button(Adw.ViewStackPage page)
    {
        var button = new ViewSwitcherButton.with_policy(m_policy);
        button.page = page;
        button.set_parent(this);
        button.add_css_class("flat");
        button.close_page.connect((_page_) => {
            this.close_page(_page_);
        });
        button.activate_page.connect((sender, _page_) => {
            m_view_stack.visible_child = _page_.child;
        });
        m_buttons.add(button);
    }

    private void update_switcher() {
        Adw.ViewStackPage page = null;
        for(var i = 0; i < m_pages.get_n_items(); i++) {
            page = m_pages.get_item(i) as Adw.ViewStackPage;
            this.add_button(page);
        }
        this.selection_changed_handler(0, 0);
        this.queue_resize();
    }

    private void clear_switcher() {
        foreach(var button in m_buttons) {
            button.unparent();
        };
        m_buttons.clear();
    }

    private void items_changed_handler()
    {
        this.clear_switcher();
        this.update_switcher();
    }

    private void selection_changed_handler(uint position, uint n_items)
    {
        foreach (var button in m_buttons) {
            button.active = (button.page.child == m_view_stack.visible_child);
        }
    }
}