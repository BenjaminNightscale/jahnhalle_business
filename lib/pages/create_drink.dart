import 'package:flutter/material.dart';
import 'package:white_label_business_app/components/my_button.dart';
import 'package:white_label_business_app/components/my_numberfield.dart';
import 'package:white_label_business_app/components/my_textfield.dart';
import 'package:white_label_business_app/services/database/drink.dart';
import 'package:white_label_business_app/services/database/firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CreateDrinkPage extends StatefulWidget {
  const CreateDrinkPage({super.key});

  @override
  _CreateDrinkPageState createState() => _CreateDrinkPageState();
}

class _CreateDrinkPageState extends State<CreateDrinkPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  File? _image;
  List<String> _categories = [];
  List<String> _filteredCategories = [];
  final FocusNode _categoryFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _categoryController.addListener(_filterCategories);
    _categoryFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _categoryFocusNode.removeListener(_onFocusChange);
    _categoryController.removeListener(_filterCategories);
    _categoryFocusNode.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _ingredientsController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _loadCategories() async {
    List<String> categories = await _firestoreService.getCategories();
    setState(() {
      _categories = categories;
      _filteredCategories = categories;
    });
  }

  void _filterCategories() {
    setState(() {
      _filteredCategories = _categories
          .where((category) => category
              .toLowerCase()
              .contains(_categoryController.text.toLowerCase()))
          .toList();
    });
    _updateOverlay();
  }

  void _onFocusChange() {
    if (_categoryFocusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox? textFieldRenderBox = _categoryFocusNode.context?.findRenderObject() as RenderBox?;
    var textFieldSize = textFieldRenderBox?.size ?? Size.zero;
    var textFieldOffset = textFieldRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: textFieldOffset.dx,
        top: textFieldOffset.dy + textFieldSize.height + 20,
        width: textFieldSize.width,
        child: Material(
          elevation: 2.0,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: _filteredCategories
                    .map((category) => ListTile(
                          title: Text(category),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                          onTap: () {
                            setState(() {
                              _categoryController.text = category;
                              _filteredCategories.clear();
                              _removeOverlay();
                            });
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    FocusScope.of(context).unfocus(); // Remove focus from all text fields
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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

  void _uploadDrink() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    String? imageUrl = await _uploadImage(_image!);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed')));
      return;
    }

    String name = _nameController.text;
    String category = _categoryController.text;
    double price = double.parse(_priceController.text);
    List<String> ingredients = _ingredientsController.text.split(',').map((e) => e.trim()).toList();
    int quantity = int.parse(_quantityController.text);

    Drink newDrink = Drink(
      id: '',
      name: name,
      category: category,
      price: price,
      imageUrl: imageUrl,
      ingredients: ingredients,
      quantity: quantity,
    );

    await _firestoreService.addDrink(newDrink);

    // Clear the text fields
    _nameController.clear();
    _priceController.clear();
    _ingredientsController.clear();
    _quantityController.clear();
    _categoryController.clear();
    setState(() {
      _image = null;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Drink successfully added!')));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Drink'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyTextField(
                controller: _categoryController,
                hintText: 'Category',
                obscureText: false,
                focusNode: _categoryFocusNode,
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
              _image == null
                  ? ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick an Image'),
                    )
                  : GestureDetector(
                      onTap: _showImageOptions,
                      child: Image.file(_image!),
                    ),
              const SizedBox(height: 20),
              MyButton(
                text: 'Upload Drink',
                onTap: _uploadDrink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
