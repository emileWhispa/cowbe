import 'dart:convert';

import 'package:cowbe/json/user.dart';
import 'package:cowbe/super_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'json/client.dart';
import 'json/mode.dart';
import 'json/payment.dart';

class NewForm extends StatefulWidget {
  final Client client;
  final Function(Payment payment)? func;

  const NewForm({Key? key, required this.client, this.func})
      : super(key: key);

  @override
  _NewFormState createState() => _NewFormState();
}

class _NewFormState extends Superbase<NewForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController amount = TextEditingController();
  final TextEditingController receipt = TextEditingController();
  final TextEditingController reason = TextEditingController();
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
        data: FormData.fromMap({"action": "load-methods","company_id":User.user?.companyId}),
        onValue: (s, v) {
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
    if (!(_formKey.currentState?.validate()??false)) return;

    if( mode == null ) return;

    setState(() {
      _saving = true;
    });

    ajax(
        url: "?saver",
        server: true,
        method: "POST",
        data: FormData.fromMap({
          "action": "save-payment",
          "amount": amount.text,
          "receipt_no": receipt.text,
          //"reason": reason.text,
          "client_id": widget.client.id,
          "employee_id": User.user?.employeeId,
          "method_id":mode?.id
        }),
        error: (s,v)=>print(s),
        onValue: (s, v) {
          print(s);
          // Payment payment = Payment(
          //     s, receipt.text, int.tryParse(amount.text) ?? 0, widget.client,mode!,DateTime.now().toString());
          // widget.func?.call(payment);
          if(s['code'] == 200) {
            Navigator.of(context).pop(s);
          }
          showSnack(s['message']??"");
        },
        onEnd: () {
          setState(() {
            _saving = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Payment"),
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
                validator: (s) => s?.isEmpty == true || s == null ? "Amafaranga yishyuye  arakenewe " : null,                  decoration: InputDecoration(
                  filled: true,
                  hintText: "Amafaranga yishyuye ",
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
                    s == null || s.isEmpty ? "Numero ya resi irakenewe " : null,
                decoration: InputDecoration(
                  filled: true,
                  hintText: "Numero ya resi ",
                  fillColor: const Color(0xffECF1F1),
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12)
                  )
              ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<Mode>(
                items: _list.map((Mode value) {
                  return DropdownMenuItem<Mode>(
                    value: value,
                    child: Text(value.name),
                  );
                }).toList(),
                value: mode,
                isExpanded: true,
                hint: const Text("Uburyo yishyuyemo ..."),
                onChanged: (Mode? mode) {
                  setState(() {
                    this.mode = mode;
                  });
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xffECF1F1),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)
                    )
                ),
              ),
              const SizedBox(height: 15),
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
