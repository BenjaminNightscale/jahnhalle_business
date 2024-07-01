import 'package:flutter/material.dart';
import 'package:white_label_business_app/components/laoding_dialog.dart';
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

  const EditDrinkPage({Key? key, required this.drink}) : super(key: key);

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

  List<String> _categories = [];
  List<String> _filteredCategories = [];
  final FocusNode _categoryFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.drink.name;
    _priceController.text = widget.drink.price.toString();
    _ingredientsController.text = widget.drink.ingredients.join(', ');
    _quantityController.text = widget.drink.quantity.toString();
    _categoryController.text = widget.drink.category;

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
    RenderBox? textFieldRenderBox =
        _categoryFocusNode.context?.findRenderObject() as RenderBox?;
    var textFieldSize = textFieldRenderBox?.size ?? Size.zero;
    var textFieldOffset =
        textFieldRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 0.0),
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

  bool _validateFields() {
    bool isValid = true;

    if (_nameController.text.isEmpty) {
      isValid = false;
    }
    if (_priceController.text.isEmpty) {
      isValid = false;
    }
    if (_ingredientsController.text.isEmpty) {
      isValid = false;
    }
    if (_quantityController.text.isEmpty) {
      isValid = false;
    }
    if (_categoryController.text.isEmpty) {
      isValid = false;
    }

    setState(() {});

    return isValid;
  }

  void _showLoadingDialog({bool isSuccess = false, bool isError = false, String message = 'Updating...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(message: message, isSuccess: isSuccess, isError: isError);
      },
    );
  }

  void _updateDrink() async {
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    _showLoadingDialog();

    String imageUrl = widget.drink.imageUrl;
    if (_image != null) {
      String? newImageUrl = await _uploadImage(_image!);
      if (newImageUrl == null) {
        Navigator.of(context).pop(); // Close the loading dialog
        _showLoadingDialog(isError: true, message: 'Image upload failed');
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // Close the error dialog
        });
        return;
      } else {
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

    try {
      await _firestoreService.updateDrink(updatedDrink);
      Navigator.of(context).pop(); // Close the loading dialog

      // Show success dialog
      _showLoadingDialog(isSuccess: true, message: 'Successfully Updated!');

      // Wait for 2 seconds and then close the success dialog
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close the success dialog
        Navigator.of(context).pop(); // Go back to the previous screen
      });
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading dialog
      _showLoadingDialog(isError: true, message: 'Update failed');
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close the error dialog
      });
    }
  }

  void _deleteDrink() async {
    try {
      await _firestoreService.deleteDrink(widget.drink.id);
      Navigator.of(context).pop();
    } catch (e) {
      _showLoadingDialog(isError: true, message: 'Delete failed');
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close the error dialog
      });
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
                GestureDetector(
                  onTap: _showImageOptions,
                  child: _image != null
                      ? Image.file(
                          _image!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 200,
                        )
                      : widget.drink.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.drink.imageUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: 200,
                            )
                          : GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 200,
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
                            ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
