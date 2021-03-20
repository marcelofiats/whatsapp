import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/models/Mensagem.dart';

import 'models/Usuario.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;
  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  File imagemSelecionada;
  TextEditingController _textMensagemBox = TextEditingController();
  String _idUsuarioLogado;
  String _idUsuariodestinatario;
  bool _subindoImagem;
  FirebaseFirestore db = FirebaseFirestore.instance;
  //
  _recuperaDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado.uid;
    _idUsuariodestinatario = widget.contato.idUsuario;
  }

  _enviarMensagem() {
    String textoMensagem = _textMensagemBox.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";
      //salvando mensagem para remetente
      _salvarMensagem(_idUsuarioLogado, _idUsuariodestinatario, mensagem);
      //salvando mensagem para destinatario
      _salvarMensagem(_idUsuariodestinatario, _idUsuarioLogado, mensagem);
    }
  }

  _salvarMensagem(String idRemetente, String idDestinatario, Mensagem msg) {
    db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());
    _textMensagemBox.text = "";
  }

  _enviarFoto() async {
    ImagePicker image = ImagePicker();
    final picker = await image.getImage(source: ImageSource.camera);
    imagemSelecionada = File(picker.path);

    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idUsuarioLogado)
        .child(nomeImagem + ".jpg");

    UploadTask task = arquivo.putFile(imagemSelecionada);

    task.snapshotEvents.listen((TaskSnapshot event) {
      if (event.state == TaskState.running) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (event.state == TaskState.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });
    task.then((TaskSnapshot snapshot) => _recuperarUrlImagem(snapshot));
  }

  Future _recuperarUrlImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";
    //salvando mensagem para remetente
    _salvarMensagem(_idUsuarioLogado, _idUsuariodestinatario, mensagem);
    //salvando mensagem para destinatario
    _salvarMensagem(_idUsuariodestinatario, _idUsuarioLogado, mensagem);
  }

  @override
  void initState() {
    _recuperaDadosUsuario();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //STREAMBIULDER
    var stream = StreamBuilder(
      stream: db
          .collection("mensagens")
          .doc(_idUsuarioLogado)
          .collection(_idUsuariodestinatario)
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text(
                    "Carregando...",
                  )
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;
            if (snapshot.hasError) {
              return Expanded(
                child: Text("Erro ao carregar os dados!"),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: querySnapshot.docs.length,
                  itemBuilder: (context, index) {
                    //recuperando lista de mensagens
                    List<DocumentSnapshot> mensagens =
                        querySnapshot.docs.toList();
                    DocumentSnapshot mensagem = mensagens[index];
                    //Largura mensagens
                    double larguraMensagens =
                        MediaQuery.of(context).size.width * 0.7;

                    //Defininco cores e alinhamento das mensagens
                    Alignment alinhamento = Alignment.centerRight;
                    Color cor = Color(0xffd2ffa5);
                    if (_idUsuarioLogado != mensagem["idUsuario"]) {
                      alinhamento = Alignment.centerLeft;
                      cor = Colors.white;
                    }
                    //
                    return Align(
                      alignment: alinhamento,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Container(
                          width: larguraMensagens,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: mensagem["tipo"] == "texto"
                              ? Text(mensagem["mensagem"])
                              : Image.network(mensagem["urlImagem"]),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            break;
          default:
        }
      },
    );

    var _caixaMensagens = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _textMensagemBox,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    prefixIcon: _subindoImagem == true
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: _enviarFoto,
                          ),
                  ),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff075E54),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: _enviarMensagem,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: widget.contato.urlImagem != null
                ? NetworkImage(widget.contato.urlImagem)
                : null,
          ),
          Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(widget.contato.nome),
          )
        ],
      )),

      //BODY
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/imagens/bg.png"),
          fit: BoxFit.cover,
        )),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                stream,
                _caixaMensagens,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
