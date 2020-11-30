
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/util/dbHelper.dart';

DbHelper helper=DbHelper();
final List<String> choices = const <String> [
  "Save todo & Back",
  "Delete Todo",
  "Back to List"
];

const mnuSave="Save todo & Back";
const mnuDelete="Delete Todo";
const mnuBack="Back to List";

class TodoDetails extends StatefulWidget {
  final Todo todo;
  TodoDetails(this.todo);

  @override
  _TodoDetailsState createState() => _TodoDetailsState(todo);
}

class _TodoDetailsState extends State<TodoDetails> {

  Todo todo;
  _TodoDetailsState(this.todo);
  final _priorities = ["High", "Medium", "low"];
  String _priority = 'low';
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    titleController.text = todo.title;
    descriptionController.text = todo.description;
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(todo.title),
          actions: [
            PopupMenuButton<String>(
              onSelected: select,
              itemBuilder: (BuildContext context){
                return choices.map((String choice){
                  return PopupMenuItem<String>(
                    value:choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 35.0, left: 10.0, right: 10.0),
            child: ListView(children: [
              Column(
                children: [
                  TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value)=>updateTitle(),
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextField(
                        controller: descriptionController,
                        onChanged: (value)=>updateDescription(),
                        style: textStyle,
                        decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      )),
                  DropdownButton<String>(
                      items: _priorities
                          .map((String value) => DropdownMenuItem<String>(
                                child: Text(value),
                                value: value,
                              ))
                          .toList(),
                      style: textStyle,
                      value: retrievePriorities(todo.priority),
                      onChanged: (value)=>updatePriority(value))
                ],
              )
            ])));
  }

  void select (String value) async{
    int result;
    switch(value){
      case mnuSave:
        save();
        break;
      case mnuDelete:
        Navigator.pop(context,true);
        if(todo.id==null){
          return;
        }
        result=await helper.deleteTodo(todo.id);
        if(result != 0){
          AlertDialog alertDialog=AlertDialog(
            title: Text("Delete Todo"),
            content: Text("The todo has been deleted"),
          );
          showDialog(context: context,
          builder: (_) => alertDialog);
        }
        break;
      case mnuBack:
        Navigator.pop(context,true);
        break;
      default:
    }
  }

  void save(){
    //todo.date=new (DateTime.now());
    if(todo.id != null){
      helper.updateItem(todo);
    }
    else{
      helper.insertTodo(todo);
    }
    Navigator.pop(context,true);
  }

  void updatePriority(String value){
    switch(value){
      case "High":
       todo.priority=1;
        break;
      case "Medium":
        todo.priority=2;
        break;
      case "Low":
        todo.priority=3;
        break;
    }
    setState(() {
      _priority=value;
    });
  }

  String retrievePriorities(int value){
    return _priorities[value - 1];
  }

  void updateDescription(){
    todo.description=descriptionController.text;
  }

  void updateTitle(){
    todo.title=titleController.text;
  }
}
