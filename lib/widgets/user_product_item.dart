import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:flutter_complete_guide/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final String title, imageUrl, id;

  UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);

    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(EditProductScreen.routeName, arguments: id);
                },
                icon: Icon(
                  Icons.edit,
                  color: Colors.blueGrey,
                )),
            IconButton(
                onPressed: () async {
                  try {
                    Provider.of<Products>(context, listen: false)
                        .deleteProduct(id);
                  } catch (e) {
                    scaffold.showSnackBar(SnackBar(
                      content: Text(
                        'Deleting Failed! ',
                        textAlign: TextAlign.center,
                      ),
                    ));
                  }
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ))
          ],
        ),
      ),
    );
  }
}
