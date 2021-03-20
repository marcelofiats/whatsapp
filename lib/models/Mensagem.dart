class Mensagem {
  String _idUsuario;
  String _mensagem;
  String _urlImagem;
  String _tipo;

  Mensagem();

  String get idUsuario => this._idUsuario;

  set idUsuario(String value) => this._idUsuario = value;

  String get mensagem => this._mensagem;

  set mensagem(value) => this._mensagem = value;

  String get urlImagem => this._urlImagem;

  set urlImagem(value) => this._urlImagem = value;

  String get tipo => this._tipo;

  set tipo(value) => this._tipo = value;

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': this._idUsuario,
      'mensagem': this._mensagem,
      'urlImagem': this._urlImagem,
      'tipo': this._tipo,
    };
  }
}
