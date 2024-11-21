/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 ThatTonybo <thattonybo@gmail.com>
 */

public class Scribble.MainWindow : Gtk.ApplicationWindow {
    public Gtk.ListBox notes_listbox;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            title: _("Scribble")
        );
    }

    construct {
        // Headers
        var sidebar_header = new Gtk.HeaderBar () {
            show_title_buttons = false,
            title_widget = new Gtk.Label ("")
        };

        sidebar_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        sidebar_header.pack_start (new Gtk.WindowControls (Gtk.PackType.START));

        var main_header = new Gtk.HeaderBar () {
            show_title_buttons = false
        };

        main_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        main_header.pack_end (new Gtk.WindowControls (Gtk.PackType.END));

        // Sidebar

        // (section title label)
        // TEMPORARY - notes should be sorted by creation date/time, then there should be a section for each
        // notable period eg. today, yesterday, last 30 days, October, November, etc...
        var notes_section_label = new Gtk.Label (_("Today")) {
            halign = START,
            margin_start = 12
        };
        notes_section_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        // (section list box)
        notes_listbox = new Gtk.ListBox ();

        //update_notes_list ();
        //notes_listbox.bind_model (playback_manager.queue_liststore, create_queue_row);
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
            Scribble.Application.handler.create_note (_("Untitled note"), "");
        });

        var actionbar = new Gtk.ActionBar ();
        actionbar.get_style_context ().add_class(Granite.STYLE_CLASS_FLAT);
        actionbar.pack_start (new_note_button);

        var sidebar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        sidebar.get_style_context ().add_class(Granite.STYLE_CLASS_SIDEBAR);
        sidebar.append (sidebar_header);
        sidebar.append (sidebar_scrollable_area);
        sidebar.append (actionbar);

        // Main content
        
        // temp code to test db updates
        /*var btntest = new Gtk.Button.with_label("test");
        btntest.clicked.connect(() => {
            Scribble.Application.handler.update_note_title ("e7cbfed2-cf96-4cbf-97ea-a7c8b23f27a3", "new title woo woo");
        });*/
        
        var main_content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_content.add_css_class (Granite.STYLE_CLASS_BACKGROUND);
        main_content.append (main_header);
        main_content.append (btntest);

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

        // Save sidebar position to settings
        Scribble.Application.settings.bind ("sidebar-position", paned, "position", GLib.SettingsBindFlags.DEFAULT);

        // Subscribe to notes being selected in the sidebar
        notes_listbox.row_selected.connect ((row) => {
            debug ("row clicked: %s", row.name);
        });
    }

    // Creates a new note row for the notes list
    private Gtk.Widget create_note_row (GLib.Object object) {
        unowned var note = (Scribble.Objects.Note) object;
        return new Scribble.Widgets.NoteRow (note);
    }
}
