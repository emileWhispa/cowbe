
class Wss {
  String id;
  String wss;
  String wssn;
  String wssnName;


  Wss.fromJson(Map<String, dynamic> json)
      : id = json['wss_id'],
        wssn = json['wssn_id'],
        wssnName = json['wssn_name'],
        wss = json['wss_id'];
  Map<String, dynamic> toJson() => {'wss_id': id, 'wss_id': wss, 'wssn_id': wssn, 'wssn_name': wssnName};
}
