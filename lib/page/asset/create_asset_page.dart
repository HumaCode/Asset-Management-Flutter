import 'dart:convert';
import 'dart:typed_data';
import 'package:course_asset_management/config/api_url.dart';
import 'package:http/http.dart' as http;
import 'package:d_info/d_info.dart';
import 'package:d_input/d_input.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateAssetPage extends StatefulWidget {
  const CreateAssetPage({super.key});

  @override
  State<CreateAssetPage> createState() => _CreateAssetPageState();
}

class _CreateAssetPageState extends State<CreateAssetPage> {
  final formkey = GlobalKey<FormState>();
  final edtName = TextEditingController();

  List<String> types = [
    'Pakaian',
    'Kendaraan',
    'Elektronik',
    'Tempat',
    'Rumah',
    'Apartemen',
    'Properti',
    'Lainya',
  ];

  String type = 'Pakaian';

  String? imageName;
  Uint8List? imageByte;

  // fungsi ambil gambar
  pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);

    if (picked != null) {
      imageName = picked.name;
      imageByte = await picked.readAsBytes();
      setState(() {});
    }
    DMethod.printBasic('imageName : $imageName');
  }

  // fungsi save data
  save() async {
    bool isValidInput = formkey.currentState!.validate();

    if (!isValidInput) return;

    if (imageByte == null) {
      DInfo.toastError('Gambar harus diisi..!!');
      return;
    }

    // eksekusi ddengan api
    try {
      Uri url = Uri.parse(createurl);

      final response = await http.post(url, body: {
        'name': edtName.text,
        'type': type,
        'image': imageName,
        'base64code': base64Encode(imageByte as List<int>),
      });

      DMethod.printResponse(response);
      Map resBody = jsonDecode(response.body);
      bool success = resBody['success'] ?? false;
      if (success) {
        DInfo.toastSuccess('Berhasil menambahkan asset baru');

        Navigator.pop(context);
      } else {
        DInfo.toastError('Gagal menambahkan asset');
      }
    } catch (e) {
      DMethod.printTitle('catch', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah'),
        centerTitle: true,
      ),
      body: Form(
        key: formkey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DInput(
              controller: edtName,
              title: 'Nama Barang',
              hint: 'Motor',
              fillColor: Colors.white,
              validator: (input) =>
                  input == '' ? "Nama barang tidak boleh kosong" : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tipe',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField(
              value: type,
              icon: const Icon(Icons.keyboard_arrow_down),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: types.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  type = value;
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Gambar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: imageByte == null
                    ? const Text('Kosong')
                    : Image.memory(imageByte!),
              ),
            ),
            ButtonBar(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    pickImage(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    pickImage(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Galeri'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => save(),
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}
