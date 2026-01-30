import 'package:flutter/material.dart';
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
                child: Stack(
                  children: [
                    CircleAvatar(radius: 40, child: Image.asset('')),
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
                ),
              ),
              SizedBox(height: 20),

              Obx(
                () => Center(
                  child: Text(
                    ac.userData.value['name'] ?? "-",
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
              Card(
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
                        ),
                      ),
                      //specialities
                      SizedBox(height: 12),
                      Text(
                        "Specialities",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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
                                        ac.editSpecialityController.text.trim(),
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                        ),
                      ),
                    ],
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
              Card(
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
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone_android_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
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
                        ),
                      ),
                      SizedBox(height: 15),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
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
                                  child: Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Get.back();
                                    await ac
                                        .updateProfile(); //calls controller update db
                                  },
                                  child: Text('Save Changes'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text('Edit Profile'),
                      ),
                    ],
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
              children: [Text('Open From'), Text('Until')],
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Expanded(child: timeBox("09:00 AM")),
                const SizedBox(width: 12),
                Expanded(child: timeBox("06:00 PM")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget timeBox(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(time, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }
}
