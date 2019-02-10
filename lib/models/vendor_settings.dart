import 'package:suarabiz/common/common.dart';

class VendorSettings {
  String uid;
  String email;
  String businessName;
  String businessDesc;
  String fbURL;
  dynamic location;
  dynamic location2;
  String whatsappNo;
  String phoneNo;
  String category;
  bool isOnline;
  bool isLoc1Def;
  int credits;
  String salesContact;
  bool creditPolicy;
  DateTime lastOnline;

  VendorSettings(this.uid, this.email) {
    isLoc1Def = true;
    isOnline = false;
    creditPolicy = false;
    lastOnline = DateTime.now();
  }

  VendorSettings.fromJson(dynamic f) {
    uid = f['uid'];
    email = f['email'];
    businessName = f['businessName'];
    businessDesc = f['businessDesc'];
    fbURL = f['fbURL'];
    location = f['location'];
    location2 = f['location2'];
    whatsappNo = f['whatsappNo'];
    phoneNo = f['phoneNo'];
    category = f['category'];
    isOnline = f['isOnline'] == null ? false : f['isOnline'];
    isLoc1Def = f['isLoc1Def'] == null ? true : f['isLoc1Def'];
    credits = f['credits'] ?? initialCredit;
    salesContact = f['salesContact'];
    creditPolicy = f['creditPolicy'];
    lastOnline = f['lastOnline'];
  }
}
