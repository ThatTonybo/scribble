/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 ThatTonybo <thattonybo@gmail.com>
 */

public class Scribble.Application : Gtk.Application {
    public Scribble.MainWindow main_window;

    public static GLib.Settings settings;
    public static Handler handler;

    public Application () {
        Object (
            application_id: "com.thattonybo.scribble",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        settings = new Settings ("com.thattonybo.scribble");
        handler = new Handler ();
    }

    protected override void startup () {
        base.startup ();

        // Database
        handler.init_database ();

        // Actions
        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit",  {"<Control>q"});
        quit_action.activate.connect (quit);

        var delete_selected_note_action = new SimpleAction ("delete_selected_note", null);

        add_action (delete_selected_note_action);
        set_accels_for_action ("app.delete_selected_note",  {"<Control>BackSpace"});
        delete_selected_note_action.activate.connect (() => {
            // Handle deleting the selected note
            main_window.delete_selected_note ();
        });

        // Dark mode
        unowned var granite_settings = Granite.Settings.get_default ();
        unowned var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
    }

    protected override void activate () {
        main_window = new MainWindow (this);

        // (previous settings)
        settings.bind ("window-height", main_window, "default-height", GLib.SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", main_window, "default-width", GLib.SettingsBindFlags.DEFAULT);

        if (settings.get_boolean ("window-maximized")) {
            main_window.maximize ();
        }

        settings.bind ("window-maximized", main_window, "maximized", GLib.SettingsBindFlags.SET);

        // Show main window
        main_window.present ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
