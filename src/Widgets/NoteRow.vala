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

        // Layout
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2) {
            margin_start = 6,
            margin_end = 6
        };

        box.append (title_label);
        box.append (content_label);

        child = box;

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
