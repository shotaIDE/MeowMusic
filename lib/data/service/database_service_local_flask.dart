import 'package:meow_music/data/model/template.dart';
import 'package:meow_music/data/service/database_service.dart';

class DatabaseServiceLocalFlask implements DatabaseService {
  @override
  Future<List<TemplateDraft>> getTemplates() async {
    return [
      const TemplateDraft(
        id: 'happy_birthday',
        name: 'Happy Birthday',
        path: '/static/templates/happy_birthday.wav',
      ),
    ];
  }
}
