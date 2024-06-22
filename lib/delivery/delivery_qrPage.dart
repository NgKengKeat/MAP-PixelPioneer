import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controller.dart';

class QrCodePage extends StatefulWidget 
{
  final String id;

  const QrCodePage({super.key, required this.id});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> 
{
  String dropdownValue = "";
  List<String> parcelTrackingIds = [];

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 195, 44, 1),
        centerTitle: true,
        title: const Text(
          'Quick Scan',
          style: TextStyle(
            fontFamily: 'roboto',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // You can replace this with your custom logo
            color: Colors.white, // Icon color
          ),
          onPressed: () {
            // Navigator.of(context).pushReplacementNamed('/');
            Navigator.of(context).pushReplacementNamed('/delivery_list');
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                      'Show the generated Qr at CPP to easily get your parcel detail.',
                      style: TextStyle(
                        color: Color(0xFF050505),
                        fontSize: 17,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        height: 0.00,
                      )),
                  const SizedBox(
                    height: 50,
                  ),
                  Column(
                    children: [
                      Column(children: [
                        const Text('Parcel Qr',
                            style: TextStyle(
                              color: Color(0xFF050505),
                              fontSize: 17,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                              height: 0.00,
                            )),
                        const SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: QrImageView(
                            data: dropdownValue.toString(),
                            // data: qrController.text,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        ),
                      ]),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text('Select Your Parcel Track Number : ',
                          style: TextStyle(
                            color: Color(0xFF050505),
                            fontSize: 17,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                            height: 0.00,
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 250,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
  child: DropdownButton<String>(
    value:widget.id, 
    items:  [
      DropdownMenuItem(
        value: widget.id,
        child: Text(widget.id), 
      ),
    ],
    onChanged: (value) {
      
    },
    isExpanded: true,
    elevation: 8,
  ),
),

                      )
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
