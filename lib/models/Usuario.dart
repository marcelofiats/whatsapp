class Usuario {
  String _idUsuario;
  String _nome;
  String _email;
  String _senha;
  String _urlImagem;

  Usuario();

  String get idUsuario => this._idUsuario;

  set idUsuario(String value) => this._idUsuario = value;

  String get nome => this._nome;

  set nome(String value) => this._nome = value;

  String get email => this._email;

  set email(String value) => this._email = value;

  String get senha => this._senha;

  set senha(String value) => this._senha = value;

  String get urlImagem => this._urlImagem;

  set urlImagem(String value) => this._urlImagem = value;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "nome": this._nome,
      "email": this._email,
    };
    return map;
  }
}
