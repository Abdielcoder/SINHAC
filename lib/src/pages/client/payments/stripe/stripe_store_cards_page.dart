import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import 'package:lavador/src/provider/StripeProvider.dart';

import '../../../../provider/stripe_store_card_provider.dart';


class StripeStoreCardPage extends StatefulWidget {


  @override
  StripeStoreCardPageState createState() => StripeStoreCardPageState();
}

class StripeStoreCardPageState extends State<StripeStoreCardPage> {

  onItemPress(BuildContext context, int index) async {
    switch (index) {
      case 0:
        // payViaNewCard(context);
        break;
      case 1:
        Navigator.pushNamed(context, 'client/payments/stripe/existingcards');
        break;
    }
  }

    // payViaNewCard(BuildContext context) async {
    //   // ProgressDialog dialog = new ProgressDialog(context);
    //   ProgressDialog progressDialog = new ProgressDialog(context: context);
    //   progressDialog.show(max: 100, msg: 'Espere un momento');
    //
    //
    //   var response = await StripeService.payWithNewCard(
    //
    //       amount: '15000',
    //       currency: 'USD',
    //
    //   );
    //
    //
    //   //await dialog.hide();
    //   progressDialog.close();
    //
    //   Scaffold.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(response.message),
    //         duration: new Duration(
    //             milliseconds: response.success == true ? 1200 : 3000),
    //       )
    //   );
    // }

    @override
    void initState() {
      super.initState();
      StripeService.init();
    }

    @override
    Widget build(BuildContext context) {
      ThemeData theme = Theme.of(context);
      return Scaffold(
            body: Container(
              padding: EdgeInsets.all(20),
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    Icon icon;
                    Text text;

                    switch (index) {
                      case 0:
                        icon =
                            Icon(Icons.add_circle, color: theme.primaryColor);
                        text = Text('Paga con una tarjeta nueva');
                        break;
                      case 1:
                        icon =
                            Icon(Icons.credit_card, color: theme.primaryColor);
                        text = Text('Paga con una tarjeta existente');
                        break;
                    }

                    return InkWell(
                      onTap: () {
                        onItemPress(context, index);
                      },
                      child: ListTile(
                        title: text,
                        leading: icon,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      Divider(
                        color: theme.primaryColor,
                      ),
                  itemCount: 2
              ),
            ),
      );
    }
  }
