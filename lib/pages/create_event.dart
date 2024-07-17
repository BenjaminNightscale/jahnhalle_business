import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:white_label_business_app/components/laoding_dialog.dart';
import 'package:white_label_business_app/components/my_app_bar.dart';
import 'package:white_label_business_app/components/my_button.dart';
import 'package:white_label_business_app/components/my_textfield.dart';
import 'package:white_label_business_app/components/my_numberfield.dart';
import 'package:white_label_business_app/services/database/firestore.dart';
import 'package:white_label_business_app/services/database/event.dart';
import 'package:intl/intl.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _musicGenreController = TextEditingController();
  final TextEditingController _specialsController = TextEditingController();
  final TextEditingController _ticketsController = TextEditingController();
  final TextEditingController _ticketCostController = TextEditingController();
  final TextEditingController _eventDetailsController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();

  bool _validateFields() {
    bool isValid = true;

    if (_nameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _musicGenreController.text.isEmpty ||
        _eventDetailsController.text.isEmpty) {
      isValid = false;
    }

    setState(() {});

    return isValid;
  }

  Future<void> _pickImage() async {
    FocusScope.of(context).unfocus(); // Remove focus from all text fields
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('events/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageReference.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _showLoadingDialog(
      {bool isSuccess = false,
      bool isError = false,
      String message = 'Uploading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(
            message: message, isSuccess: isSuccess, isError: isError);
      },
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${DateFormat('dd/MM/yyyy').format(picked.start)} - ${DateFormat('dd/MM/yyyy').format(picked.end)}';
      });
    }
  }

  Future<void> _selectTime({required TextEditingController controller}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  void _uploadEvent() async {
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all required fields')));
      return;
    }

    _showLoadingDialog();

    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
      if (imageUrl == null) {
        Navigator.of(context).pop(); // Close the loading dialog
        _showLoadingDialog(isError: true, message: 'Image upload failed');
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // Close the error dialog
        });
        return;
      }
    }

    String name = _nameController.text;
    String date = _dateController.text;
    String startTime = _startTimeController.text;
    String endTime = _endTimeController.text.isNotEmpty
        ? _endTimeController.text
        : 'Open End';
    String musicGenre = _musicGenreController.text;
    String? specials =
        _specialsController.text.isNotEmpty ? _specialsController.text : null;
    int? tickets = _ticketsController.text.isNotEmpty
        ? int.tryParse(_ticketsController.text)
        : null;
    double? ticketCost = _ticketCostController.text.isNotEmpty
        ? double.tryParse(_ticketCostController.text)
        : null;
    String eventDetails = _eventDetailsController.text;
    String? instagram =
        _instagramController.text.isNotEmpty ? _instagramController.text : null;
    String? facebook =
        _facebookController.text.isNotEmpty ? _facebookController.text : null;
    String? tiktok =
        _tiktokController.text.isNotEmpty ? _tiktokController.text : null;

    Event newEvent = Event(
      id: '',
      name: name,
      date: date,
      time: '$startTime - $endTime',
      musicGenre: musicGenre,
      specials: specials,
      tickets: tickets,
      ticketCost: ticketCost,
      eventDetails: eventDetails,
      instagram: instagram,
      facebook: facebook,
      tiktok: tiktok,
      imageUrl: imageUrl,
    );

    await _firestoreService.addEvent(newEvent);

    Navigator.of(context).pop(); // Close the loading dialog

    // Show success dialog
    _showLoadingDialog(isSuccess: true, message: 'Successfully Uploaded!');

    // Wait for 2 seconds and then close the success dialog
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close the success dialog
    });

    // Clear the text fields
    _nameController.clear();
    _dateController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _musicGenreController.clear();
    _specialsController.clear();
    _ticketsController.clear();
    _ticketCostController.clear();
    _eventDetailsController.clear();
    _instagramController.clear();
    _facebookController.clear();
    _tiktokController.clear();
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Create Event'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MyTextField(
                      controller: _nameController,
                      hintText: 'Event Name',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: _musicGenreController,
                      hintText: 'Music Genre',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: _eventDetailsController,
                      hintText: 'Event Details',
                      obscureText: false,
                      maxLines: null,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: _dateController,
                      hintText: 'Date (DD/MM/YYYY)',
                      obscureText: false,
                      onTap: _selectDateRange,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: _startTimeController,
                      hintText: 'Start Time (HH:MM)',
                      obscureText: false,
                      onTap: () => _selectTime(controller: _startTimeController),
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: _endTimeController,
                      hintText: 'End Time (HH:MM)',
                      obscureText: false,
                      onTap: () => _selectTime(controller: _endTimeController),
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: _specialsController,
                      hintText: 'Specials (optional)',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyNumberTextField(
                      controller: _ticketsController,
                      hintText: 'Number of Tickets (optional)',
                      isInteger: true,
                    ),
                    const SizedBox(height: 10),
                    MyNumberTextField(
                      controller: _ticketCostController,
                      hintText: 'Ticket Cost (optional)',
                      isInteger: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: _instagramController,
                      hintText: 'Instagram (optional)',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: _facebookController,
                      hintText: 'Facebook (optional)',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: _tiktokController,
                      hintText: 'TikTok (optional)',
                      obscureText: false,
                    ),
                    const SizedBox(height: 20),
                    _image == null
                        ? GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 250,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey[700],
                                  size: 40,
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: _pickImage,
                            child: Image.file(_image!),
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            MyButton(
              text: 'Upload Event',
              onTap: _uploadEvent,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
