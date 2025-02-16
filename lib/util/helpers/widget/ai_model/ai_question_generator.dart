
import 'package:flashi/util/helpers/widget/ai_model/mistalai_logic.dart';

class AIQuestionGenerator {

  static Future<List<Map<String, String>>> generateQuestions(String content, String modelType, String quizType,int maxLength,var questionTypes) async {
    return await MistralAiLogic.generateQuestionsMistral(content,modelType,quizType,maxLength,questionTypes);
  }


}
