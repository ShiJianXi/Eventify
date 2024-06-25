
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }


  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imagesRef = storageRef.child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
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
          'time': _timeController.text,
          'location': _locationController.text,
          'price': _priceController.text,
          'thumbnailUrl': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event added successfully')));
        _formKey.currentState!.reset();
        setState(() {
          _image = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add event: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields and pick an image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Listing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(labelText: 'Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _image == null ? TextButton(
                onPressed: _pickImage,
                child: Text('Pick Image from Gallery'),
                )
                : Image.file(_image!),

              ElevatedButton(
                onPressed: _addEvent,
                child: Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

