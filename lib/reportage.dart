import 'dart:convert';

import 'package:cowbe/json/user.dart';
import 'package:cowbe/respondent_item.dart';
import 'package:cowbe/super_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'json/client.dart';

class Reportage extends StatefulWidget{

  const Reportage({Key? key}) : super(key: key);
  @override
  _ReportageState createState() => _ReportageState();
}

class _ReportageState extends Superbase<Reportage>  {

  final _key = GlobalKey<RefreshIndicatorState>();

  int bill = 0;
  int receipt = 0;
  double billedAmount = 0;
  String paidAmount = "0";
  String performance = "0%";
  int bonus = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_)=>_key.currentState?.show());
  }


  Future<void> _loadSummary(){
    return ajax(url: "?action=loadSummaryReport",data: FormData.fromMap({
      "employeeId":User.user?.employeeId
    }),method: "POST",onValue: (data,url){
      setState(() {
        bill = data['bills'];
        receipt = data['receipts'];
        billedAmount = data['billedAmount'] + 0.0;
        paidAmount = data['paidAmount'];
        performance = data['performance'];
        bonus = data['bonus'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    var bgColor = Colors.blue.shade100;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
      ),
      body: RefreshIndicator(
        key: _key,
        onRefresh: _loadSummary,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[

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
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Image.asset("assets/money_2.png"),
                            const SizedBox(width: 7),
                            Expanded(child: Text("Amafaranga nishyuje",style: Theme.of(context).textTheme.subtitle1,)),
                            Text(fmtNbr(billedAmount),style: TextStyle(
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

                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Image.asset("assets/money_3.png"),
                            const SizedBox(width: 7),
                            Expanded(child: Text("Amafaranga nishyuwe !",style: Theme.of(context).textTheme.subtitle1,)),
                            Text(paidAmount,style: TextStyle(
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
            // Card(
            //   child: InkWell(
            //     onTap: _showModal,
            //     child: const Padding(
            //       padding: EdgeInsets.all(16.0),
            //       child: Text("Non Billed",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            //     ),
            //   ),
            // ),
            // Card(
            //   child: InkWell(
            //     onTap: ()=>_showModal(action: "loadNonPaid"),
            //     child: const Padding(
            //       padding: EdgeInsets.all(16.0),
            //       child: Text("Non Paid",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  void _showModal({String action="loadNonBilled"}){

    showModalBottomSheet(context: context,clipBehavior: Clip.antiAlias,isScrollControlled: true,shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(6),topRight: Radius.circular(6))
    ), builder: (context){
      return _NonBilledDetail(user: User.user!,action: action,);
    });
  }
}

class _NonBilledDetail extends StatefulWidget{
  final User user;
  final String action;

  const _NonBilledDetail({Key? key,required this.user,required this.action}) : super(key: key);
  @override
  __NonBilledDetailState createState() => __NonBilledDetailState();
}

class __NonBilledDetailState extends Superbase<_NonBilledDetail> {
  
  List<Client> _list = [];
  final _key = GlobalKey<RefreshIndicatorState>();
  
  bool _loading = false;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_)=>_key.currentState?.show());
  }
  
  Future<void> _loadDetails(){
    setState(() {
      _loading = true;
    });
    return ajax(url: "?action=${widget.action}",method: "POST",data: FormData.fromMap({
      "employeeId":widget.user.employeeId
    }),onValue: (source,url){
      setState(() {
        _loading = false;
        _list = (source as Iterable).map((f)=>Client.fromJson(f)).toList();
      });
    },onEnd: (){
      setState(() {
        _loading = false;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: RefreshIndicator(
        key: _key,
        onRefresh: _loadDetails,
        child: _loading ? const Center(child: CircularProgressIndicator(),) : Scrollbar(
          child: ListView.builder(itemCount: _list.length,itemBuilder: (context,index){
            return RespondentItem(client: _list[index], user: widget.user, refresh: (r){},canTap: false);
          }),
        ),
      ),
    );
  }
}