import 'dart:async';

import 'package:cowbe/respondent_item.dart';
import 'package:cowbe/super_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'json/client.dart';
import 'json/user.dart';

class ClientScreenScreen extends StatefulWidget {
  final User? user;
  final bool isNew;
  final bool fromBill;

  const ClientScreenScreen({Key? key, this.user, this.isNew = false, this.fromBill = true})
      : super(key: key);

  @override
  _ClientScreenScreenState createState() => _ClientScreenScreenState();
}

class _ClientScreenScreenState extends Superbase<ClientScreenScreen> {
  void showDemoDialog<T>(
      {required Widget Function(BuildContext context) builder,
      required BuildContext context}) {
    showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: builder,
    ).then<void>((T? value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        showSnack('You selected: $value');
      }
    });
  }

  void popDialog(ThemeData theme) {
    showDemoDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose default language.'),
          children: <Widget>[
            DialogDemoItem(
              icon: Icons.account_circle,
              color: theme.primaryColor,
              text: 'English (UK)',
              onPressed: () {
                widget.user?.setLang(0);
                // this.auth("", json.encode(widget.user), widget.user.id);
                Navigator.of(context).pop();
              },
              checked: widget.user?.isEn() == true,
            ),
            DialogDemoItem(
              icon: Icons.account_circle,
              color: theme.primaryColor,
              text: 'Kinyarwanda',
              onPressed: () {
                widget.user?.setLang(1);
                // this.auth("", json.encode(widget.user), widget.user.id);
                Navigator.of(context).pop();
              },
              checked: widget.user?.isKin() == true,
            ),
            DialogDemoItem(
              icon: Icons.close,
              text: 'Cancel',
              color: theme.disabledColor,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _HomeData(user: widget.user!,fromBill: widget.fromBill,),
    );
  }
}

class _SearchDemoSearchDelegate extends SearchDelegate<Client?> {
  final List<Client> _data;
  final User? user;
  final bool fromBill;

  _SearchDemoSearchDelegate(this._data, {this.user,this.fromBill = true});

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Client> suggestions = query.isEmpty
        ? _data
        : _data.where((Client i) => i.search(query)).toList();

    return _SuggestionList(
      query: query,
      user: user,
      fromBill: fromBill,
      suggestions: suggestions,
      onSelected: (Client res) {
        query = res.first;
        showResults(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? IconButton(
              tooltip: 'Voice Search',
              icon: const Icon(Icons.mic),
              onPressed: () {},
            )
          : IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            ),
    ];
  }
}

class _HomeData extends StatefulWidget {
  final User? user;
  final bool fromBill;

  const _HomeData({Key? key, @required this.user, this.fromBill = true}) : super(key: key);

  @override
  __HomeDataState createState() => __HomeDataState();
}

class __HomeDataState extends Superbase<_HomeData> {
  bool _loading = true;
  bool _loadingMore = true;
  _SearchDemoSearchDelegate? _delegate;

  String get uri => "?load=questions_clients_id_xc&?page=$page";
  Timer? timer;
  final ScrollController _controller = ScrollController();

  int page = 1;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    setDelegate();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _refreshKey.currentState?.show(atTop: true);
      refresh();
      checkOut();
    });
    super.initState();

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !_loadingMore) {
        setState(() {
          _loadingMore = true;
        });
        loadQuestions(false, page: page);
      }
    });
  }

  void checkOut() {
    ajax(
        url: "?check-activity",
        method: "POST",
        server: true,
        data: FormData.fromMap({
          "action": "check_employee_status",
          "employee_id": widget.user?.employeeId
        }),
        onValue: (s, v) {
          // Map<String, dynamic> decode = json.decode(s);
          // var status = decode['employee_status'];
        });
  }

  void refreshOp() {
    timer = Timer(const Duration(seconds: 600), () => loadQuestions(true));
  }

  final List<String> _urls = [];

  Future<void> loadQuestions(bool refresh, {int page = 1}) {
    setState(() {});
    return ajax(
        url: uri,
        method: "POST",
        data: FormData.fromMap({
          "action": "list-clients",
          "pageNo": page,
          "pageSize": 100,
          "district_id": widget.user?.districtId,
          "company_id": widget.user?.companyId,
          "employee_id": widget.user?.employeeId
        }),
        onValue: (value, String url) {
          if (!_urls.contains(url)) {
            _urls.add(url);
            this.page++;
          }
          var lst = (value as Iterable).map((f) => Client.fromJson(f)).toList();
          setState(() {
            _list.removeWhere((f) => lst.any((fx) => fx.id == f.id));
            _list.addAll(lst);
            _loading = false;
          });
          setDelegate();
        },
        onEnd: () {
          setState(() {
            _loading = false;
            _loadingMore = false;
          });
          if (refresh) this.refresh();
        });
  }

  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  final List<Client> _list = <Client>[];

  Widget _buildRow(int i) {
    if (i == _list.length) {
      return Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: _loadingMore
              ? const CircularProgressIndicator()
              : const SizedBox(
                  height: 30,
                  width: 30,
                ),
        ),
      );
    }

    return RespondentItem(
      user: widget.user,
      fromBill: widget.fromBill,
      refresh: (Client c) {
        _list[i] = c;
        save(url(uri), _list);
      },
      showSnack: showSnack,
      client: _list[i],
    );
  }

  void setDelegate() {
    _delegate = _SearchDemoSearchDelegate(_list, user: widget.user,fromBill: widget.fromBill);
  }

  Future<void> refreshList() async {
    return loadQuestions(false);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Clients",
              style: TextStyle(fontSize: 17),
            ),
            Text(
              "${fmtNbr(_list.length)} clients",
              style: const TextStyle(fontSize: 13),
            )
          ],
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: _delegate!);
              }),
        ],
      ),
      body: RefreshIndicator(
          key: _refreshKey,
          child: _loading
              ? ListView(
                  // controller: _controller,
                  shrinkWrap: true,
                  children: const <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 48.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                )
              : Scrollbar(
                  child: ListView.separated(
                      primary: true,
                      // controller: _controller,
                      itemCount: _list.length + 1,
                      separatorBuilder: (context, index) {
                        return const Divider(height: 0);
                      },
                      itemBuilder: (BuildContext context, int i) =>
                          _buildRow(i))),
          onRefresh: refreshList),
    );
  }
}

class _SuggestionList extends StatefulWidget {
  const _SuggestionList(
      {required this.suggestions,
      required this.query,
      required this.onSelected,
      @required this.user, this.fromBill = true});

  final List<Client> suggestions;
  final User? user;
  final bool fromBill;
  final String query;
  final ValueChanged<Client> onSelected;

  @override
  __SuggestionListState createState() => __SuggestionListState();
}

class __SuggestionListState extends Superbase<_SuggestionList> {
  List<Client> _list = [];

  bool _searching = true;

  List<Client> get suggestions => _searching ? widget.suggestions : _list;

  String? _query;

  void _search(String query) {
    if (_query == query) return;

    _query = query;

    setState(() {
      _searching = true;
    });
    ajax(
        url: "?searchClient=true",
        method: "POST",
        server: true,
        data: FormData.fromMap({
          "action": "searchClient",
          "district_id": widget.user?.districtId,
          "company_id": widget.user?.companyId,
          "employee_id": widget.user?.employeeId,
          "query": query
        }),
        onValue: (source, url) {
          setState(() {
            _list =
                (source as Iterable).map((f) => Client.fromJson(f)).toList();
          });
        },
        onEnd: () {
          setState(() {
            _searching = false;
          });
        });
  }

  @override
  void didUpdateWidget(covariant _SuggestionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _search(widget.query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        child: ListView.builder(
      itemCount: suggestions.length + 1,
      itemBuilder: (BuildContext context, int i) {
        i = i - 1;

        if (i < 0) {
          return _searching
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: CupertinoActivityIndicator(),
                      ),
                      Text("Searching ..."),
                    ],
                  ),
                )
              : const SizedBox.shrink();
        }

        final Client client = suggestions[i];
        return RespondentItem(
          client: client,
          fromBill: widget.fromBill,
          refresh: (Client r) {},
          user: widget.user,
        );
      },
    ));
  }
}

class DialogDemoItem extends StatelessWidget {
  const DialogDemoItem(
      {Key? key,
      required this.icon,
      required this.color,
      required this.text,
      this.onPressed,
      this.checked = false})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final bool checked;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 36.0, color: color),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(text),
          ),
          checked
              ? Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
