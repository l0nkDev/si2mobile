import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserFeedback extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final style = theme.textTheme.headlineMedium!;

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 32,),
          Text("Valoración del pedido", style: style),
          SizedBox(height: 24,),
          Row(
            children: [
              SizedBox(width: 24),
              Text("Productos", style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500))
            ]
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Card(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        Text("Lavadora", style: theme.textTheme.bodyLarge),
                        Expanded(child: Text("")),
                        Text("★★★☆☆", style: theme.textTheme.headlineSmall!.copyWith(color: Color(0xFF01687D))),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: 16),
                      Text("¿Qué te pareció la calidad del producto?"),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 96,
                      child: Expanded(
                        child: TextField(
                          decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Reseña'),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical(y: -1),
                          ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      FilledButton( child: Text("Enviar"), onPressed: () {}),
                    ],
                  ),
                  SizedBox(height: 8)
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Card(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        Text("Entrega", style: theme.textTheme.bodyLarge),
                        Expanded(child: Text("")),
                        Text("★★★☆☆", style: theme.textTheme.headlineSmall!.copyWith(color: Color(0xFF01687D))),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: 16),
                      Text("¿Cómo fue el servicio de delivery?"),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 96,
                      child: Expanded(
                        child: TextField(
                          decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Reseña'),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical(y: -1),
                          ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      FilledButton( child: Text("Enviar"), onPressed: () {}),
                    ],
                  ),
                  SizedBox(height: 8)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}