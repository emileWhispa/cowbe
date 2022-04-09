
import 'package:meta/meta.dart';

class User {
  String? id;
  String? employeeId;
  String? credentialId;
  String? credentialStatus;
  String? companyId;
  String? first;
  String? last;
  String? phone;
  String? status;
  String? email;
  String? time;
  String? districtId;
  @protected
  int language = 0;

  User.fromJson(Map<String, dynamic> json)
      : first = json['user_fname'],
        last = json['user_lname'],
        phone = json['user_phone'],
        employeeId = json['employee_id'],
        credentialId = json['credential_id'],
        credentialStatus = json['credential_status'],
        companyId = json['company_id'],
        id = json['user_id'],
        status = json['user_status'],
        districtId = json['district_id'],
        language = json['language'] ?? 0,
        time = json['last_login_time'],
        email = json['user_email'];

  Map<String, dynamic> toJson() => {
        'user_fname': first,
        'user_lname': last,
        'phone': phone,
        'user_status': status,
        'district_id': districtId,
        'credential_status': credentialStatus,
        'credential_id': credentialId,
        'company_id': companyId,
        'last_login_time': time,
        'user_email': status,
        'user_id': id,
        'language': language,
      };

  void setLang(int i) {
    language = i;
  }

  bool isEn() {
    return language == 0;
  }

  bool isKin() {
    return language == 1;
  }


  static User? user;
}
