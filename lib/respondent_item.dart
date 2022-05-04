import 'dart:math';

import 'package:cowbe/client_details_form.dart';
import 'package:cowbe/new_form.dart';
import 'package:cowbe/super_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../json/user.dart';
import '../json/client.dart';
import 'new_bill_creation_form.dart';

class RespondentItem extends StatefulWidget {
  final Client client;
  final User? user;
  final bool replace;
  final Function(Client r) refresh;
  final Function(String string)? showSnack;
  final bool canTap;
  final bool fromBill;

  const RespondentItem(
      {Key? key,
      required this.client,
      this.user,
      this.replace = true,
      required this.refresh,
      this.showSnack,
      this.canTap = true,
      this.fromBill = true})
      : super(key: key);

  @override
  _RespondentItemState createState() => _RespondentItemState();
}

class _RespondentItemState extends Superbase<RespondentItem> {
  bool _deleting = false;
  bool _deleted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    return _deleted || widget.client.deleted
        ? ListTile(
            subtitle: Text(
              widget.client.display,
              style: const TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            title: Row(
              children: const <Widget>[
                Icon(Icons.not_interested),
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "This is deleted",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 23,
                        color: Colors.grey),
                  ),
                )
              ],
            ))
        : ListTile(
            leading: CircleAvatar(
              backgroundColor: colors[random.nextInt(colors.length)],
              child: Text(
                widget.client.singleChar,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              widget.client.display,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
            subtitle: Text(
              widget.client.meterNumber,
              style: const TextStyle(),
            ),
            onTap: widget.canTap
                ? () {
                    var wid = PaymentForm(client: widget.client);
                    push(wid, fullscreenDialog: true);
                  }
                : null,
          );
  }

  void deleteUser() {
    setState(() {
      _deleting = true;
    });

    ajax(
        url: "?delete=123",
        server: true,
        method: "POST",
        data: FormData.fromMap({
          "action": "delete-client",
          "client_id": widget.client.id,
        }),
        onValue: (res, String val) {
          setState(() {
            _deleted = true;
          });
          widget.client.deleted = true;
          widget.refresh(widget.client);
        },
        onEnd: () => setState(() => _deleting = false));
  }

  void popDelete() {
    showDialog(
        context: context,
        builder: (BuildContext build) {
          return AlertDialog(
            title: Text("DELETE ${widget.client.display}"),
            content: Text(
                "Are you sure , you want to delete ${widget.client.display} ?"),
            actions: <Widget>[
              TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(build).pop();
                  }),
              TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(build).pop();
                    deleteUser();
                  })
            ],
          );
        });
  }

  void showMenuSelection(String s) async {
    if (s == "update") {
      // Navigator.of(context).push(CupertinoPageRoute(
      //     fullscreenDialog: true,
      //     builder: (BuildContext ctx) => RespondentForm(
      //           func: (Client r) {
      //             setState(() {
      //               this.widget.client.first = r.first;
      //               this.widget.client.last = r.last;
      //             });
      //             if( widget.refresh != null ) widget.refresh(r);
      //           },
      //           user: widget.user,
      //           client: widget.client,
      //           title: "Edit ${widget.client.display}",
      //         )));
    } else if (s == "delete") {
      popDelete();
    } else if (s == "payment") {
      goPay();
    } else if (s == "bill") {
      // var resp = await Navigator.of(context).push(CupertinoPageRoute(
      //     fullscreenDialog: true,
      //     builder: (context) => BillForm(
      //           client: widget.client,
      //           user: widget.user,
      //         )));
      // if (resp != null && widget.showSnack != null) {
      //   widget.showSnack?.call(resp);
      // }
    }
  }

  void goPay() async {
    // var sp = await Navigator.of(context).push(CupertinoPageRoute(
    //     fullscreenDialog: true,
    //     builder: (c) => NewForm(
    //           client: widget.client,
    //           user: widget.user,
    //           func: (Payment p) {},
    //         )));
    // if (sp != null && widget.showSnack != null) widget.showSnack(sp);
  }
}
