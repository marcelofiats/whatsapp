import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _textNome = TextEditingController();
  String _idUsuarioLogado;
  String _urlImagemRecuperada;
  bool _subindoImagem = false;
  File _imagem;
  ImagePicker picker = ImagePicker();
  File _imagemSelecionada;

  Future _recuperarImagem(String origemImagem) async {
    switch (origemImagem) {
      case "camera":
        final pickerFile = await picker.getImage(source: ImageSource.camera);
        _imagemSelecionada = File(pickerFile.path);
        break;
      case "galeria":
        final pickerFile = await picker.getImage(source: ImageSource.gallery);
        _imagemSelecionada = File(pickerFile.path);
        break;
      default:
    }
    setState(() {
      _imagem = _imagemSelecionada;
      if (_imagem != null) {
        _subindoImagem = true;
        _uploadImagem();
      }
    });
  }

  Future _uploadImagem() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo =
        pastaRaiz.child("perfil").child(_idUsuarioLogado + ".jpg");

    UploadTask task = arquivo.putFile(_imagem);

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
    _atualizarUrlImagemFirestore(url);

    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  _atualizarUrlImagemFirestore(String url) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> dadosAtualizar = {
      "urlImagem": url,
    };
    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  _atualizarDadosUsuario(String texto) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> dadosAtualizar = {
      "nome": texto,
    };
    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  _recuperaDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data();
    _textNome.text = dados["nome"];

    if (dados["urlImagem"] != null) {
      setState(() {
        _urlImagemRecuperada = dados["urlImagem"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperaDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: _subindoImagem
                      ? CircularProgressIndicator()
                      : Container(),
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage: _urlImagemRecuperada != null
                      ? NetworkImage(_urlImagemRecuperada)
                      : null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text(
                        "Câmera",
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        _recuperarImagem("camera");
                      },
                    ),
                    TextButton(
                      child: Text(
                        "Galeria",
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        _recuperarImagem("galeria");
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: TextField(
                    onChanged: (texto) {
                      _atualizarDadosUsuario(texto);
                    },
                    controller: _textNome,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 19, 32, 16),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: RaisedButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      child: Text(
                        "Salvar",
                        style: TextStyle(fontSize: 18),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      onPressed: () {
                        setState(() {
                          _atualizarDadosUsuario(_textNome.text);
                        });
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
