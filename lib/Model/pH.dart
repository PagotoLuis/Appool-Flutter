
class Ph {
  int _id;
  String _valor;
  String _data;

  Ph(this._valor, this._data);



  get id => this._id;

  set id(value) => this._id = value;

  get valor => this._valor;

  set valor(value) => this._valor = value;

  get data => this._data;

  set data(value) => this._data = value;

  Map<String, dynamic> topMap(){
    var dados = Map<String, dynamic>();
    dados['id'] = _id;
    dados['valor'] = _valor;
    dados['data'] = _data;
    return dados;
  }

  Ph.deMapParaModel(Map<String, dynamic> dados){
    this._id = dados['id'];
    this._valor = dados['valor'];
    this._data = dados['data'];
    
  }
}
