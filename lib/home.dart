import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animations/animations.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final db = FirebaseFirestore.instance;
  String task;
  bool isUpdate;


  void ShowDialog(isUpdate, DocumentSnapshot ds) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: isUpdate ? Text("Update Task") : Text("Add Task"),
          content: Form(
            key:formKey ,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  autovalidate: true,
                  autofocus: true,
                  decoration: InputDecoration(hintText: isUpdate ? ds["Task"] : "Task"),
                  validator: (value){
                    if(value.isEmpty)
                      {
                        return "Can't Be Empty";

                      }
                    else
                      {
                        return null;
                      }
                  },
                  onChanged: (val){
                    task = val;
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Center(
                    child: Row(
                      children: [
                        RaisedButton(
                          color: Colors.teal,
                          onPressed: () {

                            if(isUpdate){
                              db.collection("Task").doc(ds.id).update({"Task" : task, "DateTime" : DateTime.now()});
                            }
                            else{
                            db.collection("Task").add({"Task" : task, "DateTime" : DateTime.now()});

                            }
                              Navigator.pop(context);
                          },
                          child: Text(
                            "Add",
                            style: TextStyle(color: Colors.white),
                          ),
                          focusColor: Colors.teal,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
        onPressed: (){
          ShowDialog(false, null);
        },
      ),
      appBar:  AppBar(
        title: Text("Add Your Task", style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22
        ),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xff041955),
      ),
      body: Container(
        color: Color(0xff3450A1),
        child: StreamBuilder<QuerySnapshot>(
          stream: db.collection("Task").orderBy("DateTime").snapshots(),
          builder: (context, snapshot){
            if(snapshot.hasData)
              {
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index){
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Card(
                        margin: EdgeInsets.fromLTRB(30, 5, 30, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Color(0xff041955),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                     Text(ds["Task"].toString(), style: TextStyle(
                                       fontSize: 20,
                                       color: Colors.white,
                                       fontWeight: FontWeight.w500
                                     ),),
                              ]
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                              color: Colors.white,),
                                            iconSize: 27,
                                            onPressed: (){
                                                 ShowDialog(true, ds);
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 0,
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red,),
                                            iconSize: 27,
                                            onPressed: (){
                                              db.collection("Task").doc(ds.id).delete();
                                            },
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ),
                    );
                    }
                );
              }
            else if(snapshot.hasError)
              {
                return CircularProgressIndicator();
              }
            else
              {
                return CircularProgressIndicator();
              }
          },
        ),
      ),
    );
  }
}
