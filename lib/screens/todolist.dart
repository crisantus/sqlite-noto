import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/screens/tododetails.dart';
import 'package:todo_app/util/dbHelper.dart';

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  DbHelper helper=DbHelper();
  List<Todo> todos;
  int count=0;

  @override
  Widget build(BuildContext context) {
    if(todos==null){
      todos=List<Todo>();
      getData();
    }
    return Scaffold(
      body: todoListItems(),
      floatingActionButton: FloatingActionButton(onPressed:(){
        navigateToDetails(Todo('',3,''));
       },
       tooltip: "Add new Todo",
       child: Icon(Icons.add),),
    );
  }

  ListView todoListItems(){
    return ListView.builder(
        itemCount:  count,
        itemBuilder: (BuildContext context,int position){
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getColors(this.todos[position].priority),
                child: Text(this.todos[position].priority.toString()),
              ),
              title: Text(this.todos[position].title),
              subtitle: Text(this.todos[position].date),
              onTap: (){
                debugPrint("Tapped on "+ this.todos[position].id.toString());
                navigateToDetails(this.todos[position]);
              },
            ),
          );
        });
  }

  //method to retrieve data from the database
  void getData(){
    final dbFuture=helper.initializeDb();//open or create
     dbFuture.then((result){
       final todoFuture=helper.getTodo();
       todoFuture.then((result){
         List<Todo> todoList=List<Todo>();
         count=result.length;
         for(int i=0; i<count; i++){
           todoList.add(Todo.fromObject(result[i]));
           debugPrint(todoList[i].title);
         }
         setState(() {
           todos=todoList;
           count=count;
         });
         debugPrint("items "+ count.toString());
       });
     });
}

Color getColors(int priority){
    switch(priority){
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.blue;
        break;
      case 3:
        return Colors.green;
        break;
      default:
        return Colors.green;
    }
}

void navigateToDetails(Todo todo) async {
    bool result=await Navigator.push(context,
    MaterialPageRoute(builder: (context) => TodoDetails(todo)));
    //update the list when the user return
  if(result == true){
    getData();
  }
}
}
