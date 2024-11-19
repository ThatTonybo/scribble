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
    public Sqlite.Database db;
    public string err_msg;

    public signal void db_opened ();
    public signal void notes_updated ();

    static construct {
        db_path = Environment.get_user_data_dir () + "/com.thattonybo.scribble/database.db";
    }

    public void init_database () {
        create_dir ("/com.thattonybo.scribble");

		int ec = Sqlite.Database.open (db_path, out db);

        if (ec != Sqlite.OK) {
            critical ("Failed to open database");
        }

        init_tables();

        db_opened ();
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

        int ec = db.exec (query, null, out err_msg);

        if (ec != Sqlite.OK) {
            critical ("Failed to create database table: %s\n", err_msg);
        }
    }

	private void create_dir (string dir) {
		string path = Environment.get_user_data_dir () + dir;
		File tmp = File.new_for_path (path);

		if (tmp.query_file_type (0) != FileType.DIRECTORY) {
			GLib.DirUtils.create_with_parents (path, 0775);
		}
	}

    // Get all notes
	public Note[] get_all_notes () {
	    string query = "SELECT id, title, created_at FROM Notes;";
	    Sqlite.Statement statement;

	    db.prepare_v2 (query, query.length, out statement);

	    Note[] notes = {};

	    while (statement.step () == Sqlite.ROW) {
	        Note note = Note() {
	            id = statement.column_text (0),
	            title = statement.column_text (1),
	            content_md = statement.column_text (2),
	            created_at = statement.column_text (3)
	        };

	        notes += note;
	    }

	    return notes;
	}

    // Create a note
	public bool create_note (string title, string content) {
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

		notes_updated ();

		return statement.step () == Sqlite.DONE;
	}

    // Get a note by ID
	public Note get_note (string id) {
	    string query = "SELECT * FROM Notes WHERE id = $id;";
	    Sqlite.Statement statement;

	    db.prepare_v2 (query, query.length, out statement);
	    statement.bind_text (statement.bind_parameter_index ("$id"), id);

	    Note note = Note();

	    if (statement.step () == Sqlite.ROW) {
	        note = Note() {
	            id = statement.column_text (0),
	            title = statement.column_text (1),
	            content_md = statement.column_text (2),
	            created_at = statement.column_text (3)
	        };
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

        notes_updated ();

        return statement.step () == Sqlite.DONE;
    }
}