/*
* Copyright(C) Taozuhong(https://github.com/taozuhong)
* Important:
*   These functions are a part of the Kangaroo tool suite;
*   Copyright(C) 2019-present Taozuhong. All rights reserved.
*
* Author:    taozuhong
* Created:   5.10.2021
*/
using Gtk;
using Adw;

public enum ToolbarStyle {
    TEXT,
    ICON,
    BOTH
}

public class Toolbar : Gtk.Widget, Gtk.Buildable, Gtk.Orientable {
    private IconSize            m_icon_size;
    private ToolbarStyle        m_element_style;
    private SimpleActionGroup   m_action_group;
    private Gtk.PopoverMenu     m_context_menu;

    const GLib.ActionEntry[] action_entries = {
        { "large-icon", toolbar_large_icon_handler, null, "true", null },
        { "show-label", toolbar_show_label_handler, null, "true", null },
        { "show-icon", toolbar_show_icon_handler, null, "true", null },
    };    

    static construct {
        set_layout_manager_type(typeof(Gtk.BoxLayout));
        set_css_name("box");
    }

    construct {
        m_action_group = new GLib.SimpleActionGroup ();
        m_action_group.add_action_entries (action_entries, this);
        this.insert_action_group ("Toolbar", m_action_group);

        var menu_model = new GLib.Menu ();
        menu_model.append(_("_Large icons"), "Toolbar.large-icon");
        menu_model.append(_("_Show label"), "Toolbar.show-label");
        menu_model.append(_("_Show icon"), "Toolbar.show-icon");
        m_context_menu = new Gtk.PopoverMenu.from_model(menu_model);
        m_context_menu.has_arrow = false;
        m_context_menu.set_parent(this);

        var button_press_event = new Gtk.GestureClick();
        button_press_event.button = Gdk.BUTTON_SECONDARY;
        button_press_event.pressed.connect(handle_context_menu);
        this.add_controller(button_press_event);
    }

    public IconSize size {
        get { return m_icon_size; }
        set {
            m_icon_size = value;
            this.set_icon_size(value);
        } 
    }

    public ToolbarStyle style {
        get { return m_element_style; }
        set {
            m_element_style = value;
            this.set_toolbar_style(value);
        } 
    }

    public Orientation orientation {
        get { return (this.layout_manager as Gtk.Orientable).orientation; }
        set { (this.layout_manager as Gtk.Orientable).orientation = value; }
    }

    public void append(Gtk.Widget widget)
    {
        widget.set_parent(this);

        this.update_button_size(widget, m_icon_size);
        this.update_button_style(widget, m_element_style);
    }

    public void remove(Gtk.Widget widget)
    {
        widget.unparent();
    }

    public override void dispose () {
        Gtk.Widget widget = this.get_first_child();
        while(null != widget) {
            widget.unparent();
            widget = this.get_first_child();
        }
    
        base.dispose ();
    }

    public void add_child (Gtk.Builder builder, Object child, string? type) {
        base.add_child (builder, child, type);

        this.update_button_size(child as Gtk.Widget, m_icon_size);
        this.update_button_style(child as Gtk.Widget, m_element_style);
    }

    private void handle_context_menu(GestureClick gesture, int n_press, double x, double y)
    {
        var action = m_action_group.lookup_action("large-icon") as SimpleAction;
        action?.set_state(new Variant.boolean(IconSize.LARGE == this.size));

        action = m_action_group.lookup_action("show-label") as SimpleAction;
        action?.set_state(new Variant.boolean(ToolbarStyle.ICON != this.style));

        action = m_action_group.lookup_action("show-icon") as SimpleAction;
        action?.set_state(new Variant.boolean(ToolbarStyle.TEXT != this.style));

        Gdk.Rectangle rect = { (int)x, (int)y, 0, 0, };
        m_context_menu.set_pointing_to(rect);
        m_context_menu.popup();
    }

    private void toolbar_large_icon_handler(SimpleAction action, Variant? parameter)
    {
        bool show_large = ! action.state.get_boolean();
        this.size = show_large ? IconSize.LARGE : IconSize.NORMAL;
        action.set_state(new Variant.boolean(show_large));
    }

    private void toolbar_show_label_handler(SimpleAction action, Variant? parameter)
    {
        bool show_label = ! action.state.get_boolean();
        this.style =  show_label ? ToolbarStyle.BOTH : ToolbarStyle.ICON;
        action.set_state(new Variant.boolean(show_label));
    }

    private void toolbar_show_icon_handler(SimpleAction action, Variant? parameter)
    {
        bool show_icon = ! action.state.get_boolean();
        this.style = show_icon ? ToolbarStyle.BOTH : ToolbarStyle.TEXT;
        action.set_state(new Variant.boolean(show_icon));
    }

    private Gtk.IconSize get_icon_size()
    {
        Widget? widget = this.get_first_child();
        for (; null != widget; widget = widget.get_next_sibling()) {
            if ((widget is Gtk.Button) || (widget is Gtk.MenuButton) || (widget is Adw.SplitButton)) {
                break;
            }
        }

        Gtk.Box button_box;
        Gtk.IconSize retval = Gtk.IconSize.NORMAL;
        if ((widget is Gtk.Button) && ((widget as Gtk.Button).child is Gtk.Box)) {
            button_box = ((widget as Gtk.Button).child as Gtk.Box);
            if (button_box.get_first_child() is Gtk.Image) {
                retval = (button_box.get_first_child() as Gtk.Image).icon_size;
            }
        } else if ((widget is Gtk.MenuButton) && ((widget as Gtk.MenuButton).child is Gtk.Box)) {
            button_box = ((widget as Gtk.MenuButton).child as Gtk.Box);
            if (button_box.get_first_child() is Gtk.Image) {
                retval = (button_box.get_first_child() as Gtk.Image).icon_size;
            }
        } else if ((widget is Adw.SplitButton) && ((widget as Adw.SplitButton).child is Gtk.Box)) {
            button_box = ((widget as Adw.SplitButton).child as Gtk.Box);
            if (button_box.get_first_child() is Gtk.Image) {
                retval = (button_box.get_first_child() as Gtk.Image).icon_size;
            }
        }

        return retval;
    }

    private void set_icon_size(Gtk.IconSize icon_size)
    {
        Gtk.Box button_box;
        Widget? widget = this.get_first_child();
        for (; null != widget; widget = widget.get_next_sibling())
        {
            this.update_button_size(widget, icon_size);
        }
    }

    private ToolbarStyle get_toolbar_style()
    {
        Widget? widget = this.get_first_child();
        for (; null != widget; widget = widget.get_next_sibling()) {
            if ((widget is Gtk.Button) || (widget is Gtk.MenuButton) || (widget is Adw.SplitButton)) {
                break;
            }
        }
        
        Gtk.Box button_box;
        ToolbarStyle retval = ToolbarStyle.BOTH;
        if ((widget is Gtk.Button) && ((widget as Gtk.Button).child is Gtk.Box)) {
            button_box = ((widget as Gtk.Button).child as Gtk.Box);
            if (button_box.get_first_child().visible && button_box.get_last_child().visible) {
                retval = ToolbarStyle.BOTH;
            } else {
                retval = button_box.get_first_child().visible ? ToolbarStyle.ICON : ToolbarStyle.TEXT;
            }
        } else if ((widget is Gtk.MenuButton) && ((widget as Gtk.MenuButton).child is Gtk.Box)) {
            button_box = ((widget as Gtk.MenuButton).child as Gtk.Box);
            if (button_box.get_first_child().visible && button_box.get_last_child().visible) {
                retval = ToolbarStyle.BOTH;
            } else {
                retval = button_box.get_first_child().visible ? ToolbarStyle.ICON : ToolbarStyle.TEXT;
            }
        } else if ((widget is Adw.SplitButton) && ((widget as Adw.SplitButton).child is Gtk.Box)) {
            button_box = ((widget as Adw.SplitButton).child as Gtk.Box);
            if (button_box.get_first_child().visible && button_box.get_last_child().visible) {
                retval = ToolbarStyle.BOTH;
            } else {
                retval = button_box.get_first_child().visible ? ToolbarStyle.ICON : ToolbarStyle.TEXT;
            }
        }

        return retval;
    }

    private void set_toolbar_style(ToolbarStyle style)
    {
        Gtk.Box button_box;
        Widget? widget = this.get_first_child();
        for (; null != widget; widget = widget.get_next_sibling())
        {
            this.update_button_style(widget, style);
        }
    }

    private void update_button_style(Gtk.Widget widget, ToolbarStyle style)
    {
        Gtk.Box button_box;
        if ((widget is Gtk.Button) && ((widget as Gtk.Button).child is Gtk.Box)) {
            button_box = ((widget as Gtk.Button).child as Gtk.Box);
            button_box.get_first_child().visible = (ToolbarStyle.ICON == style) || (ToolbarStyle.BOTH == style);
            button_box.get_last_child().visible = (ToolbarStyle.TEXT == style) || (ToolbarStyle.BOTH == style);
        } else if ((widget is Gtk.MenuButton) && ((widget as Gtk.MenuButton).child is Gtk.Box)) {
            button_box = ((widget as Gtk.MenuButton).child as Gtk.Box);
            button_box.get_first_child().visible = (ToolbarStyle.ICON == style) || (ToolbarStyle.BOTH == style);
            button_box.get_last_child().visible = (ToolbarStyle.TEXT == style) || (ToolbarStyle.BOTH == style);
        } else if ((widget is Adw.SplitButton) && ((widget as Adw.SplitButton).child is Gtk.Box)) {
            button_box = ((widget as Adw.SplitButton).child as Gtk.Box);
            button_box.get_first_child().visible = (ToolbarStyle.ICON == style) || (ToolbarStyle.BOTH == style);
            button_box.get_last_child().visible = (ToolbarStyle.TEXT == style) || (ToolbarStyle.BOTH == style);
        }
    }

    private void update_button_size(Gtk.Widget widget, Gtk.IconSize size)
    {
        Gtk.Box button_box;
        if ((widget is Gtk.Button) && ((widget as Gtk.Button).child is Gtk.Box)) {
            button_box = ((widget as Gtk.Button).child as Gtk.Box);
            if (button_box.get_first_child() is Gtk.Image) {
                (button_box.get_first_child() as Gtk.Image).icon_size = size;
            }
        } else if ((widget is Gtk.MenuButton) && ((widget as Gtk.MenuButton).child is Gtk.Box)) {
            button_box = ((widget as Gtk.MenuButton).child as Gtk.Box);
            if (button_box.get_first_child() is Gtk.Image) {
                (button_box.get_first_child() as Gtk.Image).icon_size = size;
            }
        } else if ((widget is Adw.SplitButton) && ((widget as Adw.SplitButton).child is Gtk.Box)) {
            button_box = ((widget as Adw.SplitButton).child as Gtk.Box);
            if (button_box.get_first_child() is Gtk.Image) {
                (button_box.get_first_child() as Gtk.Image).icon_size = size;
            }
        }
    }
}
