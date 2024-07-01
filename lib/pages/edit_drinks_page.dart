import 'package:flutter/material.dart';
import 'package:white_label_business_app/components/my_button.dart';
import 'package:white_label_business_app/components/my_numberfield.dart';
import 'package:white_label_business_app/components/my_textfield.dart';
import 'package:white_label_business_app/services/database/drink.dart';
import 'package:white_label_business_app/services/database/firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditDrinkPage extends StatefulWidget {
  final Drink drink;
  final ScrollController scrollController;

  const EditDrinkPage(
      {Key? key, required this.drink, required this.scrollController})
      : super(key: key);

  @override
  _EditDrinkPageState createState() => _EditDrinkPageState();
}

class _EditDrinkPageState extends State<EditDrinkPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.drink.name;
    _priceController.text = widget.drink.price.toString();
    _ingredientsController.text = widget.drink.ingredients.join(', ');
    _quantityController.text = widget.drink.quantity.toString();
    _categoryController.text = widget.drink.category;
  }

  Future<void> _pickImage() async {
    FocusScope.of(context).unfocus();
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
          .child('drinks/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageReference.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _updateDrink() async {
    String imageUrl = widget.drink.imageUrl;
    if (_image != null) {
      String? newImageUrl = await _uploadImage(_image!);
      if (newImageUrl != null) {
        imageUrl = newImageUrl;
      }
    }

    String name = _nameController.text;
    String category = _categoryController.text;
    double price = double.parse(_priceController.text);
    List<String> ingredients =
        _ingredientsController.text.split(',').map((e) => e.trim()).toList();
    int quantity = int.parse(_quantityController.text);

    Drink updatedDrink = Drink(
      id: widget.drink.id,
      name: name,
      category: category,
      price: price,
      imageUrl: imageUrl,
      ingredients: ingredients,
      quantity: quantity,
    );

    await _firestoreService.updateDrink(updatedDrink);

    Navigator.of(context).pop();
  }

  void _deleteDrink() async {
    await _firestoreService.deleteDrink(widget.drink.id);
    Navigator.of(context).pop();
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose a new photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove photo'),
                onTap: () {
                  setState(() {
                    _image = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              children: [
                MyTextField(
                  controller: _categoryController,
                  hintText: 'Category',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _nameController,
                  hintText: 'Name',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyNumberTextField(
                  controller: _priceController,
                  hintText: 'Price',
                  isInteger: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _ingredientsController,
                  hintText: 'Ingredients (comma separated)',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyNumberTextField(
                  controller: _quantityController,
                  hintText: 'Quantity',
                  isInteger: true,
                ),
                const SizedBox(height: 20),
                if (_image == null && widget.drink.imageUrl.isNotEmpty)
                  GestureDetector(
                    onTap: _showImageOptions,
                    child: Image.network(
                      widget.drink.imageUrl,
                      fit: BoxFit.contain,
                      height: maxHeight *
                          0.3, // Adjust height to fit within the modal
                    ),
                  )
                else if (_image != null)
                  GestureDetector(
                    onTap: _showImageOptions,
                    child: Image.file(
                      _image!,
                      fit: BoxFit.contain,
                      height: maxHeight *
                          0.3, // Adjust height to fit within the modal
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick an Image'),
                  ),
                const SizedBox(height: 20),
                MyButton(
                  text: 'Update Drink',
                  onTap: _updateDrink,
                ),
                const SizedBox(height: 10),
                MyButton(
                  text: 'Delete Drink',
                  onTap: _deleteDrink,
                  color: Colors.red,
                ),
                const SizedBox(height: 10),
                MyButton(
                  text: 'Cancel',
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  outlined: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
