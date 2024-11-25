/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 ThatTonybo <thattonybo@gmail.com>
 */

public class Scribble.MainWindow : Gtk.ApplicationWindow {
    public Scribble.Objects.Note selected_note;
    public Gtk.ListBox notes_listbox;
    public bool allow_note_content_save_changes;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            title: _("(note title) - Scribble")
        );
    }

    construct {
        selected_note = new Scribble.Objects.Note ();
        allow_note_content_save_changes = true;

        // Menu
        var header_menu_quit_button = new Gtk.Button () {
            action_name = "app.quit",
            child = new Granite.AccelLabel.from_action_name ("Quit", "app.quit")
        };
        header_menu_quit_button.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var header_menu_popover = new Gtk.Popover () {
            child = header_menu_quit_button
        };
        header_menu_popover.add_css_class (Granite.STYLE_CLASS_MENU);

        var header_menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic",
            primary = true,
            popover = header_menu_popover,
            tooltip_markup = Granite.markup_accel_tooltip ({}, "Menu")
        };
        header_menu_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        // Headers
        var sidebar_header = new Gtk.HeaderBar () {
            show_title_buttons = false,
            title_widget = new Gtk.Label ("")
        };

        sidebar_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        sidebar_header.pack_start (new Gtk.WindowControls (Gtk.PackType.START));

        var main_header = new Gtk.HeaderBar () {
            show_title_buttons = false,
            title_widget = new Gtk.Label ("")
        };

        main_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        main_header.pack_end (new Gtk.WindowControls (Gtk.PackType.END));
        main_header.pack_end (header_menu_button);

        // Sidebar

        // (section title label)
        // TEMPORARY - notes should be sorted by creation date/time, then there should be a section for each
        // notable period eg. today, yesterday, last 30 days, October, November, etc...
        var notes_section_label = new Gtk.Label (_("Notes")) {
            halign = START,
            margin_start = 12
        };

        notes_section_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        // (section list box)
        notes_listbox = new Gtk.ListBox ();
        notes_listbox.bind_model (Scribble.Application.handler.notes_liststore, create_note_row);

        var sidebar_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
        sidebar_box.append (notes_section_label);
        sidebar_box.append (notes_listbox);

        var sidebar_scrollable_area = new Gtk.ScrolledWindow () {
            child = sidebar_box,
            hexpand = true,
            vexpand = true,
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };

        // (new note button/action bar)
        var new_note_button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        new_note_button_box.append (new Gtk.Image.from_icon_name ("list-add-symbolic"));
        new_note_button_box.append (new Gtk.Label (_("New Note")));

        var new_note_button = new Gtk.Button () {
            child = new_note_button_box
        };

        new_note_button.clicked.connect (() => {
            var id = Scribble.Application.handler.create_note (_("Untitled note"), "");

            var temp_note = new Scribble.Objects.Note ();
            temp_note.id = id;

            // Select the newly created note
            uint position = -1;
            Scribble.Application.handler.notes_liststore.find_with_equal_func (temp_note, Scribble.Application.handler.equal_func, out position);

            if (position != -1) {
                int index = (int) position;
                var row = notes_listbox.get_row_at_index (index);

                if (row != null) {
                    notes_listbox.select_row (row);
                    notes_listbox.row_selected (row);
                } else {
                    warning ("Failed to find note with ID \"%s\" in list box: position in list box returned NULL", id);
                }
            } else {
                warning ("Failed to find note with ID \"%s\": position in list store returned as -1", id);
            }
        });

        var actionbar = new Gtk.ActionBar ();
        actionbar.add_css_class (Granite.STYLE_CLASS_FLAT);
        actionbar.pack_start (new_note_button);

        var sidebar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        sidebar.add_css_class (Granite.STYLE_CLASS_SIDEBAR);
        sidebar.append (sidebar_header);
        sidebar.append (sidebar_scrollable_area);
        sidebar.append (actionbar);

        // Main content

        // (note content)
        var note_content = new Gtk.TextView ();
        var note_content_buffer = note_content.get_buffer ();

        note_content.add_css_class (Granite.STYLE_CLASS_BACKGROUND);
        note_content.set_focusable (true);

        // (save note content changes to database)
        note_content_buffer.changed.connect (() => {
            if (allow_note_content_save_changes == true) {
                selected_note.content_md = note_content_buffer.text;
                Scribble.Application.handler.update_note_content (selected_note.id, note_content_buffer.text);
            }
        });

        var main_scrollable_area = new Gtk.ScrolledWindow () {
            child = note_content,
            hexpand = true,
            vexpand = true,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            margin_start = 12,
            margin_end = 12,
            margin_top = 6
        };

        var main_content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_content.add_css_class (Granite.STYLE_CLASS_BACKGROUND);
        main_content.append (main_header);
        main_content.append (main_scrollable_area);

        // Layout
        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            start_child = sidebar,
            end_child = main_content,
            resize_start_child = false,
            shrink_end_child = false,
            shrink_start_child = false
        };

        titlebar = new Gtk.Grid () {
            visible = false
        };

        child = paned;

        // Load last selected note from settings and select it
        var last_selected_note = Scribble.Application.settings.get_string ("note-selected");

        if (last_selected_note != "") {
            // TODO: Database check to ensure the note still exists?

            var temp_note = new Scribble.Objects.Note ();
            temp_note.id = last_selected_note;

		    uint position = -1;
            Scribble.Application.handler.notes_liststore.find_with_equal_func (temp_note, Scribble.Application.handler.equal_func, out position);

            if (position != -1) {
                int index = (int) position;
                var row = notes_listbox.get_row_at_index (index);

                if (row != null) {
                    notes_listbox.select_row (row);
                    notes_listbox.row_selected (row);
                } else {
                    warning ("Failed to find note with ID \"%s\" in list box: position in list box returned NULL", last_selected_note);
                }
            } else {
                warning ("Failed to find note with ID \"%s\": position in list store returned as -1", last_selected_note);
            }
        }

        // Save sidebar position to settings
        Scribble.Application.settings.bind ("sidebar-position", paned, "position", GLib.SettingsBindFlags.DEFAULT);

        // When a new note is selected in the sidebar/list box...
        notes_listbox.row_selected.connect ((row) => {
            var note_row = (Scribble.Widgets.NoteRow) row;

            // Get note
            var note = Scribble.Application.handler.get_note (note_row.note.id);

            // Set selected note
            selected_note = note;

            // Save last selected note to settings
            Scribble.Application.settings.set_string ("note-selected", note.id);

            // Update note content buffer
            allow_note_content_save_changes = false;
            note_content_buffer.set_text (note.content_md);
            allow_note_content_save_changes = true;
        });
    }

    // Creates a new note row for the notes list
    private Gtk.Widget create_note_row (GLib.Object object) {
        unowned var note = (Scribble.Objects.Note) object;
        return new Scribble.Widgets.NoteRow (note);
    }
}
