import 'package:climbmetrics/models/bouldering/bouldering_wall_facilities_model.dart';

class BoulderingWallModel {

  String? boulderingWallID;
  final String city;
  final String companyID;
  final String description;
  final String email;
  List<dynamic> employees;
  final BoulderingWallFacilitiesModel facilities;
  final bool isPublic;
  final bool isEmployeesPublic;
  final String phone;
  final String postcode;
  final String street;

  BoulderingWallModel({
    this.boulderingWallID,
    required this.city,
    required this.companyID,
    required this.description,
    required this.email,
    this.employees = const [],
    required this.facilities,
    required this.isPublic,
    required this.isEmployeesPublic,
    required this.phone,
    required this.postcode,
    required this.street
  });

  Map<String,dynamic> toMap() {
    return {
      'city': city,
      'company_id': companyID,
      'description': description,
      'email': email,
      'employees': employees,
      'facilities': facilities.toMap(),
      'is_public': isPublic,
      'is_employees_public': isEmployeesPublic,
      'phone': phone,
      'postcode': postcode,
      'street': street
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BoulderingWallModel) return false;
    return 
    boulderingWallID == other.boulderingWallID &&
    city == other.city &&
    companyID == other.companyID &&
    description == other.description &&
    email == other.email &&
    employees == other.employees &&
    facilities == other.facilities &&
    isPublic == other.isPublic &&
    isEmployeesPublic == other.isEmployeesPublic &&
    phone == other.phone &&
    postcode == other.postcode &&
    street == other.street;
  }

  @override
    int get hashCode => Object.hash(
      boulderingWallID,
      city,
      companyID,
      description,
      email,
      employees,
      facilities,
      isPublic,
      isEmployeesPublic,
      phone,
      postcode,
      street,
    );

  factory BoulderingWallModel.fromMap(String boulderingWallID, Map<String,dynamic> map) {
    final String city = map['city'];
    final String companyID = map['company_id'];
    final String description = map['description'];
    final String email = map['email'];
    final List<dynamic> employees = map['employees'];
    final BoulderingWallFacilitiesModel facilities = BoulderingWallFacilitiesModel.fromMap(map['facilities']);
    final bool isPublic = map['is_public'];
    final bool isEmployeesPublic = map['is_employees_public'];
    final String phone = map['phone'];
    final String postcode = map['postcode'];
    final String street = map['street'];
    return BoulderingWallModel(
      boulderingWallID: boulderingWallID,
      city: city, 
      companyID: companyID, 
      description: description, 
      email: email,
      employees: employees, 
      facilities: facilities, 
      isPublic: isPublic, 
      isEmployeesPublic: isEmployeesPublic, 
      phone: phone, 
      postcode: postcode, 
      street: street
    );
  }

  factory BoulderingWallModel.placeholder() {
    return BoulderingWallModel(
      boulderingWallID: '',
      city: '', 
      companyID: '', 
      description: '', 
      email: '', 
      facilities: BoulderingWallFacilitiesModel(), 
      isPublic: false, 
      isEmployeesPublic: false, 
      phone: '', 
      postcode: '', 
      street: ''
    );
  }
}