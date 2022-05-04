import 'dart:async';
import 'dart:convert';

import 'package:cowbe/json/user.dart';
import 'package:cowbe/super_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'json/client.dart';
import 'json/payment.dart';
import 'new_form.dart';


class PaymentScreen extends StatefulWidget {
  final Client client;
  final Function(int i) exec;
  final Function(bool b) toggle;

  const PaymentScreen({Key? key,required this.client,required this.exec,required this.toggle})
      : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends Superbase<PaymentScreen> {
  List<Payment> _list = <Payment>[];
  bool _loading = true;
  String? uri;
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    uri = "?load-payment-id-x=" + widget.client.id;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      loadPayment(false);
      //this.refresh();
    });
    super.initState();
  }


  void refresher(){
    timer = Timer(Duration(seconds: 30),()=>loadPayment(true));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  saveNew() {
    save(url(uri!), _list);
  }

  changeState(List<Payment> list) {
    setState(() {
      _list = list;
      _loading = false;
    });
    int i = 0;
    i = list.map((f) => f.amount).toList().fold(0,(f, obj) => f + obj);
 widget.exec(i);
  }

  void loadPayment(bool refresh) {
 widget.toggle(true);
    ajax(
        url: uri!,
        method: "POST",
        data: FormData.fromMap(
            {"client_id": widget.client.id, "action": "load-payments"}),
        onValue: (s, v) {
          Iterable map = s as Iterable;
          var lst = map.map((f) => Payment.fromJson(f)).toList();
          changeState(lst);
        },
        onEnd: () {
          setState(() {
            _loading = false;
          });
 widget.toggle(false);
          if( refresh ) refresher();
        });
  }


  void showS(String s) {
    showSnack(s);
  }


  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffold,
      floatingActionButton: User.user != null ? FloatingActionButton(
        onPressed: () async {
          var sp = await Navigator.of(context).push(CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (c) => NewForm(
                client: widget.client,
                func: (Payment p) {
                  _list.add(p);
                  changeState(_list);
                  saveNew();
                },
              )));
          if( sp != null ) showS(sp);
        },
        child: const Icon(Icons.add_box),
      ) : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _list.length, itemBuilder: (ctx, i) => _row(i)),
    );
  }

  Widget _row(int i) {
    Payment payment = _list[i];
    return ListTile(
      title: Row(
        children: <Widget>[
          Text(payment.number,style: const TextStyle(fontWeight: FontWeight.w600),),
          Padding(padding: const EdgeInsets.only(left: 5),child: Text(payment.date),)
        ],
      ),
      subtitle: Text(payment.mode.name),
      trailing: Text(fmtNbr(payment.amount)),
    );
  }
}
