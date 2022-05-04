import 'package:cowbe/search_delegate.dart';

import 'json/user.dart';
import 'package:cowbe/respondent_item.dart';
import 'package:cowbe/super_base.dart';
import 'package:flutter/material.dart';

import 'json/client.dart';

class ClientListViewScreen extends StatefulWidget{
  final String url;
  final String? title;
  const ClientListViewScreen({Key? key, required this.url, this.title}) : super(key: key);

  @override
  State<ClientListViewScreen> createState() => _ClientListViewScreenState();
}

class _ClientListViewScreenState extends Superbase<ClientListViewScreen> {
  
  List<Client> _list = [];

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _key.currentState?.show();
    });
    super.initState();
  }

  final _key = GlobalKey<RefreshIndicatorState>();
  
  
  Future<void> loadData(){
    return ajax(url: "${widget.url}?employee_id=${User.user?.employeeId}",onValue: (obj,url){
      if(obj['code'] == 200){
        setState(() {
          _list = (obj['data'] as Iterable).map((e) => Client.fromJson(e)).toList();
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "Client List"),
        actions: [
          IconButton(onPressed: (){
            showSearch(context: context, delegate: SearchDemoSearchDelegate((query){
              var list = _list.where((element) => element.search(query)).toList();
              return ListView.builder(itemCount: list.length,itemBuilder: (context,index){
                return RespondentItem(client: list[index], refresh: (client){});
              });
            }));
          }, icon: const Icon(Icons.search))
        ],
      ),
      body: RefreshIndicator(
        key: _key,
        onRefresh: loadData,
        child: ListView.builder(itemCount: _list.length,itemBuilder: (context,index){
          return RespondentItem(client: _list[index], refresh: (client){});
        }),
      ),
    );
  }
}