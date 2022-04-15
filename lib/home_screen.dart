import 'dart:async';

import 'package:cowbe/client_list_screen.dart';
import 'package:cowbe/client_screen.dart';
import 'package:cowbe/json/user.dart';
import 'package:cowbe/reportage.dart';
import 'package:cowbe/respondent_form.dart';
import 'package:cowbe/super_base.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends Superbase<HomeScreen> {

  final _key = GlobalKey<RefreshIndicatorState>();

  Future<void> loadData(){
    return ajax(url: "home?employee_id=${User.user?.employeeId}",error: (s,v)=>refreshData(),onValue: (s,v){
      print(s);
      refreshData();
      setState(() {
        var map = s['data'];
        abatarishyuzwa = map['Abatarishyuzwa'];
        abatarishyura = map['Abatarishyura'];
        abishyujwe = map['Abishyujwe'];
        amavomero = map['Amavomero'];
        abishyuye = map['Abishyuye'];
      });
    });
  }



  refreshData(){
    Timer(const Duration(seconds: 30),loadData);
  }


  int abatarishyuzwa = 0;
  int abatarishyura = 0;
  int abishyujwe = 0;
  int amavomero = 0;
  int abishyuye = 0;

  @override
  void initState(){
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      reLoad();
    });
    super.initState();
  }

  void reLoad()=>_key.currentState?.show();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        key: _key,
        onRefresh: loadData,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Image.asset("assets/water_drop.png",fit: BoxFit.cover,height: 250,),
            Card(
              margin: EdgeInsets.zero,
              elevation: 2,
              shape: const RoundedRectangleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Expanded(child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text("Kubarura umufatabuguzi"),
                    )),
                    IconButton(onPressed: ()async{
                      await push(RespondentForm(func: (cl){}),fullscreenDialog: true);
                      reLoad();
                    }, icon: const Icon(Icons.arrow_forward))
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                        onTap: (){
                          push(ClientScreenScreen(user: User.user,));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Image.asset("assets/vector1.png"),
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text("Kwishyuza"),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                        onTap: (){
                          push(ClientScreenScreen(user: User.user,fromBill: false,));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Image.asset("assets/vector2.png"),
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text("Kwishyura"),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                        onTap: (){
                          push(const Reportage());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Image.asset("assets/vector3.png"),
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text("Raport"),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Card(
              margin: const EdgeInsets.all(20).copyWith(top: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 1),
                    shape: const RoundedRectangleBorder(),
                    child: InkWell(
                      onTap: ()async{
                        push(const ClientListViewScreen(url: "abatarishyuzwa",title: "Abatarishyuzwa",));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Image.asset("assets/vector4.png"),
                            const SizedBox(width: 7),
                            Expanded(child: Text("Abatarishyuzwa",style: Theme.of(context).textTheme.subtitle1,)),
                            Text("$abatarishyuzwa",style: TextStyle(
                              color: Theme.of(context).primaryColor
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 1),
                    shape: const RoundedRectangleBorder(),
                    child: InkWell(
                      onTap: ()async{
                        push(const ClientListViewScreen(url: "abatarishyura",title: "Abatarishyura",));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Image.asset("assets/vector5.png"),
                            const SizedBox(width: 7),
                            Expanded(child: Text("Abatarishyura",style: Theme.of(context).textTheme.subtitle1,)),
                            Text("$abatarishyura",style: TextStyle(
                                color: Theme.of(context).primaryColor
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 1),
                    shape: const RoundedRectangleBorder(),
                    child: InkWell(
                      onTap: ()async{
                        push(const ClientListViewScreen(url: "abishyujwe",title: "Abishyujwe",));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Image.asset("assets/vector6.png"),
                            const SizedBox(width: 7),
                            Expanded(child: Text("Abishyujwe",style: Theme.of(context).textTheme.subtitle1,)),
                            Text("$abishyujwe",style: TextStyle(
                                color: Theme.of(context).primaryColor
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 1),
                    shape: const RoundedRectangleBorder(),
                    child: InkWell(
                      onTap: ()async{
                        push(const ClientListViewScreen(url: "abishyuye",title: "Abishyuye",));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Image.asset("assets/vector7.png"),
                            const SizedBox(width: 7),
                            Expanded(child: Text("Abishyuye",style: Theme.of(context).textTheme.subtitle1,)),
                            Text("$abishyuye",style: TextStyle(
                                color: Theme.of(context).primaryColor
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 0),
                    shape: const RoundedRectangleBorder(),
                    child: InkWell(
                      onTap: ()async{

                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Image.asset("assets/water_tape.png"),
                            const SizedBox(width: 7),
                            Expanded(child: Text("Amavomero",style: Theme.of(context).textTheme.subtitle1,)),
                            Text("$amavomero",style: TextStyle(
                                color: Theme.of(context).primaryColor
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              offset: const Offset(-1.4,-1),
              blurRadius: 10
            )
          ]
        ),
        child: Material(
          child: InkWell(
            onTap: (){},
            child: Padding(
              padding: const EdgeInsets.all(20).copyWith(bottom: 30),
              child: const Text("Gusohoka",textAlign: TextAlign.center,style: TextStyle(
                color: Color(0xffCC0808),
                fontSize: 16
              ),),
            ),
          ),
        ),
      ),
    );
  }
}