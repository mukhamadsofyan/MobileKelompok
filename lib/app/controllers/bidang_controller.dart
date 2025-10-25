import 'package:get/get.dart';
import '../../services/org_service.dart';

class BidangController extends GetxController {
  var bidangList = <dynamic>[].obs;
  final api = OrgService();

  @override
  void onInit() {
    super.onInit();
    loadBidang();
  }

  void loadBidang() async {
    bidangList.value = await api.fetchBidang();
  }
}
