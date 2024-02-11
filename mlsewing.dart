import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:siap/clients/chiefs/home_chief.dart';
import 'package:siap/models/data/persons.dart';
import 'package:siap/models/sender/one.dart';
import 'package:siap/services/service.dart';

class MekanikListrik extends StatefulWidget {
  final String? gedung;
  final String? kodebagian;
  final String? pid;
  final String? token;
  MekanikListrik(
      {super.key, this.gedung, this.kodebagian, this.pid, this.token});

  @override
  State<MekanikListrik> createState() => _MekanikListrikState();
}

class _MekanikListrikState extends State<MekanikListrik> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController txtKodebarang = TextEditingController();
  TextEditingController txtNamabarang = TextEditingController();
  TextEditingController txtKeluhan = TextEditingController();
  TextEditingController txtLokasi = TextEditingController();
  String? errorMsg;
  String? errorTeknisi;
  SiapApiService? siapApiService;

  List<Persons> _items = [];

  Persons? _selectedTeknisi;

  OnesendModel? apiResult;
  String? namaTeknisi;
  String? hpTeknisi;
  String? nomorHp;
  String? pidTeknisi;
  String? namaLokasi;
  String? kodeLokasi;

  @override
  void initState() {
    super.initState();
    siapApiService = SiapApiService();
    siapApiService
        ?.getTeknisi(widget.gedung.toString(), widget.kodebagian.toString(),
            widget.token.toString())
        .then((value) {
      setState(() {
        _items = value;
      });
    });

    getSender();
  }

  Future getSender() async {
    var res = await siapApiService?.getOnesend(widget.token.toString());
    setState(() {
      apiResult = res;
    });
  }

  Future savetiket() async {
    siapApiService
        ?.kirimticket(
            txtKodebarang.text,
            txtNamabarang.text,
            txtKeluhan.text,
            namaLokasi ?? '',
            widget.gedung.toString(),
            widget.pid.toString(),
            pidTeknisi ?? '',
            'SENT')
        .then((value) => true);
    if (true) {
      await _showMyDialog();
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tiket Terkirim'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Permintaan sudah di kirim ke Mekanik'),
                Text('Silakan periksa status tiket di menu utama'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                final String pesan = txtNamabarang.text +
                    "\n" +
                    namaLokasi.toString() +
                    "\n" +
                    txtKeluhan.text;
                siapApiService
                    ?.kirimPesan(apiResult!.data.alamat,
                        apiResult!.data.rahasia, hpTeknisi ?? '', pesan)
                    .then((value) {
                  txtKodebarang.clear();
                  txtKeluhan.clear();
                  txtNamabarang.clear();
                });
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ChiefHome()),
                    (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 233, 235, 236)),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Tiket Keluhan Listrik",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 2, 23, 211)),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        DropdownButtonFormField<Persons>(
                          value: _selectedTeknisi,
                          items: _items.map((Persons item) {
                            return DropdownMenuItem<Persons>(
                                child: Text(item.nama), value: item);
                          }).toList(),
                          onChanged: (Persons? newValue) {
                            setState(() {
                              _selectedTeknisi = newValue;
                              namaTeknisi = newValue?.nama;
                              hpTeknisi = newValue?.hp;
                              pidTeknisi = newValue?.pid;
                            });
                          },
                          validator: (_selectedTeknisi) =>
                              _selectedTeknisi == null
                                  ? 'Nama Harus di pilih'
                                  : null,
                          decoration: InputDecoration(
                              labelText: 'Pilih Nama',
                              border: OutlineInputBorder(
                                borderSide: (BorderSide(
                                    color: Color.fromARGB(255, 42, 4, 85),
                                    width: 12)),
                              )),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TypeAheadFormField(
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'Lokasi Harus di isi';
                              }
                              return null;
                            },
                            hideSuggestionsOnKeyboardHide: false,
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: txtLokasi,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Ketik Lokasi',
                              ),
                            ),
                            suggestionsCallback: (String query) =>
                                siapApiService!.automLokasi(
                                    query, widget.gedung.toString()),
                            itemBuilder: (context, String suggestions) {
                              return ListTile(
                                title: Text(suggestions),
                              );
                            },
                            onSuggestionSelected: (String suggestion) {
                              txtLokasi.text = suggestion;
                              setState(() {
                                namaLokasi = txtLokasi.text;
                                if (suggestion.length >= 5) {
                                  kodeLokasi = suggestion
                                      .substring(suggestion.length - 4);
                                }
                              });
                            }),
                        SizedBox(height: 10.0),
                        TypeAheadFormField(
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'No seri Harus di isi';
                              }
                              return null;
                            },
                            hideSuggestionsOnKeyboardHide: false,
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: txtNamabarang,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Ketik No Seri Barang',
                              ),
                            ),
                            suggestionsCallback: (String query) =>
                                siapApiService!.automBarang(query, kodeLokasi!),
                            itemBuilder: (context, String saran) {
                              return ListTile(
                                title: Text(saran),
                              );
                            },
                            onSuggestionSelected: (String pilihan) {
                              txtNamabarang.text = pilihan;
                              setState(() {});
                            }),
                        SizedBox(height: 10.0),
                        TypeAheadFormField(
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'Keluhan Harus di isi';
                              }
                              return null;
                            },
                            hideSuggestionsOnKeyboardHide: false,
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: txtKeluhan,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Ketik Keluhan',
                              ),
                            ),
                            suggestionsCallback: (String query) =>
                                siapApiService!.automKeluhan(query, "KB02"),
                            itemBuilder: (context, String saran) {
                              return ListTile(
                                title: Text(saran),
                              );
                            },
                            onSuggestionSelected: (String pilihan) {
                              txtKeluhan.text = pilihan;
                              setState(() {});
                            }),
                        SizedBox(height: 40.0),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              savetiket();
                            }
                          },
                          icon: Icon(Icons.send),
                          label: Text(
                            'Kirim',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.0),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(200, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
