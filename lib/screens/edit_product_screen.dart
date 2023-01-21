import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _desFocusNode = FocusNode();
  final _imgUrlFocusNode = FocusNode();
  final _imgUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _isLoading = false;

  var _editedProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');
  bool _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _desFocusNode.dispose();
    _imgUrlController.dispose();
    _imgUrlFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _isInit = true;
    _imgUrlController.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      var prodId = ModalRoute.of(context).settings.arguments as String;

      if (prodId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(prodId);

        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };

        _imgUrlController.text = _editedProduct.imageUrl;
      }
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        label: Text('Title'),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please provide a title';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: val,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      focusNode: _priceFocusNode,
                      decoration: InputDecoration(
                        label: Text('Price'),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val.isEmpty) {
                          return "Please enter a price.";
                        }
                        if (double.tryParse(val) == null) {
                          return 'Please enter a valid number!';
                        }

                        if (double.parse(val) <= 0) {
                          return 'Please enter a number greater than 0!';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_desFocusNode);
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(val),
                            isFavorite: _editedProduct.isFavorite,
                            imageUrl: _editedProduct.imageUrl);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      focusNode: _desFocusNode,
                      maxLines: 3,
                      decoration: InputDecoration(
                        label: Text('Description'),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      validator: (val) {
                        if (val.isEmpty) {
                          return "Please enter a description.";
                        }

                        if (val.length < 10) {
                          return 'Should be at least 10 characters long!';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: val,
                            price: _editedProduct.price,
                            isFavorite: _editedProduct.isFavorite,
                            imageUrl: _editedProduct.imageUrl);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imgUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imgUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imgUrlController,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (val) {
                              if (val.isEmpty) {
                                return "Please enter an image Url.";
                              }

                              if (!val.startsWith('http') &&
                                  !val.startsWith('https')) {
                                return 'Please enter a valid Url';
                              }

                              if (!val.endsWith('.png') &&
                                  !val.endsWith('.jpg') &&
                                  !val.endsWith('.jpeg')) {
                                return "Please enter a valid image format";
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  isFavorite: _editedProduct.isFavorite,
                                  price: _editedProduct.price,
                                  imageUrl: val);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void _updateImageUrl() {
    if (!_imgUrlFocusNode.hasFocus) {
      if ((_imgUrlController.text.isEmpty) ||
          !_imgUrlController.text.startsWith('http') ||
          !_imgUrlController.text.startsWith('https') ||
          (!_imgUrlController.text.endsWith('.png') ||
              !_imgUrlController.text.endsWith('.jpg') ||
              !_imgUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    bool isvalid = _form.currentState.validate();

    if (!isvalid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        showDialog<Null>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('An error occurred! '),
              content: Text('Something went wrong!'),
              actions: <Widget>[
                TextButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                  },
                ),
              ],
            );
          },
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.pop(context);
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
    // Navigator.pop(context);
  }
}
