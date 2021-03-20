class Conversa {
  String _nome;
  String _mensagem;
  String _caminhoFoto;

  String get nome => this._nome;

  set nome(String value) => this._nome = value;

  String get mensagem => this._mensagem;

  set mensagem(value) => this._mensagem = value;

  String get caminhoFoto => this._caminhoFoto;

  set caminhoFoto(value) => this._caminhoFoto = value;

  Conversa(this._nome, this._mensagem, this._caminhoFoto);
}
