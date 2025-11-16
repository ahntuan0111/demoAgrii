// bindings/report_issue_binding.dart
import 'package:get/get.dart';
import '../controllers/report_issue_controller.dart';

class ReportIssueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportIssueController>(() => ReportIssueController());
  }
}