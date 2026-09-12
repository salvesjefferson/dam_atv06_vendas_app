import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:vendas_app/src/models/product_model.dart';
import 'package:vendas_app/src/features/product/product_viewmodel.dart';
import 'package:vendas_app/src/features/category/category_viewmodel.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});

  final ProductModel? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  //final _imageUrlController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String? _imagePath;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;
    if (product != null) {
      _nameController.text = product.name;
      _priceController.text = product.price.toStringAsFixed(2);
      _selectedCategory = product.category;
      //_imageUrlController.text = product.imageUrl;
      _imagePath = product.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    //_imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(
      source: source,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _imagePath = image.path;
    });
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }  

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final categoryViewModel = context.read<CategoryViewModel>();
      final categories = categoryViewModel.categories;

      final category = _selectedCategory ??
          (categories.isNotEmpty ? categories.first.name : 'Geral');

      final productViewModel = context.read<ProductViewModel>();

      final name = _nameController.text.trim();

      final price = double.parse(
        _priceController.text.trim().replaceFirst(',', '.'),
      );

      if (_isEditing) {
        final imagePath = await _saveImage(
          widget.product!.id,
        );

        await productViewModel.updateProduct(
          widget.product!.copyWith(
            name: name,
            price: price,
            category: category,
            imagePath: imagePath,
          ),
        );
      } else {
        final product = ProductModel(
          name: name,
          price: price,
          category: category,
          imageUrl: '',
        );

        final imagePath = await _saveImage(
          product.id,
        );

        await productViewModel.addProduct(
          product.copyWith(
            imagePath: imagePath,
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Produto atualizado com sucesso!'
                  : 'Produto cadastrado com sucesso!',
            ),
          ),
        );
      }
    }
  }

  Future<String?> _saveImage(String productId) async {
    if (_imagePath == null) {
      return null;
    }

    final sourceFile = File(_imagePath!);

    if (!await sourceFile.exists()) {
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();

    final extension = p.extension(sourceFile.path);

    final destinationPath = p.join(
      directory.path,
      '$productId$extension',
    );

    // Se a imagem já estiver salva nesse local, não precisa copiá-la novamente.
    if (sourceFile.path == destinationPath) {
      return destinationPath;
    }

    final savedFile = await sourceFile.copy(destinationPath);

    return savedFile.path;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Produto' : 'Novo Produto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Produto *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Insira o nome do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço *',
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Insira o preço';
                  }
                  if (double.tryParse(value.replaceFirst(',', '.')) == null) {
                    return 'Preço inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Consumer<CategoryViewModel>(
                builder: (context, categoryViewModel, child) {
                  final categories = categoryViewModel.categories;
                  final currentSelected = categories.any((c) => c.name == _selectedCategory)
                      ? _selectedCategory
                      : (categories.isNotEmpty ? categories.first.name : null);

                  return DropdownButtonFormField<String>(
                    initialValue: currentSelected,
                    decoration: const InputDecoration(labelText: 'Categoria *'),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.name,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Selecione uma categoria';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              //para adicionar area clicável
              InkWell(
                onTap: _showImageSourceOptions,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imagePath!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text('Adicionar foto'),
                            SizedBox(height: 4),
                            Text(
                              'Opcional',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
