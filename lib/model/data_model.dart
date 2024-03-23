
Map dataTemplate( 
  {
    required String name,
    String dueDate = "", 
    List subList = const [], 
    String notes = "", 
  }) {
  return {
    "name": name,
    // "id": int //time?
    "due_date": dueDate,
    "sub_tasks": subList,
    "notes": notes,
  };
}

// class DataTemplate {

//   String? name;
//   String? dueDate = DateFormat("y-MM-d").format(DateTime.now());
//   List subTaskList = [];
//   String? notes = "";

//   void mapData() {
//     Map template = {
//       name : 
//     }
//   }
// }

