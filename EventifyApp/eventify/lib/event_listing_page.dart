import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

//UI to be improved in the future, and also instead of using image url, might change to using image from gallery or camera
//Image from galley implemented, need improve UI next

class EventListingPage extends StatefulWidget {
  const EventListingPage({super.key});

  @override
  _EventListingPageState createState() => _EventListingPageState();
}

class _EventListingPageState extends State<EventListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  //final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  File? _image;

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  //Allow users to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  //Allow users to use image from camera
  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  
  //Upload image to firebase storage and get the download URL
  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imagesRef =
        storageRef.child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = imagesRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _addEvent() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        final imageUrl = await _uploadImage(_image!);
        await FirebaseFirestore.instance.collection('events').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          //'time': _timeController.text,
          'startDate': _startDate,
          'endDate': _endDate,
          'startTime': _startTime!.format(context),
          'endTime': _endTime!.format(context),
          'location': _locationController.text,
          'price': _priceController.text,
          'thumbnailUrl': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Event added successfully')));
        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _startDate = null;
          _endDate = null;
          _startTime = null;
          _endTime = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add event: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all fields and pick an image')));
    }
  }

  //Allow users to select Date using a calendar widget
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Event added successfully!'),
//       ));
//       _formKey.currentState!.reset();
  //Allow users to select timing using a clock widget
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != (isStartTime ? _startTime : _endTime)) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Listing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(labelText: 'Title'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a title';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(labelText: 'Description'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a description';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _timeController,
//                 decoration: const InputDecoration(labelText: 'Time'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a time';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _thumbnailUrlController,
//                 decoration: const InputDecoration(labelText: 'Thumbnail URL'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a thumbnail URL';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _locationController,
//                 decoration: const InputDecoration(labelText: 'Location'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a location';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _priceController,
//                 decoration: const InputDecoration(labelText: 'Price'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a price';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150,
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      expands: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                            'Start Date: ${_startDate != null ? DateFormat.yMd().format(_startDate!) : 'Select Date'}'),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, true),
                      ),
                      ListTile(
                        title: Text(
                            'End Date: ${_endDate != null ? DateFormat.yMd().format(_endDate!) : 'Select Date'}'),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, false),
                      ),
                      ListTile(
                        title: Text(
                            'Start Time: ${_startTime != null ? _startTime!.format(context) : 'Select Time'}'),
                        trailing: Icon(Icons.access_time),
                        onTap: () => _selectTime(context, true),
                      ),
                      ListTile(
                        title: Text(
                            'End Time: ${_endTime != null ? _endTime!.format(context) : 'Select Time'}'),
                        trailing: Icon(Icons.access_time),
                        onTap: () => _selectTime(context, false),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 16,
              ),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      prefix: Text('\$',
                      style: TextStyle(
                        color: Color.fromARGB(190, 0, 0, 0),
                      ),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              _image == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(Icons.photo),
                          label: Text('Pick from Gallery'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickImageFromCamera,
                          icon: Icon(Icons.camera_alt),
                          label: Text('Camera'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        //Allow users to remove pictures and set image state back to null
                        Image.file(_image!),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _image = null;
                            });
                          },
                          icon: Icon(Icons.remove_circle),
                          label: Text('Remove Image'),
                        ),
                      ],
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addEvent,
                child: const Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
