/*
* Copyright(C) Taozuhong(https://github.com/taozuhong)
* Important:
*   These functions are a part of the Kangaroo tool suite;
*   Copyright(C) 2019-present Taozuhong. All rights reserved.
*
* Author:    taozuhong
* Created:   5.16.2019
*/
using Gtk;

public enum DateTimePickerMode {
    TIME,
    DATE,
    DATETIME
}

[GtkTemplate(ui = "/taozuhong/widgets/datetime_picker.ui")]
public class DateTimePicker : Gtk.Widget {
    [GtkChild]
    private unowned Gtk.Box box_child;
    [GtkChild]
    private unowned Gtk.Label title_label;
    [GtkChild]
    private unowned Gtk.Calendar calendar;
    [GtkChild]
    private unowned Gtk.SpinButton spin_hour;
    [GtkChild]
    private unowned Gtk.SpinButton spin_minute;
    [GtkChild]
    private unowned Gtk.SpinButton spin_second;
    [GtkChild]
    private unowned Gtk.Box box_time;
    [GtkChild]
    private unowned Gtk.Button button_today;
    [GtkChild]
    private unowned Gtk.Button button_apply;

    private Gtk.Widget m_user_widget;
    private DateTimePickerMode m_picker_mode;

    public signal void changed();
    public signal void completed();

    public DateTimePickerMode mode
    {
        get { return m_picker_mode; }
        construct set { m_picker_mode = value; }
    }

    public string title {
        get { return this.title_label.label; }
        set { this.title_label.label = value; }
    }

    public DateTime datetime {
        owned get {
            var now = new DateTime.now_local();
            
            bool is_time_mode = DateTimePickerMode.TIME == m_picker_mode;
            int year = is_time_mode ? now.get_year() : this.calendar.year;
            int month = is_time_mode ? now.get_month() : this.calendar.month + 1;
            int day = is_time_mode ? now.get_day_of_month() : this.calendar.day;

            bool is_date_mode = DateTimePickerMode.DATE == m_picker_mode;
            int hour = is_date_mode ?  now.get_hour() : this.spin_hour.get_value_as_int();
            int minute = is_date_mode ?  now.get_minute() : this.spin_minute.get_value_as_int();
            int second = is_date_mode ?  now.get_second() : this.spin_second.get_value_as_int();
            
            return new DateTime.local(year, month, day, hour, minute, second);
        }
        set {
            if (DateTimePickerMode.TIME != m_picker_mode) {
                this.calendar.year = value.get_year();
                this.calendar.month = value.get_month() - 1;
                this.calendar.day = value.get_day_of_month();
            }

            if (DateTimePickerMode.DATE != m_picker_mode) {
                this.spin_hour.value = value.get_hour();
                this.spin_minute.value = value.get_minute();
                this.spin_second.value = value.get_second();
            }
        }
    }

    public Gtk.Widget? child {
        get { return m_user_widget; }
        set { m_user_widget = value; }
    }
    
    static construct {
        set_layout_manager_type(typeof(Gtk.BinLayout));
        set_css_name("datetimepicker");
    }

    construct {
        layout_manager = new Gtk.BinLayout();

        this.datetime = new DateTime.now_local();
        if (DateTimePickerMode.TIME == m_picker_mode) {
            this.calendar.visible = false;
        } else if (DateTimePickerMode.DATE == m_picker_mode) {
            this.box_time.visible = false;
        }
    }

    public DateTimePicker()
    {
        m_picker_mode = DateTimePickerMode.DATETIME;
    }

    public DateTimePicker.with_mode(DateTimePickerMode mode)
    {
        m_picker_mode = mode;
    }

    public override void dispose () {
        m_user_widget?.unparent();
        m_user_widget = null;
    
        base.dispose ();
    }

    public void add_child (Gtk.Builder builder, Object child, string? type) {
        if (child is Gtk.Widget) {
            m_user_widget = (Gtk.Widget) child;
            m_user_widget?.set_parent (this);
            return;
        }

        base.add_child (builder, child, type);
    }

    [GtkCallback]
    private void datetime_value_changed()
    {
        this.changed();
    }

    [GtkCallback]
    protected void button_today_clicked_handler(Object entry)
    {
        DateTime value = new DateTime.now_local();
        this.calendar.year = value.get_year();
        this.calendar.month = value.get_month() - 1;
        this.calendar.day = value.get_day_of_month();

        this.spin_hour.value = value.get_hour();
        this.spin_minute.value = value.get_minute();
        this.spin_second.value = value.get_second();
    }

    [GtkCallback]
    private void button_apply_clicked_handler()
    {
        this.completed();
    }
}
