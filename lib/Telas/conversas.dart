import 'package:flutter/material.dart';
import 'package:whatsapp/models/Conversa.dart';

class Conversas extends StatefulWidget {
  @override
  _ConversasState createState() => _ConversasState();
}

class _ConversasState extends State<Conversas> {
  List<Conversa> listaConversa = [
    Conversa(
      "Camila",
      "Olá Tudo bem?",
      "https://firebasestorage.googleapis.com/v0/b/whatsapp-27613.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=84d106d8-5807-4e0f-b4b5-ff58ea8bcb71",
    ),
    Conversa(
      "Jose Renato",
      "Não consegui resolver ainda",
      "https://firebasestorage.googleapis.com/v0/b/whatsapp-27613.appspot.com/o/perfil%2Fperfil4.jpg?alt=media&token=34667acd-832c-4423-9d59-8b846e215436",
    ),
    Conversa(
      "Flavia Teixaira",
      "Olá, Pode me ajudar?",
      "https://firebasestorage.googleapis.com/v0/b/whatsapp-27613.appspot.com/o/perfil%2Fperfil3.jpg?alt=media&token=93b2cd53-c814-42fb-bb5e-c969d30b1631",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listaConversa.length,
      itemBuilder: (context, indice) {
        Conversa conversa = listaConversa[indice];

        return ListTile(
          contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          leading: CircleAvatar(
            maxRadius: 30,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(conversa.caminhoFoto),
          ),
          title: Text(
            conversa.nome,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            conversa.mensagem,
            style: TextStyle(fontSize: 14),
          ),
        );
      },
    );
  }
}
