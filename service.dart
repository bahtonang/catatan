import 'package:siap/models/auth/user.dart';
import 'package:siap/models/data/lokasi.dart';
import 'package:siap/models/data/persons.dart';
import 'package:siap/models/data/ticket.dart';
import 'package:http/http.dart' show Client;
import 'dart:convert';
import 'package:siap/models/data/tickets.dart';
import 'package:siap/models/data/versi.dart';
import 'package:siap/models/sender/one.dart';

class SiapApiService {
  Client client = Client();
  static const String url = "http://192.168.1.7/apisiap/public/";
  //static const String url = "http://36.93.18.9:81/apisiap/public/";

  Future<VersiModel?> getVersi() async {
    try {
      final respond = await client.get(Uri.parse("$url/versi"));
      if (respond.statusCode == 200) {
        final data = versiModelFromJson(respond.body);
        return data;
      }
    } catch (e) {
      throw e;
    }
    return null;
  }

  Future<LoginModel?> login(String pid, String pass) async {
    try {
      Map<String, String> header = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };
      var respond = await client.post(Uri.parse("$url/otentikasi/login"),
          headers: header, body: json.encode({"pid": pid, "pass": pass}));

      if (respond.statusCode == 200) {
        final data = loginModelFromJson(respond.body);
        return data;
      }
    } catch (e) {
      throw e;
    }
    return null;
  }

  Future<OnesendModel?> getOnesend(String token) async {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    try {
      var respond =
          await client.get(Uri.parse("$url/onesend"), headers: header);
      if (respond.statusCode == 200) {
        final data = onesendModelFromJson(respond.body);
        return data;
      }
    } catch (e) {
      throw e;
    }
    return null;
  }

//mksewing dart Call Teknisi
//dropdown item

  Future<List<Persons>> getTeknisi(
      String gedung, String kodebagian, String token) async {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var respond = await client
        .get(Uri.parse("$url/teknisi/$gedung/$kodebagian"), headers: header);
    if (respond.statusCode == 200) {
      List<dynamic> body = jsonDecode(respond.body)['data'];
      List<Persons> persons =
          body.map((dynamic item) => Persons.fromJson(item)).toList();
      return persons;
    }
    return [];
  }

//mksewing dart Call Teknisi
//dropdown item

  Future<List<Lokasi>> getLokasi(String gedung, String token) async {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    try {
      var respond =
          await client.get(Uri.parse("$url/lokasi/$gedung"), headers: header);
      if (respond.statusCode == 200) {
        List<dynamic> body = jsonDecode(respond.body)['data'];
        List<Lokasi> lokasi =
            body.map((dynamic item) => Lokasi.fromJson(item)).toList();
        return lokasi;
      }
    } catch (e) {
      throw e;
    }
    return [];
  }

  Future<List<Lokasi>> autoLokasi(String query) async {
    final response = await client.get(Uri.parse("$url/autolokasi/$query"));
    if (response.statusCode == 200) {
      final List lokasi = jsonDecode(response.body)['data'];
      return lokasi.map((json) => Lokasi.fromJson(json)).where((lok) {
        final lokasoLower = lok.nama.toLowerCase();
        final queryLower = query.toLowerCase();
        return lokasoLower.contains(queryLower);
      }).toList();
    } else {
      throw Exception();
    }
  }

  Future<bool> kirimticket(
      String kodebarang,
      String namabarang,
      String keluhan,
      String lokasi,
      String gedung,
      String pengirim,
      String teknisi,
      String statuskirim) async {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    try {
      final respond = await client.post(Uri.parse("$url/kirimtiket"),
          headers: header,
          body: json.encode({
            "kodebarang": kodebarang,
            "namabarang": namabarang,
            "keluhan": keluhan,
            "lokasi": lokasi,
            "gedung": gedung,
            "pengirim": pengirim,
            "teknisi": teknisi,
            "statuskirim": statuskirim
          }));
      if (respond.statusCode == 200) {
        return true;
      }
    } catch (e) {
      throw e;
    }
    return false;
  }

  //tampilkan tikets berdasarkan PID teknisi
  //mytiket.dart

  Future<List<Tickets?>> getTickets(String pid, String token) async {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    try {
      final respond =
          await client.get(Uri.parse("$url/myjobs/$pid"), headers: header);
      if (respond.statusCode == 200) {
        List<dynamic> body = jsonDecode(respond.body)['data'];
        List<Tickets> tickets =
            body.map((dynamic item) => Tickets.fromJson(item)).toList();
        return tickets;
      } else {
        return [];
      }
    } catch (e) {
      throw e;
    }
  }
  //tampilkan semua tikets berdasarkan kodebagian
  //all

  Future<List<Tickets?>> getAllTickets(String kodebagian, String token) async {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    try {
      final respond = await client.get(Uri.parse("$url/alltickets/$kodebagian"),
          headers: header);
      if (respond.statusCode == 200) {
        List<dynamic> body = jsonDecode(respond.body)['data'];
        List<Tickets> tickets =
            body.map((dynamic item) => Tickets.fromJson(item)).toList();
        return tickets;
      } else {
        return [];
      }
    } catch (e) {
      throw e;
    }
  }

  Future<int?> kirimPesan(
      String alamat, String rahasia, String hp, String pesan) async {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '$rahasia'
    };
    int hasil = 0;
    final request = await client.post(Uri.parse("$alamat"),
        headers: header,
        body: json.encode(
          {
            "recipient_type": "individual",
            "to": "$hp",
            "type": "text",
            "text": {"body": "$pesan"}
          },
        ));
    if (request.statusCode == 200) {
      var result = jsonDecode(request.body);
      hasil = result['code'];
      if (hasil == 200) {
        return 1;
      }
    } else {
      return 0;
    }
    return 0;
  }

  Future<TicketModel?> tiketAction(String no) async {
    try {
      var respond = await client.get(Uri.parse("$url/tiketaction/$no"));
      if (respond.statusCode == 200) {
        final data = ticketModelFromJson(respond.body);
        return data;
      }
    } catch (e) {
      throw e;
    }
    return null;
  }

  Future<bool> tiketStart(String no) async {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };
    final respond = await client.put(Uri.parse("$url/tiketstart"),
        headers: header, body: json.encode({"nomor": no}));
    if (respond.statusCode == 200) {
      var data = jsonDecode(respond.body)["error"];
      if (data == false) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  //hapus tiket

  Future<bool> tiketDelete(String no) async {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };
    final respond = await client.delete(Uri.parse("$url/tiketdelete"),
        headers: header, body: json.encode({"nomor": no}));
    if (respond.statusCode == 200) {
      var data = jsonDecode(respond.body)["error"];
      if (data == false) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

//ticket close

  Future<bool> tiketClose(String no, String ket) async {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };
    final respond = await client.put(Uri.parse("$url/tiketclose"),
        headers: header, body: json.encode({"nomor": no, "ket": ket}));
    if (respond.statusCode == 200) {
      var data = jsonDecode(respond.body)["error"];
      if (data == false) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

//menampilkan no, validasi di page validasi SPV

  Future<TicketModel?> tiketClosing(String no) async {
    try {
      var respond = await client.get(Uri.parse("$url/tiketclosing/$no"));
      if (respond.statusCode == 200) {
        final data = ticketModelFromJson(respond.body);
        return data;
      }
    } catch (e) {
      throw e;
    }
    return null;
  }

  //tampilkan open tiket dan start di halaman SPV
  Future<List<Tickets?>> getOpenticket(String pid, String token) async {
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    try {
      var respond =
          await client.get(Uri.parse("$url/tiketopen/$pid"), headers: header);
      if (respond.statusCode == 200) {
        List<dynamic> body = jsonDecode(respond.body)['data'];
        List<Tickets> tickets =
            body.map((dynamic item) => Tickets.fromJson(item)).toList();

        return tickets;
      }
    } catch (e) {
      throw e;
    }
    return [];
  }

  //at lokasi
  Future<List<String>> automLokasi(String query, String gedung) async {
    final response =
        await client.get(Uri.parse("$url/atlokasi/$query/$gedung"));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body)['data'];
      return responseData.map((json) => json['nama'] as String).toList();
    } else {
      throw Exception('Tidak ada data Lokasi');
    }
  }

  //at Barang
  Future<List<String>> automBarang(String query, String kode) async {
    final response = await client.get(Uri.parse("$url/atbarang/$query/$kode"));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body)['data'];
      return responseData.map((json) => json['barcode'] as String).toList();
    } else {
      throw Exception('Nama Barang tidak ada');
    }
  }

  //at Keluhan
  Future<List<String>> automKeluhan(String query, String kate) async {
    final response = await client.get(Uri.parse("$url/atkeluhan/$query/$kate"));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body)['data'];
      return responseData.map((json) => json['jenis'] as String).toList();
    } else {
      throw Exception('Data Keluhan tidak ada');
    }
  }
}
