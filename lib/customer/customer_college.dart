import 'package:flutter/material.dart';

Widget buildListTileForColleague(
    String colleague, Function updateBlock, BuildContext context) {
  List<Widget> listTiles;

  switch (colleague) {
    case 'KTDI':
      listTiles = [
        ListTile(
          title: const Text('MA1'),
          onTap: () {
            updateBlock('MA1');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('M01'),
          onTap: () {
            updateBlock('M01');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('M02'),
          onTap: () {
            updateBlock('M02');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('M03'),
          onTap: () {
            updateBlock('M03');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('M04'),
          onTap: () {
            updateBlock('M04');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('M05'),
          onTap: () {
            updateBlock('M05');
            Navigator.pop(context);
          },
        )
      ];
      break;
    case 'KTHO':
      listTiles = [
        ListTile(
          title: const Text('L01'),
          onTap: () {
            updateBlock('L01');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('L02'),
          onTap: () {
            updateBlock('L02');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('L03'),
          onTap: () {
            updateBlock('L03');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('L04'),
          onTap: () {
            updateBlock('L04');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('L05'),
          onTap: () {
            updateBlock('L05');
            Navigator.pop(context);
          },
        )
      ];
      break;
    case 'KTR':
      listTiles = [
        ListTile(
          title: const Text('K01'),
          onTap: () {
            updateBlock('K01');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('K02'),
          onTap: () {
            updateBlock('K02');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('K03'),
          onTap: () {
            updateBlock('K03');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('K04'),
          onTap: () {
            updateBlock('K04');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('K05'),
          onTap: () {
            updateBlock('K05');
            Navigator.pop(context);
          },
        )
      ];
      break;
    case 'KDSE':
      listTiles = [
        ListTile(
          title: const Text('WA1'),
          onTap: () {
            updateBlock('WA1');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('WA2'),
          onTap: () {
            updateBlock('WA2');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('WA3'),
          onTap: () {
            updateBlock('WA3');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('W1'),
          onTap: () {
            updateBlock('W1');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('W2'),
          onTap: () {
            updateBlock('W2');
            Navigator.pop(context);
          },
        )
      ];
      break;
    case 'KDOJ':
      listTiles = [
        ListTile(
          title: const Text('XB1'),
          onTap: () {
            updateBlock('XB1');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('XB2'),
          onTap: () {
            updateBlock('XB2');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('XC1'),
          onTap: () {
            updateBlock('XC1');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('XC2'),
          onTap: () {
            updateBlock('XC2');
            Navigator.pop(context);
          },
        ),
      ];
      break;
    case 'KTC':
      listTiles = [
        ListTile(
          title: const Text('S01'),
          onTap: () {
            updateBlock('S01');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('S02'),
          onTap: () {
            updateBlock('S02');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('S03'),
          onTap: () {
            updateBlock('S03');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('S04'),
          onTap: () {
            updateBlock('S04');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('S05'),
          onTap: () {
            updateBlock('S05');
            Navigator.pop(context);
          },
        )
      ];
      break;
    case 'K9&K10':
      listTiles = [
        ListTile(
          title: const Text('UA1'),
          onTap: () {
            updateBlock('UA1');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('UA2'),
          onTap: () {
            updateBlock('UA2');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('K10'),
          onTap: () {
            updateBlock('K10');
            Navigator.pop(context);
          },
        ),
      ];
      break;
    // Add more cases as needed
    default:
      listTiles = [
        ListTile(
          title: const Text('Please select a colleague first!'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ];
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: listTiles,
  );
}