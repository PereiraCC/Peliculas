

import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:async';

import 'package:peliculas/src/models/actores_model.dart';
import 'package:peliculas/src/models/pelicula_model.dart';

class PeliculasProvider {

  String _apikey = 'dfd2209626ba7b9bd2b11a8284931342';
  String _url = 'api.themoviedb.org';
  String _languaje = 'es-Es';

  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();

  // Se crea el Stream
  final _popularesStreamController = StreamController<List<Pelicula>>.broadcast();

  //Funcion para añadir informacion al Stream
  Function(List<Pelicula>) get popularesSink => _popularesStreamController.sink.add;

  // Funcion para escuchar el Stream
  Stream<List<Pelicula>> get popularesStream => _popularesStreamController.stream;

  // Metodo para cerrar el Stream
  void disposeStreams(){
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url) async {
    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);

    final peliculas = new Peliculas.fromJsonList(decodedData['results']);

    return peliculas.iteams;
  }

  Future<List<Pelicula>> getEnCines() async {

    final url = Uri.https(_url, '3/movie/now_playing', {
      'api_key' : _apikey,
      'language' : _languaje
    });

    return _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopulares() async {


    if(_cargando) return [];

    _cargando = true;
    _popularesPage++;

    final url = Uri.https(_url, '3/movie/popular', {
      'api_key' : _apikey,
      'language' : _languaje,
      'page'     : _popularesPage.toString()
    });

    final resp = await _procesarRespuesta(url);

    _populares.addAll(resp);
    popularesSink(_populares); //Se agregan la informacion al StreamController

    _cargando = false;
    return resp;
  }

  Future<List<Actor>> getCast(String peliId) async{
    final url = Uri.https(_url, '3/movie/$peliId/credits',{
      'api_key'  : _apikey,
      'language' : _languaje,
    });

    final resp = await http.get(url);
    final decodedData =  json.decode(resp.body);

    final cast = new Cast.fromJsonList(decodedData['cast']);

    return cast.actores;
    
  }

  Future<List<Pelicula>> buscarPelicula(String query) async {

    final url = Uri.https(_url, '3/search/movie', {
      'api_key' : _apikey,
      'language' : _languaje,
      'query'    : query
    });

    return  await _procesarRespuesta(url);
  }

  
}