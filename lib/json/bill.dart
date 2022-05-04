
import 'Client.dart';

class Bill {
  String id;
  String date;
  String time;
  int amount;
  int total;
  Client client;
  int oldIndex;
  int newIndex;
  String status;
  String paymentStatus;
  bool selected = false;

  // Bill(this.id, this.amount, this.client);

  Bill.fromJson(Map<String, dynamic> json)
      : id = json['bill_id'],
        client = Client.fromJson(json),
        date = json['bill_date'],
        time = json['bill_time'],
        total = int.tryParse('${json['bill_total']}') ?? 0,
        oldIndex = int.tryParse('${json['bill_old_index']}') ?? 0,
        newIndex = int.tryParse('${json['bill_new_index']}') ?? 0,
        status = json['bill_status'],
        paymentStatus = json['bill_pay_status'],
        amount = int.tryParse(json['bill_amount'].toString()) ?? 0;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = toJson2();
 map.addAll(client.toJson());
    return map;
  }

  Map<String, dynamic> toJson2() => {
        'bill_id': id,
        'bill_time': time,
        'bill_date': date,
        'bill_old_index': oldIndex,
        'bill_new_index': newIndex,
        'bill_pay_status': paymentStatus,
        'bill_amount': 0,
        "bill_status": status
      };
}
