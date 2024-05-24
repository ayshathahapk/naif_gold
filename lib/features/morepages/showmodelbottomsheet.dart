import 'package:flutter/material.dart';
import 'package:naif_gold/features/morepages/products.dart';
import 'package:naif_gold/features/morepages/trend_analysis.dart';
import '../../main.dart';
import 'bank_details.dart';
import 'graph.dart';
import 'news.dart';

class Showpage extends StatefulWidget {
  const Showpage({super.key});

  @override
  State<Showpage> createState() => _ShowpageState();
}

class _ShowpageState extends State<Showpage> {
  @override
  Widget build(BuildContext context) {
    return
      Container(
      height: height * 0.4,
      width: width,
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.new_releases), // Icon for 'New'
            title: Text('News'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => New(),));
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance), // Icon for 'Bank Details'
            title: Text('Bank Details'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BankDetails(),));
            },
          ),
          ListTile(
            leading: Icon(Icons.auto_graph), // Icon for 'Bank Details'
            title: Text('Graph'),
               onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Graph(),));
            },
          ),
          ListTile(
            leading: Icon(Icons.trending_up_sharp), // Icon for 'Bank Details'
            title: Text('Trend analysis'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TrendAnalysis(),));
            },
          ),
          ListTile(
            leading: Icon(Icons.production_quantity_limits_sharp), // Icon for 'Bank Details'
            title: Text('Products'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Products(),));
            },
          ),
        ],
      ),

    );
  }
}



