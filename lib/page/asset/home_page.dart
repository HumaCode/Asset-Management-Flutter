import 'dart:convert';

import 'package:course_asset_management/config/api_url.dart';
import 'package:course_asset_management/config/app_constant.dart';
import 'package:course_asset_management/models/asset_model.dart';
import 'package:course_asset_management/page/asset/create_asset_page.dart';
import 'package:course_asset_management/page/asset/search_asset_page.dart';
import 'package:course_asset_management/page/asset/update_asset_page.dart';
import 'package:course_asset_management/page/user/login_page.dart';
import 'package:d_info/d_info.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AssetModel> assets = [];

  // function membaca data
  readAssets() async {
    assets.clear();
    setState(() {}); // update tampilan yang lama / dihapus

    try {
      Uri url = Uri.parse(readurl);

      final response = await http.get(url);

      DMethod.printResponse(response);
      Map resBody = jsonDecode(response.body);
      bool success = resBody['success'] ?? false;
      if (success) {
        List data = resBody['data'];
        assets = data.map((e) => AssetModel.fromJson(e)).toList();
      }
      setState(() {});
    } catch (e) {
      DMethod.printTitle('catch', e.toString());
    }
  }

  // menu item
  showMenuItem(AssetModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(item.name),
          children: [
            ListTile(
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateAssetPage(oldAsset: item),
                  ),
                ).then((value) => readAssets());
              },
              horizontalTitleGap: 0,
              leading: const Icon(
                Icons.edit,
                color: Colors.blue,
              ),
              title: const Text('Ubah'),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);

                deleteAsset(item);
              },
              horizontalTitleGap: 0,
              leading: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: const Text('Hapus'),
            )
          ],
        );
      },
    );
  }

  // function delete
  deleteAsset(AssetModel item) async {
    bool? yes = await DInfo.dialogConfirmation(
      context,
      'Hapus Data',
      'Kamu yakin akan menghapus data "${item.name}"..?',
      textNo: 'Batal',
      textYes: 'Ya, Hapus',
    );

    // jika true
    if (yes ?? false) {
      // eksekusi ddengan api
      try {
        Uri url = Uri.parse(deleteurl);

        final response = await http.post(url, body: {
          'id': item.id,
          'image': item.image,
        });

        DMethod.printResponse(response);
        Map resBody = jsonDecode(response.body);
        bool success = resBody['success'] ?? false;
        if (success) {
          DInfo.toastSuccess('Berhasil menghapus data');

          // refresh halaman dengan data terbaru
          readAssets();
        } else {
          DInfo.toastError('Gagal menghapus data');
        }
      } catch (e) {
        DMethod.printTitle('catch', e.toString());
      }
    }
  }

  @override
  void initState() {
    readAssets();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton(
          icon: const Icon(Icons.logout),
          onSelected: (value) {
            if (value == 'keluar') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'keluar',
              child: Text('Keluar'),
            ),
          ],
        ),
        title: const Text(AppConstant.appName),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchAssetPage(),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),

      body: assets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum ada data ',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () => readAssets(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => readAssets(),
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: assets.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  AssetModel item = assets[index];

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              // ignore: prefer_interpolation_to_compose_strings
                              '$imageurl/' + item.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.type,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // tombol
                            Material(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.purple[50],
                              child: InkWell(
                                splashColor: Colors.purpleAccent,
                                onTap: () {
                                  showMenuItem(item);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Icon(Icons.more_vert),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

      // floating button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAssetPage(),
            ),
          ).then((value) => readAssets());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
