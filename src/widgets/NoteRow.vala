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
        var title_label = new Gtk.Label (note.title) {
            halign = START,
            hexpand = true,
            ellipsize = Pango.EllipsizeMode.MIDDLE,
            margin_end = 9
        };

        title_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var content = note.content_md;
        if (content == "") {
            content = "No additional content";
        }

        var content_label = new Gtk.Label (content) {
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
