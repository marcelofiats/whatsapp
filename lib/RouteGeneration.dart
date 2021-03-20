import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Telas/contatos.dart';
import 'package:whatsapp/Telas/conversas.dart';
import 'package:whatsapp/mensagens.dart';
import 'package:whatsapp/cadastro.dart';
import 'package:whatsapp/configuracoes.dart';
import 'package:whatsapp/home.dart';

import 'login.dart';

class RouteGeneration {
  static Route<dynamic> generationRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Login());
      case "/home":
        return MaterialPageRoute(builder: (_) => Home());
      case "/cadastro":
        return MaterialPageRoute(builder: (_) => Cadastro());
      case "/contatos":
        return MaterialPageRoute(builder: (_) => Contatos());
      case "/conversas":
        return MaterialPageRoute(builder: (_) => Conversas());
      case "/configuracoes":
        return MaterialPageRoute(builder: (_) => Configuracoes());
      case "/mensagens":
        return MaterialPageRoute(builder: (_) => Mensagens(args));

      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encotrada!"),
        ),
        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}
