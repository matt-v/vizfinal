public class School {
  String name, id;
  boolean checked;
  color col;
  School(String name, String id, color col, boolean checked) {
    this.name = name;
    this.id = id;
    this.col = col;
    this.checked = checked;
  }
  void toggle() { checked = !checked; }
  boolean isChecked() { return checked; }
}
