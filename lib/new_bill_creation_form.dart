import 'dart:convert';

import 'package:cowbe/super_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'json/client.dart';
import 'json/mode.dart';
import 'json/payment.dart';
import 'json/user.dart';

class NewBillCreationForm extends StatefulWidget {
  final Client client;
  final User? user;
  final Function(Payment payment)? func;

  const NewBillCreationForm({Key? key, required this.client, this.func,this.user})
      : super(key: key);

  @override
  _NewBillCreationFormState createState() => _NewBillCreationFormState();
}

class _NewBillCreationFormState extends Superbase<NewBillCreationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController amount =  TextEditingController();
  final TextEditingController receipt = TextEditingController();
  final TextEditingController reason =  TextEditingController();
  bool _saving = true;
  List<Mode> _list = <Mode>[];
  Mode? mode;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance?.addPostFrameCallback((_)=>loadModes());
    super.initState();
  }

  void loadModes() {
    ajax(
        url: "?load-modes",
        method: "POST",
        data: FormData.fromMap({"action": "load-methods","company_id":widget.user?.companyId}),
        onValue: (s, v) {
          print(s);
          var lst = (s as Iterable).map((f)=>Mode.fromJson(f)).toList();
          setState(() {
            _list = lst;
            _saving = false;
          });
        },
        onEnd: () {
          setState(() {
            _saving = false;
          });
        });
  }

  void saveForm() {
    if (!(_formKey.currentState?.validate()??true)) return;

    // if( mode == null ) return;

    setState(() {
      _saving = true;
    });

    ajax(
        url: "?saver",
        server: true,
        method: "POST",
        json: false,
        data: FormData.fromMap({
          "action": "generate-bill",
          "client_new_index": amount.text,
          "bill_no": receipt.text,
          //"reason": reason.text,
          "client_id": widget.client.id,
          "employee_id": widget.user?.employeeId,
          // "method_id":mode?.id
        }),
        error: (s,v)=>print(s),
        onValue: (s, v) {
          print(s);
          if(s['code'] == 200) {

            // widget9.func?.call(payment);
            Navigator.of(context).pop(s);
          }
          if(s is Map && s.containsKey("message")){
            showSnack(s['message']??'');
          }
        },
        onEnd: () {
          setState(() {
            _saving = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.display),
      ),
      body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            children: <Widget>[
              TextFormField(
                controller: amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (s) => s?.trim().isNotEmpty == true ? null : "Imibare iri muri mubazi irakenewe ",
                decoration: InputDecoration(
                    filled: true,
                    hintText: "Imibare iri muri mubazi ",
                    fillColor: const Color(0xffECF1F1),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)
                    )
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: receipt,
                validator: (s) =>
                s?.trim().isNotEmpty == true ? null :  "Nimero ya fagitire irakenewe ",
                decoration: InputDecoration(
                  filled: true,
                  hintText: "Nimero ya fagitire ",
                  fillColor: const Color(0xffECF1F1),
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12)
                  )
              ),
              ),
              const SizedBox(height: 15),
              // DropdownButton<Mode>(
              //   items: _list.map((Mode value) {
              //     return DropdownMenuItem<Mode>(
              //       value: value,
              //       child: Text(value.name),
              //     );
              //   }).toList(),
              //   value: mode,
              //   isExpanded: true,
              //   hint: const Text("Choose payment mode ..."),
              //   onChanged: (Mode? mode) {
              //     setState(() {
              //       this.mode = mode;
              //     });
              //   },
              // ),
              _saving ? const Center(
                child: CircularProgressIndicator(),
              ) : ElevatedButton(onPressed: saveForm,style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(17)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ))
              ), child: const Text("Bika Amakuru"))
            ],
          )),
    );
  }
}
