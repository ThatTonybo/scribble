/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 ThatTonybo <thattonybo@gmail.com>
 */

    // Temporary documentation for myself, so I don't forget what I've written:

    // Note: { id: string, title: string, content_md: string, created_at: string }

    // create a note: handler.create_note ("title", "content");
    // get all notes: Note[] notes = handler.get_all_notes ();
    // get a specific note: Note note = handler.get_note ("id");
    // update note title: handler.update_note_title ("id", "new title");
    // update note content: handler.update_note_content ("id", "new content");
    // delete a note: handler.delete_note ("id");

    /* listen for notes updated:
    handler.notes_updated.connect ((source) => {
        info ("Notes have been updated");
    });
    */

public struct Scribble.Note {
    public string id;
    public string title;
    public string content_md;
    public string created_at;
}

public class Scribble.Handler : Object {
    public static string db_path;
    public string db_err_msg;
    public Sqlite.Database db;

    public ListStore notes_liststore { get; public set; }

    public signal void db_opened ();
    public signal void notes_updated ();

    static construct {
        db_path = Environment.get_user_data_dir () + "/com.thattonybo.scribble/database.db";
    }
    
    construct {
        notes_liststore = new ListStore (typeof (Scribble.Objects.Note));
    }

    public void init_database () {
        create_dir ("/com.thattonybo.scribble");

		int ec = Sqlite.Database.open (db_path, out db);

        if (ec != Sqlite.OK) {
            critical ("Failed to open database");
        }

        init_tables();
        fill_notes_liststore ();

        db_opened ();
    }

    public void clear_database () {
        string db_path = Environment.get_user_data_dir () + db_path;
		File db_file = File.new_for_path (db_path);

		if (db_file.query_exists ()) {
			try {
				db_file.delete ();

				init_database ();
			} catch (Error err) {
				critical ("Failed to delete database file: %s\n", err.message);
			}
		}
    }

    private void init_tables () {
        string query = """
            CREATE TABLE IF NOT EXISTS Notes (
                id              TEXT PRIMARY KEY,
                title           TEXT,
                content_md      TEXT,
                created_at      TEXT
            );
        """;

        int ec = db.exec (query, null, out db_err_msg);

        if (ec != Sqlite.OK) {
            critical ("Failed to create database table: %s\n", db_err_msg);
        }
    }

    private void fill_notes_liststore () {
        var notes = get_all_notes ();

        notes.foreach((note) => {
            notes_liststore.append (note);
        });
    }

	private void create_dir (string dir) {
		string path = Environment.get_user_data_dir () + dir;
		File tmp = File.new_for_path (path);

		if (tmp.query_file_type (0) != FileType.DIRECTORY) {
			GLib.DirUtils.create_with_parents (path, 0775);
		}
	}

	// Used to find a note in the list store by ID
    public EqualFunc<string> equal_func = (a, b) => {
        return ((Scribble.Objects.Note) a).id == ((Scribble.Objects.Note) b).id;
    };

    // Get all notes
	public GenericArray<Scribble.Objects.Note> get_all_notes () {
	    string query = "SELECT * FROM Notes;";
	    Sqlite.Statement statement;

	    db.prepare_v2 (query, query.length, out statement);

	    GenericArray<Scribble.Objects.Note> notes = new GenericArray<Scribble.Objects.Note> ();

	    while (statement.step () == Sqlite.ROW) {
	        Scribble.Objects.Note note = new Scribble.Objects.Note ();

	        note.id = statement.column_text (0);
	        note.title = statement.column_text (1);
	        note.content_md = statement.column_text (2);
	        note.created_at = statement.column_text (3);

	        notes.add (note);
	    }

	    return notes;
	}

    // Get a count of how many notes are in the database
    public int get_notes_count () {
	    var notes = get_all_notes ();

	    return notes.length;
	}

    // Create a note
	public string create_note (string title, string content) {
	    string id = GLib.Uuid.string_random ();
	    string query = """
            INSERT INTO Notes (id, title, content_md, created_at)
            VALUES ($id, $title, $content_md, $created_at);
	    """;
	    Sqlite.Statement statement;

	    db.prepare_v2 (query, query.length, out statement);
        statement.bind_text (statement.bind_parameter_index ("$id"), id);
        statement.bind_text (statement.bind_parameter_index ("$title"), title);
        statement.bind_text (statement.bind_parameter_index ("$content_md"), content);
        statement.bind_text (statement.bind_parameter_index ("$created_at"), "i have no idea");

        if (statement.step () != Sqlite.DONE) {
			warning ("Failed to create note: %i: %s", db.errcode (), db.errmsg ());
		}

        // Add to list store
        var note = new Scribble.Objects.Note ();

        note.id = id;
        note.title = title;
        note.content_md = content;
        note.created_at = "i have no idea";

        notes_liststore.append (note);

		notes_updated ();

		return id;
	}

    // Get a note by ID
	public Scribble.Objects.Note get_note (string id) {
	    string query = "SELECT * FROM Notes WHERE id = $id;";
	    Sqlite.Statement statement;

	    db.prepare_v2 (query, query.length, out statement);
	    statement.bind_text (statement.bind_parameter_index ("$id"), id);

	    Scribble.Objects.Note note = new Scribble.Objects.Note ();

	    if (statement.step () == Sqlite.ROW) {
	        note = new Scribble.Objects.Note ();

	        note.id = statement.column_text (0);
	        note.title = statement.column_text (1);
	        note.content_md = statement.column_text (2);
	        note.created_at = statement.column_text (3);
	    }

	    return note;
	}

    // Update a note's title
    public bool update_note_title (string id, string title) {
        string query = "UPDATE Notes SET title = $title WHERE id = $id;";
        Sqlite.Statement statement;

        db.prepare_v2 (query, query.length, out statement);
	    statement.bind_text (statement.bind_parameter_index ("$id"), id);
	    statement.bind_text (statement.bind_parameter_index ("$title"), title);

	    if (statement.step () != Sqlite.DONE) {
			warning ("Failed to update title of note with ID \"%s\": %i: %s", id, db.errcode (), db.errmsg ());
		}

        // Update in list store
        var temp_note = new Scribble.Objects.Note ();
        temp_note.id = id;

		uint position = -1;
        notes_liststore.find_with_equal_func (temp_note, equal_func, out position);

        if (position != -1) {
            var note = (Scribble.Objects.Note) notes_liststore.get_object (position);
            note.title = title;
        } else {
            warning ("Failed to update title of note with ID \"%s\": position in list store returned as -1", id);
        }

		notes_updated ();

        return statement.step () == Sqlite.DONE;
    }

    // Update a note's content
    public bool update_note_content (string id, string content) {
        string query = "UPDATE Notes SET content_md = $content_md WHERE id = $id;";
        Sqlite.Statement statement;

        db.prepare_v2 (query, query.length, out statement);
	    statement.bind_text (statement.bind_parameter_index ("$id"), id);
	    statement.bind_text (statement.bind_parameter_index ("$content_md"), content);

	    if (statement.step () != Sqlite.DONE) {
			warning ("Failed to update content of note with ID \"%s\": %i: %s", id, db.errcode (), db.errmsg ());
		}

		// Update in list store
        var temp_note = new Scribble.Objects.Note ();
        temp_note.id = id;

		uint position = -1;
        notes_liststore.find_with_equal_func (temp_note, equal_func, out position);

        if (position != -1) {
            var note = (Scribble.Objects.Note) notes_liststore.get_object (position);
            note.content_md = content;
        } else {
            warning ("Failed to update title of note with ID \"%s\": position in list store returned as -1", id);
        }

		notes_updated ();

        return statement.step () == Sqlite.DONE;
    }

    // Delete a note
    public bool delete_note (string id) {
        string query = "DELETE FROM Notes WHERE id = $id;";
        Sqlite.Statement statement;

	    db.prepare_v2 (query, query.length, out statement);
        statement.bind_text (statement.bind_parameter_index ("$id"), id);

        if (statement.step () != Sqlite.DONE) {
			warning ("Failed to delete note with ID \"%s\": %i: %s", id, db.errcode (), db.errmsg ());
		}

		// Remove from list store
        var temp_note = new Scribble.Objects.Note ();
        temp_note.id = id;

		uint position = -1;
        notes_liststore.find_with_equal_func (temp_note, equal_func, out position);

        if (position != -1) {
            notes_liststore.remove (position);
        } else {
            warning ("Failed to delete note with ID \"%s\": position in list store returned as -1", id);
        }

        notes_updated ();

        return statement.step () == Sqlite.DONE;
    }
}
