import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:tugas1/side_menu.dart';
import 'package:tugas1/tambah_data.dart';
import 'package:tugas1/update_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListData extends StatefulWidget {
  const ListData({super.key});
  @override
// ignore: library_private_types_in_public_api
  _ListDataState createState() => _ListDataState();
}

class _ListDataState extends State<ListData> {
  List<Map<String, String>> dataAnggota = [];
  String url = Platform.isAndroid
      ? 'http://10.98.5.192/api_crud/index.php'
      : 'http://localhost/api_crud/index.php';
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  lihatMahasiswa(String nama, String jurusan) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("Nama Anggota : $nama"),
              content: Text("Jurusan Kuliah : $jurusan"));
        });
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        dataAnggota = List<Map<String, String>>.from(data.map((item) {
          return {
            'nama': item['nama'] as String,
            'jurusan': item['jurusan'] as String,
            'id': item['id'] as String,
          };
        }));
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future deleteData(int id) async {
    final response = await http.delete(Uri.parse('$url?id=$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Data Anggota'),
      ),
      drawer: const SideMenu(),
      body: Column(children: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TambahData(url: url),
              ),
            );
          },
          child: const Text('Tambah Data Anggota'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: dataAnggota.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(dataAnggota[index]['nama']!),
                subtitle: Text('Jurusan: ${dataAnggota[index]['jurusan']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.visibility),
                      onPressed: () {
                        lihatMahasiswa(dataAnggota[index]['nama']!,
                            dataAnggota[index]['jurusan']!);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateData(
                                id: dataAnggota[index]['id']!,
                                nama: dataAnggota[index]['nama']!,
                                jurusan: dataAnggota[index]['jurusan']!,
                                url: url),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteData(int.parse(dataAnggota[index]['id']!))
                            .then((result) {
                          if (result['pesan'] == 'berhasil') {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Data berhasil di hapus'),
                                    content: const Text('ok'),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ListData(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                });
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
