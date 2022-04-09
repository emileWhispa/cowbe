

import 'category.dart';
import 'cell.dart';
import 'district.dart';
import 'sector.dart';
import 'village.dart';

class Client {
  String id;
  String first;
  String last;
  String? email;
  String phone;
  String status;
  String meterNumber;
  String? upi;
  String time;
  String? clientID;
  String? categoryName;
  String? index;
  String? nationalId;
  String? wssn;
  String? wss;
  String? wssPrice;
  Village village;
  bool deleted = false;
  Cell cell;
  Sector sector;
  int debt = 0;
  int fines = 0;
  District district;
  Category? category;

  Client(this.id,this.first,this.last,this.meterNumber,this.phone,this.status,this.time,this.wss,this.wssn,this.index,this.nationalId,this.clientID,this.village,this.cell,this.sector,this.district,this.category);

  Client.fromJson(Map<String, dynamic> json)
      : first = json['client_fname'],
        last = json['client_lname'],
        phone = json['client_phone'],
        id = json['client_id'],
        nationalId = json['client_nid'],
        upi = json['client_upi'],
        email = json['client_email'],
        wssPrice = json['wss_price'],
        meterNumber = json['client_meter_number'],
        index = json['client_current_index'],
        wssn = json['wssn_name'],
        wss = json['wss_name'],
        categoryName = json['category_name'],
        clientID = json['client_cid'],
        status = json['client_status'],
        debt = int.tryParse(json['client_debt'].toString()) ?? 0,
        fines = int.tryParse(json['client_fines'].toString()) ?? 0,
        time = json['client_reg_date'],
  district = District.fromJson(json),
  sector = Sector.fromJson(json, null),
  cell = Cell.fromJson(json,null),
  category = Category.fromJson(json),
  village = Village.fromJson(json, null);

  Map<String, dynamic> toJson() => {
    'client_fname': first,
    'client_lname': last,
    'client_fines': fines,
    'client_phone': phone,
    // 'category_name': categoryName,
    'client_status': status,
    'wssn_name': wssn,
    'wss_price': wssPrice,
    'wss_name': wss,
    'client_nid': nationalId,
    'client_upi': upi,
    'client_reg_date': time,
    'client_meter_number': meterNumber,
    'client_current_index': index,
    'user_email': status,
    'client_id': id,
    'client_debt': debt,
    'client_cid': clientID,
    'client_email': email,
    'village_id': village != null ? village.id : "",
    'village_name': village != null ? village.name : "",
    'cell_id': cell != null ? cell.id : "",
    'cell_name': cell != null ? cell.name : "",
    'sector_id': sector != null ? sector.id : "",
    'sector_name': sector != null ? sector.name : "",
    'sector_category': sector != null ? sector.category : "",
    'district_id': district != null ? district.id : "",
    'district_name': district != null ? district.name : "",
    'category_id': category?.id ?? "",
    'category_name': category?.name ?? "",
  };


  String get display=>"$first $last";


  String get singleChar =>first.isNotEmpty
        ? first.substring(0, 1).toUpperCase()
        : "";

  bool search(String query) {
    query = query.toLowerCase();
    return (first.toLowerCase().contains(query)) ||
        (last.toLowerCase().contains(query)) ||
        (phone.contains(query)) ||
        (meterNumber.toLowerCase().contains(query)) ||
        (village.name.toLowerCase().contains(query));
  }

}
