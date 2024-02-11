import 'package:flutter/material.dart';
import 'package:siap/clients/chiefs/chiefaction.dart';
import 'package:siap/models/data/tickets.dart';
import 'package:siap/services/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketOpen extends StatefulWidget {
  final String? nopid;

  TicketOpen({super.key, this.nopid});

  @override
  State<TicketOpen> createState() => _TicketOpenState();
}

class _TicketOpenState extends State<TicketOpen> {
  SiapApiService? siapApiService;
  TicketsModel? apiResult;
  String? tokenNo = "";

  @override
  void initState() {
    super.initState();
    siapApiService = SiapApiService();
    SharedPreferences.getInstance().then((prefValue) => {
          setState(() {
            tokenNo = prefValue.getString("sp_token") ?? "";
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tickets'),
      ),
      body: Container(
        color: Colors.lime[50],
        child: FutureBuilder(
            future: siapApiService?.getOpenticket(
                widget.nopid.toString(), tokenNo ?? ''),
            builder: (BuildContext context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Container(
                    child: Center(
                      child: Text('No Connection'),
                    ),
                  );
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                case ConnectionState.done:
                  if (snapshot.data!.isEmpty) {
                    return Container(
                      child: Center(
                        child: Text('Tidak Ada Data'),
                      ),
                    );
                  } else {
                    List<Tickets?> data = snapshot.data ?? [];
                    return snapshot.hasData
                        ? _dataTiket(data)
                        : Center(
                            child: CircularProgressIndicator(),
                          );
                  }
              }
            }),
      ),
    );
  }

  Widget _dataTiket(List<Tickets?> list) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int i) =>
                Divider(color: Colors.black54),
            itemCount: list.length,
            itemBuilder: (context, index) {
              Tickets? tiket = list[index]!;
              return Container(
                color: Colors.lime[50],
                child: ListTile(
                  title: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            tiket.notiket ?? '',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Column(
                    children: [
                      Row(
                        children: [
                          Text(tiket.lokasi ?? '',
                              style: TextStyle(fontSize: 16.0)),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(tiket.keluhan ?? '',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color:
                                        const Color.fromARGB(255, 247, 1, 1))),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(tiket.statustiket ?? '',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_rounded,
                    color: Color.fromARGB(255, 20, 5, 241),
                    size: 30,
                  ),
                  onTap: () {
                    // context.goNamed('chiefaction',
                    //     params: {'nomor': tiket.notiket ?? ''});
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ChiefAction(
                                  notiket: tiket.notiket,
                                )));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
