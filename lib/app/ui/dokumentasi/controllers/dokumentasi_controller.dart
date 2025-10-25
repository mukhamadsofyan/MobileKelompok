import 'package:get/get.dart';

class DokumentasiController extends GetxController {
  var photos = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // contoh foto dummy
    photos.addAll([
      'https://picsum.photos/300/200?random=1',
      'https://picsum.photos/300/200?random=2',
    ]);
  }

  void tambahFotoDummy() {
    photos.add('https://picsum.photos/300/200?random=${photos.length + 3}');
  }
}
