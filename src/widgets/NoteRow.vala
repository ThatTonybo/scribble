/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 ThatTonybo <thattonybo@gmail.com>
 */

public class Scribble.Widgets.NoteRow : Gtk.ListBoxRow {
    public string title { get; construct; }


    public NoteRow (string title) {
        Object (title: title);
    }

    construct {
        var title_label = new Gtk.Label (title) {
            halign = START,
            hexpand = true,
            ellipsize = Pango.EllipsizeMode.MIDDLE,
            margin_end = 9
        };
        
        title_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);
        
        var content_label = new Gtk.Label ("No additional content") {
            halign = START,
            hexpand = true,
            vexpand = true,
            ellipsize = Pango.EllipsizeMode.MIDDLE,
            max_width_chars = 16,
            margin_end = 9
        };

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2) {
            margin_start = 6,
            margin_end = 6
        };
        
        box.append (title_label);
        box.append (content_label);

        child = box;
    }
}
