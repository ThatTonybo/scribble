/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 ThatTonybo <thattonybo@gmail.com>
 */

public class Scribble.Widgets.NoteRow : Gtk.ListBoxRow {
    public Scribble.Objects.Note note { get; construct; }

    public NoteRow (Scribble.Objects.Note note) {
        Object (note: note);
    }

    construct {
        // Title
        var title_label = new Gtk.Label (note.title) {
            halign = START,
            hexpand = true,
            ellipsize = Pango.EllipsizeMode.MIDDLE,
            margin_end = 9
        };

        title_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        // Content
        var content_label = new Gtk.Label (note.content_md) {
            halign = START,
            hexpand = true,
            vexpand = true,
            ellipsize = Pango.EllipsizeMode.MIDDLE,
            max_width_chars = 16,
            margin_end = 9
        };

        // Context Menu
        //new Granite.AccelLabel.from_action_name (_("Delete Note…"), "app.delete_selected_note");
        //add_css_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

        var menu = new Menu ();
        menu.append (_("Delete Note…"), "app.delete_selected_note");

        var popover_menu = new Gtk.PopoverMenu.from_model (menu) {
            halign = Gtk.Align.START,
            has_arrow = false,
            position = Gtk.PositionType.BOTTOM
        };

        // Activate menu on right-click
        var secondary_click_gesture = new Gtk.GestureClick () {
            button = Gdk.BUTTON_SECONDARY
        };

        secondary_click_gesture.released.connect ((n_press, x, y) => {
            var rect = Gdk.Rectangle () {
                x = (int) x,
                y = (int) y
            };

            popover_menu.pointing_to = rect;
            popover_menu.popup ();
        });

        // Layout
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2) {
            margin_start = 6,
            margin_end = 6
        };

        box.add_controller (secondary_click_gesture);
        box.append (title_label);
        box.append (content_label);

        popover_menu.set_parent (box);

        child = box;

        add_css_class ("note");

        // Bindings
        note.bind_property ("title", title_label, "label", BindingFlags.SYNC_CREATE);
        note.bind_property ("content_md", content_label, "label", BindingFlags.SYNC_CREATE, (binding, srcval, ref targetval) => {
            string content = (string) srcval;

		    if (content == "") {
		        targetval = "No additional content";
		    } else {
		        targetval = content;
		    }

		    return true;
        });
    }
}
