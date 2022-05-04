import 'dart:math';

import 'package:cowbe/json/user.dart';
import 'package:cowbe/new_bill_creation_form.dart';
import 'package:cowbe/new_form.dart';
import 'package:cowbe/payment_screen.dart';
import 'package:cowbe/respondent_form.dart';
import 'package:cowbe/super_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bill_screen.dart';
import 'json/client.dart';

class PaymentForm extends StatefulWidget {
  final Client client;

  const PaymentForm({Key? key,required this.client,})
      : super(key: key);

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends Superbase<PaymentForm>
    with SingleTickerProviderStateMixin {
  TabController? _controller;
  String i = "0";
  String i2 = "0";
  bool _loading2 = false;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this);
    super.initState();
  }

  void toggle(bool b) {
    setState(() {
      _loading2 = b;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final Random random = Random();
    const TextStyle style = TextStyle(fontSize: 17);
    const TextStyle style2 = TextStyle(fontSize: 17,fontWeight: FontWeight.bold);
    return Scaffold(
      key: _scaffold,
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              CircleAvatar(
                child: Text(
                  widget.client.singleChar,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: colors[random.nextInt(colors.length)],
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.client.display,
                      style: const TextStyle(fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.client.meterNumber,
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ))
            ],
          ),
          actions: <Widget>[
            IconButton(
                icon: _loading2 ? const LinearProgressIndicator() : const SizedBox.shrink(),
                onPressed: () {}),
            IconButton(icon: const Icon(Icons.edit), onPressed: (){

              Navigator.of(context).push(CupertinoPageRoute(
                  fullscreenDialog: true,
                  builder: (BuildContext ctx) => RespondentForm(
                    func: (r) {
                      setState(() {
                        widget.client.first = r.first;
                        widget.client.last = r.last;
                      });
                    },
                    client: widget.client,
                    title: "Edit ${widget.client.display}",
                  )));
            })
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("Information",style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10,),
                  Row(
                    children: <Widget>[
                      const Text("Index : ",style: style2),
                      Text(widget.client.index ?? "",style: style)
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Text("Debt : ",style: style2),
                      Text('${fmtNbr(widget.client.debt)} RWF',style: widget.client.debt <= 0 ? style : const TextStyle(color: Colors.red,fontSize: 17))
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Text("Fines( Amande ) : ",style: style2),
                      Text('${fmtNbr(widget.client.fines)} RWF',style: widget.client.debt <= 0 ? style : TextStyle(color: Colors.red,fontSize: 17))
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Text("WSS : ",style: style2),
                      Text(widget.client.wss??"",style: style)
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Text("WSSN : ",style: style2),
                      Text(widget.client.wssn ?? "",style: style)
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Text("Category : ",style: style2),
                      Text(widget.client.categoryName ?? "",style: style)
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text("Address",style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10,),
                  Row(
                    children: <Widget>[
                      const Text("District name : ",style: style2),
                      Text(widget.client.district?.name ?? "",style: style)
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Text("Sector name : ",style: style2),
                      Text(widget.client.sector?.name??"",style: style)
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Text("Cell name : ",style: style2),
                      Text(widget.client.cell?.name??"",style: style)
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text("Contacts",style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10,),
                  Row(
                    children: <Widget>[
                      const Text("Telephone : ",style: style2),
                      Text(widget.client.phone,style: style)
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Text("Email : ",style: style2),
                      Text(widget.client.email??"",style: style)
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Text("Status : ",style: style2),
                      Text(widget.client.status,style: style)
                    ],
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ElevatedButton(onPressed: () async {
                        var p = await Navigator.of(context).push(CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (c) => NewBillCreationForm(
                        client: widget.client,
                        user: User.user
                        )));
                        if( p != null ) showS(p);
                      },child:
                      Row(
                        children: const <Widget>[
                          Icon(Icons.monetization_on),
                          Text(" Create Bill")
                        ],
                      ),),
                      ElevatedButton(onPressed: ()async{

                        var p = await Navigator.of(context).push(CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (c) => NewForm(
                              client: widget.client,
                              func: (p) {
                              },
                            )));
                        if( p != null ) showS(p);
                      },child: Row(
                        children: const <Widget>[
                          Icon(Icons.payment),
                          Text(" Add payment")
                        ],
                      ),),
                    ],
                  )
                ],
              ),
            ),
            PaymentScreen(
              toggle: toggle,
              client: widget.client,
              exec: (int i) {
                setState(() {
                  this.i = fmt(i.toString());
                });
              },
            ),
            BillScreen(
              toggle: toggle,
              client: widget.client,
              exec: (int i) {
                setState(() {
                  i2 = fmtNbr(i);
                });
              },
            ),
          ],
          controller: _controller,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.grey,
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(1, 1))
          ],
            color: Theme.of(context).primaryColor),
          child: SafeArea(
            child: TabBar(controller: _controller, tabs: <Tab>[
              const Tab(
                text: "Info",
              ),
              Tab(
                text: "Payment($i)",
              ),
              Tab(
                text: "Bills($i2)",
              ),
            ]),
          ),
        ));
  }


  void showS(String s) {
    showSnack(s);
  }


  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
}
