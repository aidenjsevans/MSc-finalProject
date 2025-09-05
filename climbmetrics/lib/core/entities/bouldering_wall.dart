import 'package:climbmetrics/models/bouldering/bouldering_wall_facilities_model.dart';

class BoulderingWall {

  final String city;
  final String companyID;
  final String description;
  final String email;
  final List<String> employees;
  final BoulderingWallFacilitiesModel facilities;
  final bool isPublic;
  final bool isEmployeesPublic;
  final String phoneNumber;
  final String postcode;
  final String street;

  BoulderingWall({
    required this.city,
    required this.companyID,
    required this.description,
    required this.email,
    required this.employees,
    required this.facilities,
    required this.isPublic,
    required this.isEmployeesPublic,
    required this.phoneNumber,
    required this.postcode,
    required this.street
  });
}