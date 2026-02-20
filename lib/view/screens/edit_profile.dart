import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/view/auth_screens/register.dart';

class EditProfile extends StatelessWidget {
  EditProfile({super.key});

  final AuthController ac = Get.put(AuthController());
  final Color primaryRed = Colors.red.shade400;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Obx(() {
                  final imageUrl = ac.userData['profileImage'];

                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.lightBlue[200],
                        backgroundImage:
                            (imageUrl != null && imageUrl.toString().isNotEmpty)
                            ? NetworkImage(imageUrl)
                            : null,
                        child: (imageUrl == null || imageUrl.toString().isEmpty)
                            ? Icon(Icons.person, size: 40, color: Colors.black)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.camera_alt_outlined),
                            iconSize: 20,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(height: 20),

              Obx(
                () => Center(
                  child: Text(
                    ac.userData.value['kitchenName'] ?? "-",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),

              Obx(
                () => Center(
                  child: Text(
                    ac.userData.value['ownerName'] ?? "-",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, color: Colors.green, size: 14),
                  SizedBox(width: 6),
                  Text('Active Kitchen Partner'),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 6),
                  Text(
                    'Personal Info',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(25),
                      blurRadius: 5,
                      spreadRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Full Name'),
                        SizedBox(height: 6),
                        TextField(
                          controller: ac.editFullNameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text('Kitchen Name (Display Name)'),
                        SizedBox(height: 6),
                        TextField(
                          controller: ac.editKitchenNameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text('About Your Cooking'),
                        SizedBox(height: 6),
                        TextField(
                          controller: ac.editAboutCooking,
                          maxLines: 4, //max we can add 4 lines here
                          decoration: InputDecoration(
                            hintText:
                                "Tell customers a little bit about what makes your food special.......",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        //cuisine
                        SizedBox(height: 5),
                        Text("Set Cuisine"),
                        SizedBox(height: 6),
                        TextField(
                          controller: ac.editCuisineController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        //specialities
                        SizedBox(height: 12),
                        Text(
                          "Specialities",
                          // style: TextStyle(
                          //   fontSize: 15,
                          //   fontWeight: FontWeight.w600,
                          // ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Input field for adding specialities
                              Row(
                                children: [
                                  Expanded(
                                    child: textField(
                                      hint: "Add a speciality",
                                      icon: Icons.folder_special,
                                      controller: ac.editSpecialityController,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      if (ac.editSpecialityController.text
                                          .trim()
                                          .isNotEmpty) {
                                        ac.editSpecialitiesList.add(
                                          ac.editSpecialityController.text
                                              .trim(),
                                        );
                                        ac.editSpecialityController.clear();
                                      }
                                    },
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primaryRed,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Display added specialities as chips
                              Obx(
                                () => ac.editSpecialitiesList.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          "No specialities added yet",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      )
                                    : Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: ac.editSpecialitiesList.map((
                                          speciality,
                                        ) {
                                          return Chip(
                                            label: Text(speciality),
                                            deleteIcon: const Icon(
                                              Icons.close,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            onDeleted: () {
                                              ac.editSpecialitiesList.remove(
                                                speciality,
                                              );
                                            },
                                            backgroundColor: primaryRed,
                                            labelStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),

                        //pan card
                        SizedBox(height: 6),
                        Text("Pan Number"),
                        SizedBox(height: 6),
                        TextField(
                          controller: ac.editPanController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.call),
                  SizedBox(width: 6),
                  Text(
                    'Contact Details',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(25),
                      blurRadius: 5,
                      spreadRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //for phone number
                        Text('Phone Number'),
                        SizedBox(height: 6),
                        TextField(
                          controller: ac.editPhoneNumberController,
                          keyboardType: TextInputType.number,
                          // maxLength: 10,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                              10,
                            ), // Limits input to 10 characters
                          ],
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone_iphone_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        // for thr address
                        SizedBox(height: 6),
                        Text('Kitchen Address'),
                        SizedBox(height: 6),
                        TextField(
                          controller: ac.editKitchenAddressController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Agartala Tripura",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        //this for email
                        SizedBox(height: 6),
                        Text('Email'),
                        SizedBox(height: 6),
                        TextField(
                          controller: ac.editEmailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.event_available_sharp),
                  SizedBox(width: 6),
                  Text(
                    'Availability',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // const Text("Accepting Orders"),
                          // Switch(
                          //   value: isAvailable,
                          //   activeThumbColor: Colors.green,
                          //   onChanged: (value) {
                          //     setState(() {
                          //       isAvailable = value;
                          //     });
                          //   },
                          // ),
                        ],
                      ),
                      Align(
                        alignment: AlignmentGeometry.bottomLeft,
                        child: Text('Standard Operating Hours'),
                      ),
                      SizedBox(height: 8),

                      AvailabilitySection(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Text('Update Profile?'),
                          content: Text('Do you want to save the changes?'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Get.back();
                                await ac
                                    .updateProfile(); //calls controller update db
                              },
                              child: Text(
                                'Save Changes',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('Update Profile'),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class AvailabilitySection extends StatelessWidget {
  AvailabilitySection({super.key});
  final AuthController ac = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Accepting Orders",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: ac.isAcceptingOrders.value,
                  onChanged: (value) {
                    ac.isAcceptingOrders.value = value;
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [Text('Open Time'), Text('Close Time')],
            ),
            SizedBox(height: 8),

            Row(
              children: [
                timePickerButton(
                  label: "Open Time",
                  selectedTime: ac.editOpenTime,
                ),
                const SizedBox(width: 12),
                timePickerButton(
                  label: "Close Time",
                  selectedTime: ac.editCloseTime,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget timeBox(String time) {
    return Obx(
      () => GestureDetector(
        onTap: () async {
          // Determine if this is open or close time based on the time value
          final isOpenTime =
              ac.editOpenTime.value != null &&
              time == ac.timeToString(ac.editOpenTime.value!);

          final TimeOfDay? picked = await showTimePicker(
            context: Get.context!,
            initialTime: isOpenTime
                ? (ac.editOpenTime.value ?? TimeOfDay.now())
                : (ac.editCloseTime.value ?? TimeOfDay.now()),
          );

          if (picked != null) {
            if (isOpenTime) {
              ac.editOpenTime.value = picked;
            } else {
              ac.editCloseTime.value = picked;
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Center(
            child: Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

class timePickerButton extends StatelessWidget {
  final String label;
  final Rx<TimeOfDay?> selectedTime;
  final AuthController ac = Get.put(AuthController());

  timePickerButton({
    super.key,
    required this.label,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(
        () => GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: selectedTime.value ?? TimeOfDay.now(),
            );
            if (picked != null) {
              selectedTime.value = picked;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selectedTime.value != null
                  ? Colors.grey.shade100
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedTime.value != null
                    ? Colors.red.shade400
                    : Colors.grey.shade300,
                width: selectedTime.value != null ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                selectedTime.value != null
                    ? ac.timeToString(selectedTime.value!)
                    : label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: selectedTime.value != null
                      ? Colors.black
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
