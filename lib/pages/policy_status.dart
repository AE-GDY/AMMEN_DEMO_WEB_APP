import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newest_insurance/companies/insurancecompanies.dart';
import 'package:newest_insurance/constants.dart';
import 'package:newest_insurance/services/database.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class PolicyStatus extends StatefulWidget {

  double currentHeight = 200.0;
  PolicyStatus({Key? key}) : super(key: key);

  @override
  _PolicyStatusState createState() => _PolicyStatusState();
}

class _PolicyStatusState extends State<PolicyStatus> {

  final GlobalKey _key = GlobalKey();
  DataBaseService dataBaseService = DataBaseService();
  int currentTime = 0;
  String currentComp = "الدلتا للتأمين";

  List<String> timings = [
    "9:00 AM", "9:15 AM", "9:30 AM", "9:45 AM", "10:00 AM", "10:15 AM", "10:30 AM", "10:45 AM", "11:15 AM", "11:30 AM",
    "11:45 AM", "12:00 PM", "12:15 PM", "12:30 PM", "12:45 PM", "1:00 PM", "1:15 PM", "1:30 PM", "1:45 PM", "2:00 PM", "2:15 PM", "2:30 PM", "2:45 PM", "3:00 PM", "3:15 PM", "3:30 PM", "3:45 PM", "4:00 PM",
    "4:15 PM", "4:30 PM", "4:45 PM", "5:00 PM", "5:15 PM", "5:30 PM", "5:45 PM", "6:00 PM", "6:15 PM", "6:30 PM", "6:45 PM",
    "7:00 PM", "7:15 PM", "7:30 PM", "7:45 PM", "8:00 PM", "8:15 PM", "8:30 PM", "8:45 PM", "9:00 PM", "9:15 PM", "9:30 PM", "9:45 PM",
    "10:00 PM", "10:15 PM", "10:30 PM", "10:45 PM",
  ];

  CalendarFormat format = CalendarFormat.week;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  String currentInsuranceComp = "none";
  String currentBrokerComp = "none";
  TextEditingController underwriterController = TextEditingController();
  TextEditingController policyPremiumController = TextEditingController();


  bool changePolicyPremium = false;

  Future<Map<String, dynamic>?> policiesApprovedData() async {
    return (await FirebaseFirestore.instance.collection('users-policy-approvals').
    doc('approvals').get()).data();
  }

  Future<Map<String, dynamic>?> policiesSchedulingStatus() async {
    return (await FirebaseFirestore.instance.collection('users-policy-approvals').
    doc('scheduling').get()).data();
  }

  Future<Map<String, dynamic>?> currentPolicyRequest() async {
    return (await FirebaseFirestore.instance.collection('users-policy-requests').
    doc(currentInsuranceCompany).get()).data();
  }

  Future<Map<String, dynamic>?> brokerCurrentPolicyRequest(String currentBroker) async {
    return (await FirebaseFirestore.instance.collection('users-policy-requests-broker').
    doc(currentBroker).get()).data();
  }


  Future<Map<String, dynamic>?> requestsDocCurrentPolicyRequest() async {
    return (await FirebaseFirestore.instance.collection('users-policy-requests').
    doc("requests").get()).data();
  }

  Future<Map<String, dynamic>?> getCurrentIdx() async {
    return (await FirebaseFirestore.instance.collection('users-policy-requests').
    doc("current-policy-request").get()).data();
  }

  Future<Map<String, dynamic>?> insuranceCompaniesSignedUp() async {
    return (await FirebaseFirestore.instance.collection('insurance-companies').
    doc('insurance-company-list').get()).data();
  }


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text("Status"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 1500,
          width: 1500,
          child:Stack(
            children: [

              // USER INFO
              Positioned(
                top: 50,
                left: 50,
                child: Container(
                  width: 400,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 5,
                        left: 90,
                        child: Text("Policy holder information", style: TextStyle(
                          fontSize: 20,
                          // fontWeight: FontWeight.bold,
                        ),),
                      ),
                      Positioned(
                        top: 50,
                        left: 10,
                        child: Text("Name: ${globalNewNames[globalCurrentPolicyIndex]}", style: TextStyle(
                          fontSize: 15,
                          // fontWeight: FontWeight.bold,
                        ),),
                      ),
                      Positioned(
                        top: 80,
                        left: 10,
                        child: Text("National ID: ${globalPolicyIDs[globalCurrentPolicyIndex]}", style: TextStyle(
                          fontSize: 15,
                          // fontWeight: FontWeight.bold,
                        ),),
                      ),
                      Positioned(
                        top: 110,
                        left: 10,
                        child: Text("Mobile: ${globalPolicyMobiles[globalCurrentPolicyIndex]}", style: TextStyle(
                          fontSize: 15,
                          // fontWeight: FontWeight.bold,
                        ),),
                      ),
                      Positioned(
                        top: 140,
                        left: 10,
                        child: Text("Email: ${globalPolicyEmails[globalCurrentPolicyIndex]}", style: TextStyle(
                          fontSize: 15,
                          // fontWeight: FontWeight.bold,
                        ),),
                      ),
                    ],
                  ),
                ),
              ),

              //VEHICLE INFO
              buildVehicleInfo(),

              //INSPECTION REPORT
              FutureBuilder(
                future: Future.wait([currentPolicyRequest(),requestsDocCurrentPolicyRequest(), insuranceCompaniesSignedUp()]),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasError){
                      return const Text("There is an error");
                    }
                    else if(snapshot.hasData){
                        if(snapshot.data[0]['$globalCurrentPolicyIndex']['status-inspection'] == true){
                          return  Positioned(
                            top: 20,
                            left: 500,
                            child: Container(
                              width: 300,
                              height: 270,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text("Inspector Report", style: TextStyle(
                                    fontSize: 20,
                                    // fontWeight: FontWeight.bold,
                                  ),),
                                  SizedBox(height: 10,),
                                  snapshot.data[2]['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['inspection-editable']?Container(
                                    width: 200,
                                    height: 50,
                                    child: TextButton(
                                      onPressed: (){},
                                      child: Text("Attach Report",style: TextStyle(
                                        color: Colors.white,
                                      ),),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ):Container(child: Text("Details Hidden"),),
                                  SizedBox(height: 10,),
                                  snapshot.data[2]['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['inspection-editable']?Container(
                                    height: 100,
                                    width: 250,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey[50],
                                      border: Border.all(width: 1.0,),
                                    ),
                                    child: Center(child: Text("Vehicle Attachments", style: TextStyle(
                                      fontSize: 20,
                                    ),)),
                                  ):Container(),
                                  SizedBox(height: 10,),
                                  snapshot.data[2]['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['inspection-editable']?Container(
                                    width: 170,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextButton(
                                      onPressed: () async {

                                        if(snapshot.data[0]['$globalCurrentPolicyIndex']['broker-name'] == "none"){
                                          await dataBaseService.updateInspectionToUnderwriting(
                                            signInAsBroker?currentBrokerCompany:currentInsuranceCompany,
                                            globalCurrentPolicyIndex,
                                            signInAsBroker,
                                          );
                                        }
                                        else{
                                          await dataBaseService.updateInspectionToBrokerInspectionApproval(
                                            signInAsBroker?currentBrokerCompany:currentInsuranceCompany,
                                            globalCurrentPolicyIndex,
                                            signInAsBroker,
                                          );
                                        }


                                        if(globalVehiclesRequested[globalCurrentPolicyIndex].isEmpty){
                                          int idx = 0;
                                          while(idx <= snapshot.data[1]['total-policy-amount']){
                                            if(globalNewNames[globalCurrentPolicyIndex] == snapshot.data[1]['$idx']['policy-holder-name']
                                                && currentInsuranceCompany == snapshot.data[1]['$idx']['intended-company']
                                                && globalPolicyVehicleIndexes[globalCurrentPolicyIndex] == snapshot.data[1]['$idx']['vehicle-index']
                                            ){

                                              if(snapshot.data[0]['$globalCurrentPolicyIndex']['broker-name'] == "none"){
                                                await dataBaseService.requestsDocUpdateInspectionToUnderwriting(idx);

                                              }
                                              else{
                                                await dataBaseService.requestsDocUpdateInspectionToBrokerInspectionApproval(idx);
                                              }
                                            }
                                            idx++;
                                          }
                                        }
                                        else{
                                          int idx = 0;
                                          while(idx <= snapshot.data[1]['total-policy-amount']){
                                            if(globalNewNames[globalCurrentPolicyIndex] == snapshot.data[1]['$idx']['policy-holder-name']
                                                && snapshot.data[1]['$idx']['vehicle-amount'] == globalVehiclesRequested[globalCurrentPolicyIndex].length){

                                              bool isPolicy = true;
                                              int vehicleIdx = 0;
                                              while(vehicleIdx < globalVehiclesRequested[globalCurrentPolicyIndex].length){
                                                if(snapshot.data[1]['$idx']['vehicles']['$vehicleIdx']['vehicle-index'] != globalVehiclesRequested[globalCurrentPolicyIndex][vehicleIdx].currentIndex){
                                                  isPolicy = false;
                                                }
                                                vehicleIdx++;
                                              }

                                              if(isPolicy){
                                                if(snapshot.data[0]['$globalCurrentPolicyIndex']['broker-name'] == "none"){
                                                  if(currentInsuranceCompany == snapshot.data[1]['$idx']['intended-company']){
                                                    await dataBaseService.requestsDocUpdateInspectionToUnderwriting(idx);
                                                  }
                                                }
                                                else{
                                                  await dataBaseService.requestsDocUpdateInspectionToBrokerInspectionApproval(idx);
                                                }
                                              }
                                            }
                                            idx++;
                                          }
                                        }


                                        print("current USER: ${globalNewNames[globalCurrentPolicyIndex]}");
                                        Navigator.pushNamed(context, '/policies-page');
                                      },
                                      child: Text("Complete Inspection", style: TextStyle(
                                        color: Colors.white,
                                      ),),
                                    ),
                                  ):Container(),
                                ],
                              ),
                            ),
                          );
                        }
                        else if(snapshot.data[0]['$globalCurrentPolicyIndex']['status-scheduling'] == true){
                          return  Positioned(
                            top: 50,
                            left: 500,
                            child: Container(
                              width: 300,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text("Inspector Report", style: TextStyle(
                                    fontSize: 20,
                                    // fontWeight: FontWeight.bold,
                                  ),),
                                  SizedBox(height: 40,),
                                  Text("Waiting for scheduling", style: TextStyle(
                                    fontSize: 15,
                                    // fontWeight: FontWeight.bold,
                                  ),),
                                ],
                              ),
                            ),
                          );
                        }
                        else{
                          return Positioned(
                            top: 50,
                            left: 500,
                            child: Container(
                              width: 300,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text("Inspector Report", style: TextStyle(
                                    fontSize: 20,
                                    // fontWeight: FontWeight.bold,
                                  ),),
                                  SizedBox(height: 40,),
                                  Text("Complete", style: TextStyle(
                                    fontSize: 15,
                                    // fontWeight: FontWeight.bold,
                                  ),),
                                  snapshot.data[2]['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['inspection-visible']?
                                  Container(
                                    width: 250,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextButton(
                                      onPressed: (){},
                                      child: Text("Download Inspection Report",style: TextStyle(
                                        color: Colors.white,
                                      ),),
                                    ),
                                  ):Container(),
                                ],
                              ),
                            ),
                          );
                        }
                      }
                  }
                  return const Text("");
                },

              ),

              // SCHEDULING
              FutureBuilder(
                //Future.wait([]),
                future: currentPolicyRequest(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasError){
                      return const Text("There is an error");
                    }
                    else if(snapshot.hasData){
                        if(snapshot.data['$globalCurrentPolicyIndex']['status-scheduling'] == true){
                          return Positioned(
                            top: 50,
                            left: 850,
                            child: Container(
                              height: 900,
                              width: 400,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),

                              child: Column(
                                children: [
                                  SizedBox(
                                    height: widget.currentHeight,
                                    child: FutureBuilder(
                                      future: insuranceCompaniesSignedUp(),
                                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                        if(snapshot.connectionState == ConnectionState.done){
                                          if(snapshot.hasError){
                                            return const Text("There is an error");
                                          }
                                          else if(snapshot.hasData){
                                            if(snapshot.data['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['scheduling-editable'] == false){
                                              return Container(
                                                child: Text("Scheduling Details Hidden"),
                                              );
                                            }
                                            else{
                                              return TableCalendar(
                                                key: _key,
                                                focusedDay:selectedDay,
                                                firstDay: DateTime(1990),
                                                lastDay: DateTime(2050),
                                                calendarFormat: format,
                                                daysOfWeekVisible: true,
                                                calendarStyle: CalendarStyle(
                                                  isTodayHighlighted:true,
                                                  selectedDecoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    shape: BoxShape.rectangle,
                                                    // borderRadius: BorderRadius.circular(10),
                                                  ),

                                                  todayTextStyle: TextStyle(color: Colors.black),
                                                  selectedTextStyle: TextStyle(color: Colors.black),
                                                  todayDecoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:Colors.black,
                                                    ),
                                                    color:Colors.white,
                                                    shape: BoxShape.rectangle,
                                                    //borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                headerStyle: HeaderStyle(
                                                  formatButtonVisible: true,
                                                  titleCentered: true,
                                                  formatButtonShowsNext: false,
                                                ),
                                                selectedDayPredicate: (DateTime date){
                                                  return isSameDay(selectedDay, date);
                                                },
                                                onDaySelected: (DateTime selectDay, DateTime focusDay){
                                                  setState(() {
                                                    if((focusDay.day >= DateTime.now().day && focusDay.month == DateTime.now().month) || focusDay.month > DateTime.now().month){
                                                      onCalender = true;
                                                      selectedDay = selectDay;
                                                      focusedDay = focusDay;
                                                      timePicked = selectedDay;
                                                    }
                                                  });
                                                  String formattedDate = DateFormat.LLLL().format(timePicked);
                                                  print(timePicked.day);
                                                },
                                              );
                                            }
                                          }
                                        }
                                        return const Text("Please wait");
                                      },

                                    ),
                                  ),

                                  FutureBuilder(
                                    future: insuranceCompaniesSignedUp(),
                                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                      if(snapshot.connectionState == ConnectionState.done){
                                        if(snapshot.hasError){
                                          return const Text("There is an error");
                                        }
                                        else if(snapshot.hasData){
                                          if(snapshot.data['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['scheduling-editable'] == false){
                                            return Container();
                                          }
                                          else{
                                            return SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              physics: ScrollPhysics(),
                                              child: Container(
                                                height: 50,
                                                margin: EdgeInsets.only(right: 20),
                                                child: ListView.builder(
                                                  itemCount: timings.length,
                                                  scrollDirection: Axis.horizontal,
                                                  physics: ScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemBuilder: (context, index){
                                                    return MaterialButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          currentTime = index;
                                                        });
                                                      },
                                                      child: buildTiming(index),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                      return const Text("Please wait");
                                    },

                                  ),

                                  SizedBox(height: 20,),


                                  FutureBuilder(
                                    future: Future.wait([currentPolicyRequest(),requestsDocCurrentPolicyRequest(), insuranceCompaniesSignedUp()]),
                                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                      if(snapshot.connectionState == ConnectionState.done){
                                        if(snapshot.hasError){
                                          return const Text("There is an error");
                                        }
                                        else if(snapshot.hasData){
                                          if(snapshot.data[2]['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['scheduling-editable'] == false){
                                            return Container();
                                          }
                                          else{
                                            return TextButton(
                                              onPressed: () async {

                                                // UPDATED NEW REQUEST AMOUNT


                                                if(snapshot.data[0]['$globalCurrentPolicyIndex']['broker-name'] == "none"){
                                                  print('1');
                                                  await dataBaseService.updateSchedulingToWaitingUserApproval(
                                                    currentInsuranceCompany,
                                                    globalCurrentPolicyIndex,
                                                  );
                                                  print('2');
                                                }
                                                else{
                                                  print('3');
                                                  await dataBaseService.updateToWaitingBrokerScheduleApproval(
                                                    currentInsuranceCompany,
                                                    globalCurrentPolicyIndex,
                                                  );
                                                  print('4');
                                                }

                                                if(globalVehiclesRequested[globalCurrentPolicyIndex].isEmpty){

                                                  print("5");

                                                  int idx = 0;
                                                  while(idx <= snapshot.data[1]['total-policy-amount']){
                                                    if(globalNewNames[globalCurrentPolicyIndex] == snapshot.data[1]['$idx']['policy-holder-name']
                                                        && globalPolicyVehicleIndexes[globalCurrentPolicyIndex] == snapshot.data[1]['$idx']['vehicle-index']
                                                    ){
                                                      print('6');
                                                      if(snapshot.data[0]['$globalCurrentPolicyIndex']['broker-name'] == "none"){
                                                        print('7');
                                                        if(currentInsuranceCompany == snapshot.data[1]['$idx']['intended-company']){
                                                          print('8');

                                                          await dataBaseService.requestsDocUpdateSchedulingToWaitingUserApproval(
                                                            idx,
                                                            timings[currentTime],
                                                            timePicked.day,
                                                            timePicked.month,
                                                            timePicked.year,
                                                            globalCurrentPolicyIndex,
                                                            signInAsBroker?currentBrokerCompany:currentInsuranceCompany,
                                                            signInAsBroker,
                                                          );
                                                          print('9');
                                                        }
                                                      }
                                                      else{
                                                        print('10');
                                                        await dataBaseService.requestsDocUpdateToWaitingBrokerScheduleApproval(
                                                          idx,
                                                          timings[currentTime],
                                                          timePicked.day,
                                                          timePicked.month,
                                                          timePicked.year,
                                                          globalCurrentPolicyIndex,
                                                          signInAsBroker?currentBrokerCompany:currentInsuranceCompany,
                                                          signInAsBroker,
                                                        );
                                                        print('11');
                                                      }
                                                      print('12');


                                                    }
                                                    idx++;
                                                  }
                                                }
                                                else{
                                                  int idx = 0;
                                                  while(idx <= snapshot.data[1]['total-policy-amount']){
                                                    if(globalNewNames[globalCurrentPolicyIndex] == snapshot.data[1]['$idx']['policy-holder-name']
                                                        && snapshot.data[1]['$idx']['vehicle-amount'] == globalVehiclesRequested[globalCurrentPolicyIndex].length){

                                                      bool isPolicy = true;
                                                      int vehicleIdx = 0;
                                                      while(vehicleIdx < globalVehiclesRequested[globalCurrentPolicyIndex].length){
                                                        if(snapshot.data[1]['$idx']['vehicles']['$vehicleIdx']['vehicle-index'] != globalVehiclesRequested[globalCurrentPolicyIndex][vehicleIdx].currentIndex){
                                                          isPolicy = false;
                                                        }
                                                        vehicleIdx++;
                                                      }

                                                      if(isPolicy){
                                                        print('13');
                                                        if(snapshot.data[0]['$globalCurrentPolicyIndex']['broker-name'] == "none"){
                                                          print('14');
                                                          if(currentInsuranceCompany == snapshot.data[1]['$idx']['intended-company']){
                                                            print('15');
                                                            print("REACHED REQUESTS DOC 1");
                                                            await dataBaseService.requestsDocUpdateSchedulingToWaitingUserApproval(
                                                              idx,
                                                              timings[currentTime],
                                                              timePicked.day,
                                                              timePicked.month,
                                                              timePicked.year,
                                                              globalCurrentPolicyIndex,
                                                              signInAsBroker?currentBrokerCompany:currentInsuranceCompany,
                                                              signInAsBroker,
                                                            );
                                                            print('16');
                                                          }
                                                        }
                                                        else{
                                                          print('17');
                                                          await dataBaseService.requestsDocUpdateToWaitingBrokerScheduleApproval(
                                                            idx,
                                                            timings[currentTime],
                                                            timePicked.day,
                                                            timePicked.month,
                                                            timePicked.year,
                                                            globalCurrentPolicyIndex,
                                                            signInAsBroker?currentBrokerCompany:currentInsuranceCompany,
                                                            signInAsBroker,
                                                          );
                                                          print('18');
                                                        }
                                                      }
                                                      print('18');
                                                    }
                                                    idx++;
                                                  }
                                                }

                                                Navigator.pushNamed(context, '/policies-page');
                                              },
                                              child: Container(
                                                width: 200,
                                                height: 35,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Center(
                                                  child: Text("Send Schedule link", style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                      return const Text("Please wait");
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        else{
                          Container();
                        }

                    }
                  }
                  return const Text("");
                },
              ),

              // UNDERWRITING
              FutureBuilder(
                future: Future.wait([currentPolicyRequest(),requestsDocCurrentPolicyRequest(), insuranceCompaniesSignedUp()]),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasError){
                      return const Text("There is an error");
                    }
                    else{
                      if(signInAsBroker){

                      }
                      else{
                        if(snapshot.data[0]['$globalCurrentPolicyIndex']['status-underwriting'] == true){
                          return Positioned(
                            top: 300,
                            left: 500,
                            child: Container(
                              width: 350,
                              height: 400,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text("Underwriter Decision", style: TextStyle(
                                    fontSize: 20,
                                    // fontWeight: FontWeight.bold,
                                  ),),
                                  SizedBox(height: 30,),
                                  /*
                                  TextField(
                                    decoration: InputDecoration(
                                      label: Text("Comments"),
                                    ),
                                    controller: underwriterController,
                                  ),
                                  */

                                  snapshot.data[2]['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['underwriting-editable']?Container(
                                    width: 200,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextButton(
                                      onPressed: (){},
                                      child: Text("Attach Report",style: TextStyle(
                                        color: Colors.white,
                                      ),),
                                    ),
                                  ):Container(
                                    child: Text("Underwriting Details Hidden"),
                                  ),


                                  SizedBox(height: 30,),
                                  snapshot.data[2]['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['underwriting-editable']?Container(
                                    width: 200,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextButton(
                                      onPressed: (){
                                        setState(() {
                                          if(changePolicyPremium){
                                            changePolicyPremium = false;
                                          }
                                          else{
                                            changePolicyPremium = true;
                                          }
                                        });
                                      },
                                      child: Text(changePolicyPremium?"Default Policy Premium":"Change Policy Premium", style: TextStyle(
                                        color: Colors.white,
                                      ),),
                                    ),
                                  ):Container(),
                                  SizedBox(height: 30,),
                                  snapshot.data[2]['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['underwriting-editable']? TextField(
                                    enabled: changePolicyPremium,
                                    decoration: InputDecoration(
                                      label: Text("Policy Premium"),
                                    ),
                                    controller: policyPremiumController,
                                  ):Container(),
                                  SizedBox(height: 60,),
                                  snapshot.data[2]['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['underwriting-editable']?Row(
                                    children: [
                                      SizedBox(width: 60,),
                                      Container(
                                        width: 80,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: mainColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: TextButton(
                                          onPressed: () async {


                                            if(snapshot.data[0]['$globalCurrentPolicyIndex']['broker-name'] == "none"){

                                              print('1');
                                              await dataBaseService.updateUnderwritingToWaitingICApproval(
                                                signInAsBroker?currentBrokerCompany:currentInsuranceCompany,
                                                globalCurrentPolicyIndex,
                                                signInAsBroker,
                                              );
                                              print('2');
                                            }
                                            else{
                                              await dataBaseService.updateUnderwritingToWaitingApprovalBroker(
                                                currentInsuranceCompany,
                                                globalCurrentPolicyIndex,
                                                signInAsBroker,
                                              );
                                            }
                                            print('3');


                                            if(globalVehiclesRequested[globalCurrentPolicyIndex].isEmpty){
                                              print('4');
                                              int idx = 0;
                                              while(idx <= snapshot.data[1]['total-policy-amount']){
                                                if(globalNewNames[globalCurrentPolicyIndex] == snapshot.data[1]['$idx']['policy-holder-name']
                                                    && currentInsuranceCompany == snapshot.data[1]['$idx']['intended-company']
                                                    && globalPolicyVehicleIndexes[globalCurrentPolicyIndex] == snapshot.data[1]['$idx']['vehicle-index']
                                                ){
                                                  print('5');
                                                  if(changePolicyPremium){
                                                    if(snapshot.data[0]['$globalCurrentPolicyIndex']['broker-name'] == "none"){
                                                      print('6');
                                                      await dataBaseService.requestsDocUpdateUnderwritingToWaitingIcApproval(idx, policyPremiumController.text);
                                                      print('7');
                                                    }
                                                    else{
                                                      print('8');
                                                      await dataBaseService.requestsDocUpdateUnderwritingToWaitingBrokerApproval(idx, policyPremiumController.text);
                                                      print('9');
                                                    }
                                                  }
                                                  else{
                                                    print('10');
                                                    if(snapshot.data[0]['$globalCurrentPolicyIndex']['broker-name'] == "none"){
                                                      print('11');
                                                      await dataBaseService.requestsDocUpdateUnderwritingToWaitingIcApprovalNoChangeInAmount(idx);
                                                      print('12');
                                                    }
                                                    else{
                                                      print('13');
                                                      await dataBaseService.requestsDocUpdateUnderwritingToWaitingBrokerApprovalNoChangeInAmount(idx);
                                                      print('14');
                                                    }
                                                    print('15');


                                                  }
                                                }
                                                idx++;
                                              }
                                            }
                                            else{
                                              int idx = 0;
                                              while(idx <= snapshot.data[1]['total-policy-amount']){
                                                if(globalNewNames[globalCurrentPolicyIndex] == snapshot.data[1]['$idx']['policy-holder-name']
                                                    && snapshot.data[1]['$idx']['vehicle-amount'] == globalVehiclesRequested[globalCurrentPolicyIndex].length
                                                && currentInsuranceCompany == snapshot.data[1]['$idx']['intended-company']){

                                                  bool isPolicy = true;
                                                  int vehicleIdx = 0;
                                                  while(vehicleIdx < globalVehiclesRequested[globalCurrentPolicyIndex].length){
                                                    if(snapshot.data[1]['$idx']['vehicles']['$vehicleIdx']['vehicle-index'] != globalVehiclesRequested[globalCurrentPolicyIndex][vehicleIdx].currentIndex){
                                                      isPolicy = false;
                                                    }
                                                    vehicleIdx++;
                                                  }

                                                  if(isPolicy){
                                                      if(changePolicyPremium){
                                                        if(snapshot.data[0]['$globalCurrentPolicyIndex']['broker-name'] == "none"){
                                                          await dataBaseService.requestsDocUpdateUnderwritingToWaitingIcApproval(idx,policyPremiumController.text);
                                                        }
                                                        else{
                                                          await dataBaseService.requestsDocUpdateUnderwritingToWaitingBrokerApproval(idx,policyPremiumController.text);
                                                        }
                                                      }
                                                      else{

                                                        if(snapshot.data[0]['$globalCurrentPolicyIndex']['broker-name'] == "none"){
                                                          await dataBaseService.requestsDocUpdateUnderwritingToWaitingIcApprovalNoChangeInAmount(idx);
                                                        }
                                                        else{
                                                          await dataBaseService.requestsDocUpdateUnderwritingToWaitingBrokerApprovalNoChangeInAmount(idx);
                                                        }
                                                      }
                                                  }
                                                }
                                                idx++;
                                              }
                                            }
                                            Navigator.pushNamed(context, '/policies-page');
                                          },
                                          child: Text("Approve", style: TextStyle(
                                            color: Colors.white,
                                            //fontWeight: FontWeight.bold,
                                          ),),
                                        ),
                                      ),
                                      SizedBox(width: 60,),
                                      Container(
                                        width: 80,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: mainColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: TextButton(
                                          onPressed: () {

                                          },
                                          child: Text("Decline", style: TextStyle(
                                            color: Colors.white,
                                            //fontWeight: FontWeight.bold,
                                          ),),
                                        ),
                                      ),
                                    ],
                                  ):Container(),
                                ],
                              ),
                            ),
                          );
                        }
                        else if(snapshot.data[0]['$globalCurrentPolicyIndex']['status-waiting-ic-approval'] == true){
                          return Positioned(
                            top: 300,
                            left: 500,
                            child: Container(
                              width: 300,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text("Underwriter Decision", style: TextStyle(
                                    fontSize: 20,
                                    // fontWeight: FontWeight.bold,
                                  ),),
                                  SizedBox(height: 40,),
                                  Text("Approved", style: TextStyle(
                                    fontSize: 15,
                                    // fontWeight: FontWeight.bold,
                                  ),),
                                  SizedBox(height: 20,),
                                  snapshot.data[2]['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['underwriting-visible']?
                                      Container(
                                        width: 200,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: TextButton(
                                          onPressed: (){},
                                          child: Text("Download Underwriting Report",style: TextStyle(
                                            color: Colors.white,
                                          ),),
                                        ),
                                      ):Container(),


                                ],
                              ),
                            ),
                          );
                        }
                        else{
                          return Positioned(
                            top: 300,
                            left: 500,
                            child: Container(
                              width: 300,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text("Underwriter Decision", style: TextStyle(
                                    fontSize: 20,
                                    // fontWeight: FontWeight.bold,
                                  ),),
                                  SizedBox(height: 60,),
                                  Text("Waiting for inspection", style: TextStyle(
                                    fontSize: 15,
                                    // fontWeight: FontWeight.bold,
                                  ),),
                                ],
                              ),
                            ),
                          );
                        }
                      }
                    }
                  }
                  return const Text("");
                },
              ),


              //IC APPROVAL
              FutureBuilder(
                future: currentPolicyRequest(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasError){
                      return const Text("There is an error");
                    }
                    else if(snapshot.hasData){
                        if(snapshot.data['$globalCurrentPolicyIndex']['status-waiting-ic-approval'] == true){
                          return Positioned(
                            top: 100,
                            left: 900,
                            child: Column(
                              children: [
                                FutureBuilder(
                                  future: Future.wait([currentPolicyRequest(),policiesApprovedData(), requestsDocCurrentPolicyRequest(),brokerCurrentPolicyRequest(currentBrokerCompany),insuranceCompaniesSignedUp()]),
                                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                    if(snapshot.connectionState == ConnectionState.done){
                                      if (snapshot.hasError) {
                                        return const Center(
                                          child: Text('there is an error'),
                                        );
                                      }
                                      else if(snapshot.hasData){

                                        if(snapshot.data[4]['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['completion-editable'] == false){
                                          return Container(
                                            child: Text("Pending Policy Request Approval",style: TextStyle(
                                              fontSize: 17,
                                            ),),
                                          );
                                        }
                                        else{
                                          return Container(
                                            width: 250,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: mainColor,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: TextButton(
                                              onPressed: () async {


                                                // UPDATES INSURANCE COMPANY STATUS
                                                await dataBaseService.updateWaitingICApprovalToApprovedRequest(
                                                  currentInsuranceCompany,
                                                  globalCurrentPolicyIndex,
                                                  signInAsBroker,
                                                );

                                                await dataBaseService.updatePendingPoliciesAmount(
                                                  currentInsuranceCompany,
                                                  snapshot.data[0]['total-pending-policies']+1,
                                                  signInAsBroker,
                                                );

                                                int policyAmount = 0;

                                                int index = 0;
                                                while(index < firstCompanies.length){
                                                  if(currentInsuranceCompany == firstCompanies[index].title){
                                                    policyAmount = firstCompanies[index].price;
                                                  }
                                                  index++;
                                                }

                                                index = 0;
                                                while(index < secondCompanies.length){
                                                  if(currentInsuranceCompany == secondCompanies[index].title){
                                                    policyAmount = secondCompanies[index].price;
                                                  }
                                                  index++;
                                                }

                                                if(globalVehiclesRequested[globalCurrentPolicyIndex].isEmpty){
                                                  print('1');
                                                  await dataBaseService.updateApprovalsNew(
                                                    signInAsBroker?currentBrokerCompany:'none',
                                                    globalPolicyVehicleMakes[globalCurrentPolicyIndex],
                                                    globalPolicyVehicleModels[globalCurrentPolicyIndex],
                                                    globalPolicyVehicleIndexes[globalCurrentPolicyIndex],
                                                    currentInsuranceCompany,
                                                    globalNewNames[globalCurrentPolicyIndex],
                                                    policyAmount,
                                                    snapshot.data[1]['total-amount-approved']+1,
                                                  );
                                                  print('2');
                                                }
                                                else{
                                                  int vehicleIndex = 0;

                                                  while(vehicleIndex < globalVehiclesRequested[globalCurrentPolicyIndex].length){
                                                    await dataBaseService.updateApprovalsNewVehicles(
                                                      globalVehiclesRequested[globalCurrentPolicyIndex].length,
                                                      vehicleIndex,
                                                      signInAsBroker?currentBrokerCompany:'none',
                                                      globalVehiclesRequested[globalCurrentPolicyIndex][vehicleIndex].vehicleMake,
                                                      globalVehiclesRequested[globalCurrentPolicyIndex][vehicleIndex].vehicleModel,
                                                      globalVehiclesRequested[globalCurrentPolicyIndex][vehicleIndex].currentIndex,
                                                      currentInsuranceCompany,
                                                      globalNewNames[globalCurrentPolicyIndex],
                                                      policyAmount,
                                                      snapshot.data[1]['total-amount-approved']+1,
                                                    );
                                                    vehicleIndex++;
                                                  }

                                                }


                                                currentPoliciesApproved++;

                                                if(globalVehiclesRequested[globalCurrentPolicyIndex].isEmpty){
                                                  int idx = 0;
                                                  while(idx <= snapshot.data[2]['total-policy-amount']){
                                                    if(globalNewNames[globalCurrentPolicyIndex] == snapshot.data[2]['$idx']['policy-holder-name']
                                                        && currentInsuranceCompany == snapshot.data[2]['$idx']['intended-company']
                                                        && globalPolicyVehicleIndexes[globalCurrentPolicyIndex] == snapshot.data[2]['$idx']['vehicle-index']
                                                    ){
                                                      print("3");

                                                      /* setState(() {
                                                      currentBrokerCompany = snapshot.data[2]['$idx']['broker-name'];
                                                    });*/

                                                      await dataBaseService.requestsDocUpdateWaitingICApprovalToApprovedRequest(idx);

                                                      // (BROKER) for updating pending polocies broker logged in
                                                      /*
                                                    await dataBaseService.updatePendingPoliciesAmount(
                                                      "",//snapshot.data[2]['$idx']['broker-name'],
                                                      snapshot.data[3]['total-pending-policies']+1,
                                                      signInAsBroker,
                                                    );
                                                    */

                                                      print("4");

                                                    }
                                                    idx++;
                                                  }
                                                }
                                                else{
                                                  print("REACHED THIS ELSE STATEMENTSDFSDFDSFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");
                                                  int idx = 0;
                                                  while(idx <= snapshot.data[2]['total-policy-amount']){
                                                    if(globalNewNames[globalCurrentPolicyIndex] == snapshot.data[2]['$idx']['policy-holder-name']
                                                        && snapshot.data[2]['$idx']['vehicle-amount'] == globalVehiclesRequested[globalCurrentPolicyIndex].length){

                                                      print("VEHICLE AMOUNT IS EQUAL AND REACHED");
                                                      bool isPolicy = true;
                                                      int vehicleIdx = 0;
                                                      while(vehicleIdx < globalVehiclesRequested[globalCurrentPolicyIndex].length){
                                                        if(snapshot.data[2]['$idx']['vehicles']['$vehicleIdx']['vehicle-index'] != globalVehiclesRequested[globalCurrentPolicyIndex][vehicleIdx].currentIndex){
                                                          isPolicy = false;
                                                        }
                                                        vehicleIdx++;
                                                      }

                                                      if(isPolicy){
                                                        if(currentInsuranceCompany == snapshot.data[2]['$idx']['intended-company']){
                                                          print("REACHED REQUESTS DOC FINALLLLLLLLLLLLLLLLLLLLLLLLL");

                                                          setState(() {
                                                            currentBrokerCompany = snapshot.data[2]['$idx']['broker-name'];
                                                          });

                                                          await dataBaseService.requestsDocUpdateWaitingICApprovalToApprovedRequest(idx);
                                                          //await dataBaseService.updatingAmount(idx, policyAmount);
                                                          await dataBaseService.updatePendingPoliciesAmount(
                                                            snapshot.data[2]['$idx']['broker-name'],
                                                            snapshot.data[3]['total-pending-policies']+1,
                                                            signInAsBroker,
                                                          );
                                                        }
                                                      }
                                                    }
                                                    idx++;
                                                  }
                                                }

                                                currentTab = "Policies";
                                                Navigator.pushNamed(context, '/policies-page');


                                              },
                                              child: const Text("Approve Policy Request",style: TextStyle(
                                                color: Colors.white,
                                              ),),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                    return const Text("");
                                  },
                                ),
                                SizedBox(height: 30,),
                                FutureBuilder(
                                  future: insuranceCompaniesSignedUp(),
                                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                    if(snapshot.connectionState == ConnectionState.done){
                                      if(snapshot.hasError){
                                        return const Text("There is an error");
                                      }
                                      else if(snapshot.hasData){
                                        if(snapshot.data['$globalCurrentCompanyIndex']['users']['$globalSignedInUserIndex']['completion-editable'] == false){
                                          return Container();
                                        }
                                        else{
                                          return Container(
                                            width: 250,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: mainColor,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: TextButton(
                                              onPressed: (){

                                              },
                                              child: const Text("Decline Policy Request", style: TextStyle(
                                                color: Colors.white,
                                              ),),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                    return const Text("Please wait");
                                  },

                                ),
                              ],
                            ),
                          );
                        }
                        else{
                          return Container();
                        }

                    }
                  }
                  return const Text("");
                },

              ),

              FutureBuilder(
                future: currentPolicyRequest(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasError){
                      return const Text("There is an error");
                    }
                    else if(snapshot.hasData){
                      return Positioned(
                        top: 500,
                        left: 100,
                        child: Container(
                          width: 400,
                          height: 200,
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 50,
                              child: TextButton(
                                onPressed: (){
                                  Navigator.pushNamed(context, '/attachments');
                                },
                                child: Text("View Attachments"),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return const Text("Please wait");
                },

              ),


            ],
          ),
        ),
      ),
    );
  }



  Widget buildTiming(int idx){
    return Container(
      width: 130,
      height: 100,
      margin: EdgeInsets.only(left: 20, top: 10),
      decoration: BoxDecoration(
        color: idx == currentTime?Colors.blue:Color(0xffEEEEEE),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(right: 2, left:5),
            child: Icon(
              Icons.access_time,
              color: Colors.black,
              size: 18,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 2, right:5),
            child: Text("${timings[idx]}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVehicleExtraInfo(){

    if(globalVehiclesRequested[globalCurrentPolicyIndex].length == 0){
      if(globalVehicleTypes[globalCurrentPolicyIndex] == 'truck'){
        return Text("Vehicle Weight: ${globalVehicleWeights[globalCurrentPolicyIndex]}", style: TextStyle(
          fontSize: 15,),);
      }
      else if(globalVehicleTypes[globalCurrentPolicyIndex] == 'bus'){
        return Text("Number of seats: ${globalNumberOfSeats[globalCurrentPolicyIndex]}", style: TextStyle(
          fontSize: 15,),);
      }
      else{
        return Container();
      }
    }
    else{
      return Container();
    }

  }


  Widget buildVehicleInfo(){
    if(globalVehiclesRequested[globalCurrentPolicyIndex].length == 0){
      return Positioned(
        top: 300,
        left: 50,
        child: Container(
          width: 400,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          child:  Stack(
            children: [
              Positioned(
                top: 5,
                left: 110,
                child: Text("Vehicle Information", style: TextStyle(
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),),
              ),
              Positioned(
                top: 50,
                left: 10,
                child: Text("Vehicle Make: ${globalPolicyVehicleMakes[globalCurrentPolicyIndex]} ", style: TextStyle(
                  fontSize: 15,
                  // fontWeight: FontWeight.bold,
                ),),
              ),
              Positioned(
                top: 80,
                left: 10,
                child: Text("Vehicle Model: ${globalPolicyVehicleModels[globalCurrentPolicyIndex]}", style: TextStyle(
                  fontSize: 15,
                  // fontWeight: FontWeight.bold,
                ),),
              ),
              Positioned(
                top: 110,
                left: 10,
                child: Text("Production Year: ${globalPolicyProductionYears[globalCurrentPolicyIndex]}", style: TextStyle(
                  fontSize: 15,
                  // fontWeight: FontWeight.bold,
                ),),
              ),
              Positioned(
                top: 140,
                left: 10,
                child: Text("Plate Number: ${globalPolicyPlateNumbers[globalCurrentPolicyIndex]}", style: TextStyle(
                  fontSize: 15,
                  // fontWeight: FontWeight.bold,
                ),),
              ),
              Positioned(
                top: 170,
                left: 10,
                child: buildVehicleExtraInfo(),
              ),
            ],
          ),
        ),
      );
    }
    else{
      return Positioned(
        top: 300,
        left: 50,
        child: Container(
          width: 400,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          child:  Stack(
            children: [
              Positioned(
                top: 5,
                left: 110,
                child: Text("Vehicle Information", style: TextStyle(
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),),
              ),
              Positioned(
                top: 100,
                left: 120,
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: (){
                      Navigator.pushNamed(context, '/vehiclesRequested');
                    },
                    child: Text("View Vehicles", style: TextStyle(
                      color: Colors.white,
                      // fontWeight: FontWeight.bold,
                    ),),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

}
