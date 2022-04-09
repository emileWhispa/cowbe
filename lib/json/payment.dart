
import 'client.dart';
import 'mode.dart';

class Payment {
  String id;
  String number;
  int amount;
  Client client;
  String date;
  Mode mode;

  Payment(this.id, this.number,this.amount,this.client,this.mode,this.date);

  Payment.fromJson(Map<String, dynamic> json)
      : id = json['payment_id'],
        client = Client.fromJson(json),
        mode = Mode.fromJson(json),
        number = json['receipt_no'],
        date = json['payment_date'],
        amount = int.tryParse(json['payment_amount'].toString()) ?? 0;


  Map<String, dynamic> toJson(){
    Map<String, dynamic> map = toJson2();
    if( client != null ) map.addAll(client.toJson());
    if( mode != null ) map.addAll(mode.toJson());
    return map;
  }

  Map<String, dynamic> toJson2() =>
      {'payment_id': id, 'receipt_no': number, 'payment_amount': amount,'payment_date':date};
}
