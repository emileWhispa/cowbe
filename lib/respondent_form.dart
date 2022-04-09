import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'json/category.dart';
import 'json/cell.dart';
import 'json/client.dart';
import 'json/district.dart';
import 'json/sector.dart';
import 'json/user.dart';
import 'json/village.dart';
import 'json/wss.dart';
import 'super_base.dart';

class RespondentForm extends StatefulWidget {
  final Function(Client r) func;
  final User user;
  final Client? client;
  final String title;

  const RespondentForm(
      {Key? key,
      required this.func,
      required this.user,
      this.client,
      this.title= "New Client"})
      : super(key: key);

  @override
  _RespondentFormState createState() => _RespondentFormState();
}

class _RespondentFormState extends Superbase<RespondentForm> {
  TextEditingController phone = TextEditingController();
  TextEditingController first =  TextEditingController();
  TextEditingController last =  TextEditingController();
  TextEditingController email =  TextEditingController();
  TextEditingController clientField =  TextEditingController();
  TextEditingController upi = TextEditingController();
  TextEditingController nationalId =  TextEditingController();
  TextEditingController clientIndex =  TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  District? district;
  Sector? sector;
  Cell? cell;
  Village? village;
  String? _gender;
  Wss? _wss;
  bool _saving = false;
  bool _loading = true;
  Category? category;
  List<District> districts = <District>[];
  List<Sector> sectors = <Sector>[];
  List<Category> categories = <Category>[];
  List<Cell> cells = <Cell>[];
  List<Village> villages = <Village>[];
  List<Wss> wssList = <Wss>[];

  @override
  void dispose() {
    // TODO: implement dispose
    first.dispose();
    last.dispose();
    clientField.dispose();
    phone.dispose();
    super.dispose();
  }

  void loadWss() {
    ajax(
        url: "?loasd-wss",
        method: "POST",
        data: FormData.fromMap({
          "action": "list-wssn",
          "district_id": widget.user.districtId,
          "company_id": widget.user.companyId
        }),onValue: (map,url){
          setState(() {
            wssList = (map as Iterable).map((f)=>Wss.fromJson(f)).toList();
          });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    Client? res = widget.client;
    if (res != null) {
      phone = TextEditingController(text: res.phone);
      first =  TextEditingController(text: res.first);
      email =  TextEditingController(text: res.email);
      clientField =  TextEditingController(text: res.meterNumber);
      last =  TextEditingController(text: res.last);
      upi =  TextEditingController(text: res.upi);
      clientIndex =  TextEditingController(text: res.index);
      nationalId = TextEditingController(text: res.nationalId);
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _loading = true;
        sector = null;
        cell = null;
        village = widget.client?.village;
        districts.clear();
        sectors.clear();
        cells.clear();
        villages.clear();
      });
      loadWss();
      ajax(
          url: "?load-districts09",
          method: "POST",
          data: FormData.fromMap({"company_id": widget.user.companyId, "action": "districts"}),
          // error: (s,v)=>print("$s"),
          onValue: (map, String url) {
            List<District> list = (map as Iterable).map((model) =>District.fromJson(model)).toList();
            //list = list.where((f)=>f.id == widget.user.districtId).toList();
            for (var district in list) {
              this.district = res != null &&
                  district.id == res.district.id
                  ? district
                  : this.district;
            }
            setState(() {
              districts = list;
            });

            if (res != null && district != null) {
              loadSectors(district!);
            }
          },
          onEnd: () {
            setState(() {
              _loading = false;
            });
          });
      ajax(
          url: "?load-load-categies-560",
          method: "POST",
          // localSave: true,
          data: FormData.fromMap({"data": "", "action": "list-client-categories"}),
          onValue: (map, String url) {
            var list = (map as Iterable).map((model) {
              Category category = Category.fromJson(model);
              this.category = res != null &&
                      res.category != null &&
                      category.id == res.category!.id
                  ? category
                  : this.category;
              return category;
            }).toList();
            setState(() {
              categories = list;
            });
          },
          onEnd: () {
            setState(() {
              _loading = false;
            });
          });
    });
    super.initState();
  }

  void saveRespondent() {
    bool validate = _formKey.currentState?.validate() ?? false;
    if (validate &&
        village != null &&
        cell != null &&
        sector != null &&
        district != null &&
        _wss != null &&
        category != null) {
      setState(() {
        _saving = true;
      });
      ajax(
          url: "?send-req-1",
          method: "POST",
          json: false,
          data: FormData.fromMap({
            "action": "save-client",
            "client_phone": phone.text,
            "client_fname": first.text,
            "client_lname": last.text,
            "client_email": email.text,
            "client_meter_no": clientField.text,
            "wssn_id": _wss?.wssn,
            "client_index": clientIndex.text,
            "client_nid": nationalId.text,
            "gender": _gender,
            "client_id": widget.client != null ? widget.client!.id : "_",
            "user_id": widget.user.id,
            "village_id": village!.id,
            "cell_id": cell!.id,
            "sector_id": sector!.id,
            "employee_id": widget.user.employeeId,
            "company_id": widget.user.companyId,
            "client_upi": upi.text,
            "category_id": category!.id,
            "district_id": widget.user.districtId
          }),
          server: true,
          error: (s,v)=>print(s),
          onValue: (value, String url) {
            print(value);

            if(value['code'] == 200) {
              Client respondent = Client(
                  '0',
                  first.text,
                  last.text,
                  clientField.text,
                  phone.text,
                  "",
                  "",
                  _wss!.wss,
                  _wss!.wssn,
                  clientIndex.text,
                  nationalId.text,
                  clientField.text,
                  village!,
                  cell!,
                  sector!,
                  district!,
                  category);
              widget.func(respondent);
              Navigator.of(context).pop(value);
            }
            showSnack(value['message']??'');
          },
          onEnd: () => setState(() => _saving = false));
    } else {
      showSnack("Not valid, Information missing ...");
    }
  }


  void loadSectors(District district) {
    Client? res = widget.client;
    setState(() {
      sectors.clear();
      cells.clear();
      villages.clear();
      this.district = district;
      sector = null;
      cell = null;
      village = null;
      _loading = true;
    });
    ajax(
        url: "?load-sectors=" + district.id,
        method: "POST",
        // localSave: true,
        data: FormData.fromMap({"district_id": district.id, "action": "sectors"}),
        onValue: (map, String url) {
          List<Sector> list = (map as Iterable).map((model) {
            Sector sector = Sector.fromJson(model, district);

            this.sector =
                res != null && sector.id == res.sector.id
                    ? sector
                    : this.sector;

            return sector;
          }).toList();
          setState(() {
            sectors = list;
          });

          if (res != null && sector != null) {
            loadCells(sector!);
          }
        },
        onEnd: () {
          setState(() {
            _loading = false;
          });
        });
  }

  void loadCells(Sector sector) {
    Client? res = widget.client;
    setState(() {
      this.sector = sector;
      cell = null;
      village = null;
      cells.clear();
      villages.clear();
      _loading = true;
    });
    ajax(
        url: "?load-cells=" + sector.id,
        method: "POST",
        // localSave: true,
        data: FormData.fromMap({"sector_id": sector.id, "action": "cells"}),
        onValue: (map, String url) {
          List<Cell> list = (map as Iterable).map((model) {
            Cell cell = Cell.fromJson(model, sector);
            this.cell =
                res != null && cell.id == res.cell.id
                    ? cell
                    : this.cell;
            return cell;
          }).toList();
          setState(() {
            cells = list;
          });

          if (res != null && cell != null) {
            loadVillages(cell!);
          }
        },
        onEnd: () {
          setState(() {
            _loading = false;
          });
        });
  }

  void loadVillages(Cell cell) {
    Client? res = widget.client;
    setState(() {
      villages.clear();
      this.cell = cell;
      _loading = true;
    });
    ajax(
        url: "?load-villages=" + cell.id,
        method: "POST",
        // localSave: true,
        data: FormData.fromMap({"cell_id": cell.id, "action": "villages"}),
        onValue: (map, String url) {
          List<Village> list = (map as Iterable).map((model) {
            Village village = Village.fromJson(model, cell);

            this.village = res != null &&
                    village.id == res.village.id
                ? village
                : this.village;

            return village;
          }).toList();
          setState(() {
            villages = list;
          });
        },
        onEnd: () {
          setState(() {
            _loading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          _loading
              ? const IconButton(
                  icon: SizedBox(
                      height: 17,
                      width: 17,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      )),
                  onPressed: null)
              : const SizedBox.shrink(),
          IconButton(
            onPressed: _saving ? null : () => saveRespondent(),
            icon: _saving ? const LinearProgressIndicator() : Text("Next",style: TextStyle(
              color: Theme.of(context).textTheme.headline6?.color
            ),),
          )
        ],
      ),
      body: Form(
          key: _formKey,
          child:  ListView(
              padding: const EdgeInsets.all(10),
              children: <Widget>[
                TextFormField(
                  controller: clientField,
                  validator: (s) =>
                      s?.isNotEmpty == true ? null : "Client meter number is required",
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0x00fffeee))),
                      hintText: "PKRZ00001",
                      helperText: "Enter client meter number",
                    ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: nationalId,
                  validator: (s) => s?.isEmpty == true ? null : s?.length != 16
                      ? "Client national ID must be 16 chars"
                      : null,
                  maxLength: 16,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0x00fffeee))),
                      hintText: "National ID",
                      helperText: "Enter client national ID",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: clientIndex,
                  readOnly: widget.client != null,
                  validator: (s) =>
                      s?.isEmpty == true ? "Client index is required" : null,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0x00fffeee))),
                      hintText: "Index",
                      helperText: "Enter client index",
                   ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: phone,
                  validator: (s) =>
                      s?.length != 10 ? "10 digits required on phone ." : null,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: const TextInputType.numberWithOptions(),
                  maxLength: 10,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0x00fffeee))),
                      hintText: "Phone number",
                      helperText: "Enter valid phone number.",
                      ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: first,
                  validator: (s) => s?.isEmpty == true ? "First name is required" : null,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0x00fffeee))),
                      hintText: "First name",
                      helperText: "Enter valid first name.",
                    ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: last,
                  validator: (s) => s?.isEmpty == true ? "Last name is required" : null,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0x00fffeee))),
                      hintText: "Last name",
                      helperText: "Enter valid last name.",
                     ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0x00fffeee))),
                      hintText: "Email",
                      helperText: "Enter valid email address.",
                     ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: upi,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0x00fffeee))),
                      hintText: "Client upi",
                      helperText: "Enter valid client upi address.",
                 ),
                ),
                const SizedBox(
                  height: 10,
                ),
                DropdownButton<Wss>(
                  items: wssList.map((Wss value) => DropdownMenuItem<Wss>(
                            value: value,
                            child: Text(value.wssnName),
                          ))
                      .toList(),
                  value: _wss,
                  isExpanded: true,
                  hint: const Text("Choose your wss ..."),
                  onChanged: (Wss? wss) {
                    setState(() {
                      _wss = wss;
                    });
                  },
                ),
                DropdownButton<Category>(
                  items: categories
                      .map((Category value) => DropdownMenuItem<Category>(
                            value: value,
                            child: Text(value.name),
                          ))
                      .toList(),
                  value: category,
                  isExpanded: true,
                  hint: const Text("Choose category ..."),
                  onChanged: (Category? category) {
                    setState(() {
                      this.category = category;
                    });
                  },
                ),
                DropdownButton<District>(
                  items: districts.map((District value) {
                    return  DropdownMenuItem<District>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
                  value: district,
                  isExpanded: true,
                  hint: const Text("Choose district"),
                  onChanged: (District? district){
                    if(district != null){
                      loadSectors(district);
                    }
                  },
                ),
                DropdownButton<Sector>(
                  items: sectors.map((Sector value) {
                    return  DropdownMenuItem<Sector>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
                  value: sector,
                  isExpanded: true,
                  hint: const Text("Choose sector"),
                  onChanged: (Sector? sector){
                    if(sector != null){
                      loadCells(sector);
                    }
                  },
                ),
                DropdownButton<Cell>(
                  items: cells.map((Cell value) {
                    return  DropdownMenuItem<Cell>(
                      value: value,
                      child:  Text(value.name),
                    );
                  }).toList(),
                  value: cell,
                  isExpanded: true,
                  hint: const Text("Choose cell"),
                  onChanged: (Cell? cell){
                    if(cell != null){
                      loadVillages(cell);
                    }
                  },
                ),
                DropdownButton<Village>(
                  items: villages.map((Village value) {
                    return DropdownMenuItem<Village>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
                  value: village,
                  isExpanded: true,
                  hint: const Text("Choose village"),
                  onChanged: (Village? village) {
                    setState(() {
                      this.village = village;
                    });
                  },
                ),
              ],
            ),
      ),
    );
  }
}
