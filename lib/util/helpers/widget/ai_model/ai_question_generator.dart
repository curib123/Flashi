

import 'package:flashi/util/helpers/widget/ai_model/mistralai_logic.dart';

class AIQuestionGenerator {

  static Future<List<Map<String, String>>> generateQuestions(String content, String modelType, String quizType,int maxLength) async {
    return await MistralAiLogic.generateQuestionsMistral(content,modelType,quizType,maxLength);
  }


}
