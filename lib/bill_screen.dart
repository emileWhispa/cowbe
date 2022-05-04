import 'dart:async';
import 'dart:convert';

import 'package:cowbe/super_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'json/bill.dart';
import 'json/client.dart';


class BillScreen extends StatefulWidget {
  final Client client;
  final Function(int i) exec;
  final Function(bool b) toggle;

  const BillScreen({Key? key,required this.client,required this.exec,required this.toggle})
      : super(key: key);

  @override
  _BillScreenState createState() => _BillScreenState();
}

class _BillScreenState extends Superbase<BillScreen> {
  List<Bill> _list = <Bill>[];
  bool _loading = true;
  String? uri;
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    uri = "?load-bills-id-phone-09-frf=" + widget.client.id;
    WidgetsBinding.instance?.addPostFrameCallback((_){
      loadPayment(false);
    });
    super.initState();
  }

  saveNew() {
    save(url(uri!), _list);
  }

  changeState(List<Bill> list) {
    setState(() {
      _list = list;
      _loading = false;
    });
    int i = 0;
    i = list.map((f) => f.total).toList().fold(0,(f, obj) => f + obj);
 widget.exec(i);
  }

  void refresher(){
    timer = Timer(const Duration(seconds: 30),()=>loadPayment(true));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void loadPayment(bool refresh) {
    if( widget.toggle != null ) widget.toggle(true);
    ajax(
        url: uri!,
        method: "POST",
        data: FormData.fromMap(
            {"client_id": widget.client.id, "action": "load-client-bills"}),
        onValue: (s, v) {
          Iterable map = s;
          var lst = map.map((f) => Bill.fromJson(f)).toList();
          changeState(lst);
        },
        onEnd: () {
 widget.toggle(false);
          if( refresh ) refresher();
          setState(() {
            _loading = false;
          });
        });


  }


  final int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  void _sort<T>(Comparable<T> Function(Bill d) getField, int columnIndex, bool ascending) {
    _dessertsDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  DessertDataSource get _dessertsDataSource=>DessertDataSource(_list);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: <Widget>[
          PaginatedDataTable(
            header: const Text('All bills'),
            source: _dessertsDataSource,
            onSelectAll: _dessertsDataSource._selectAll,
            horizontalMargin: 10,
            columns: <DataColumn>[
              DataColumn(
                label: const Text('Date'),
                onSort: (int columnIndex, bool ascending) => _sort<String>((Bill d) => d.date, columnIndex, ascending),
              ),
              DataColumn(
                label: const Text('O/I'),
                tooltip: 'The total amount of food energy in the given serving size.',
                numeric: true,
                onSort: (int columnIndex, bool ascending) => _sort<num>((Bill d) => d.oldIndex, columnIndex, ascending),
              ),
              DataColumn(
                label: const Text('N/I'),
                numeric: true,
                onSort: (int columnIndex, bool ascending) => _sort<num>((Bill d) => d.newIndex, columnIndex, ascending),
              ),
              DataColumn(
                label: const Text('Status'),
                numeric: true,
                onSort: (int columnIndex, bool ascending) => _sort<num>((Bill d) => d.newIndex, columnIndex, ascending),
              ),
              DataColumn(
                label: const Text('Total'),
                numeric: true,
                onSort: (int columnIndex, bool ascending) => _sort<num>((Bill d) => d.total, columnIndex, ascending),
              )
            ],
          )
        ],
      )
    );
  }


}



class DessertDataSource extends DataTableSource{
  final List<Bill> _desserts;

  DessertDataSource(this._desserts);

  void _sort<T>(Comparable<T> Function(Bill d) getField, bool ascending) {
    _desserts.sort((Bill a, Bill b) {
      if (!ascending) {
        final Bill c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= _desserts.length) {
      return null;
    }
    final Bill dessert = _desserts[index];
    return DataRow.byIndex(
      index: index,
      selected: dessert.selected,
      onSelectChanged: ( value) {
        if (dessert.selected != value) {
          _selectedCount += value == true ? 1 : -1;
          assert(_selectedCount >= 0);
          dessert.selected = value == true;
          notifyListeners();
        }
      },
      cells: <DataCell>[
        DataCell(Text(dessert.date)),
        DataCell(Text(fmtNbr(dessert.oldIndex))),
        DataCell(Text(fmtNbr(dessert.newIndex))),
        DataCell(Text(dessert.paymentStatus)),
        DataCell(Text('${dessert.total} RWF',style: const TextStyle(color: Colors.blue),)),
      ],
    );
  }

  String fmt(String test) {
    return test.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }


  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  String fmtNbr(num test) {
    return fmt(test.toInt().toString());
  }

  @override
  int get rowCount => _desserts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool? checked) {
    for (Bill dessert in _desserts) {
      dessert.selected = checked == true;
    }
    _selectedCount = checked == true ? _desserts.length : 0;
    notifyListeners();
  }
}
