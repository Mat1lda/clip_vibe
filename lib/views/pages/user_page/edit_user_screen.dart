import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/colors.dart';
import '../../../databases/services/user_service.dart';
import '../../../provider/gender_model.dart';
import '../../widgets/custom_basic_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/text_form_field.dart';

class EditUserInfoScreen extends StatelessWidget {
  EditUserInfoScreen({Key? key}) : super(key: key);

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final _editUserFormKey = GlobalKey<FormState>();
  late String genderInfo = 'Male';

  doEdit(BuildContext context) {
    bool isValidate = _editUserFormKey.currentState!.validate();
    if (isValidate) {
      UserService.editUserFetch(
          context: context,
          phone: phoneController.text,
          fullName: nameController.text,
          gender: genderInfo,
          age: ageController.text);
    }
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return "Empty Field !";
    } else if (value.length >= 50) {
      return "Your name is so dark !";
    } else {
      return null;
    }
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Empty Field !";
    } else if (value.length != 10) {
      return "Your phone number is wrong !";
    } else {
      return null;
    }
  }

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return "Empty Field !";
    } else if (value.length >= 3) {
      return "Your age is so dark !";
    } else {
      try {
        int age = int.parse(value);
        return null;
      } catch (e) {
        return 'Age Format is wrong';
      }
    }
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Empty Field !";
    } else if (value != ageController.text) {
      return "Your confirmation password does not match !";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _editUserFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Full Name Field
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      errorStyle: const TextStyle(color: Colors.redAccent),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: validateFullName,
                  ),
                  const SizedBox(height: 20),
                  // Phone Number Field
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      errorStyle: const TextStyle(color: Colors.redAccent),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: validatePhone,
                  ),
                  const SizedBox(height: 20),
                  // Age Field
                  TextFormField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      hintText: 'Enter your age',
                      prefixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      errorStyle: const TextStyle(color: Colors.redAccent),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: validateAge,
                  ),
                  const SizedBox(height: 20),
                  // Gender Field
                  const Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Consumer<GenderModel>(
                      builder: (_, genderUser, __) {
                        return DropdownButtonFormField<String>(
                          value: genderUser.gender,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          items: dropdownItems,
                          onChanged: (Object? value) {
                            genderUser.changeMale();
                            genderInfo = context.read<GenderModel>().gender;
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => doEdit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}