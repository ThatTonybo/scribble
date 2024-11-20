public class Scribble.Objects.Note : GLib.Object {
    public string id { get; set; default = ""; }
    public string title { get; set; default = ""; }
    public string content_md { get; set; default = ""; }
    public string created_at { get; set; default = ""; }
}
