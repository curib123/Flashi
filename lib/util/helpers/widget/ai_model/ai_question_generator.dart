
import 'package:flashi/util/helpers/widget/ai_model/mistalai_logic.dart';
import 'package:flashi/util/helpers/widget/ai_model/openai_logic.dart';

class AIQuestionGenerator {

  static Future<List<Map<String, String>>> generateQuestions(String content, String modelType, String quizType,int maxLength) async {
    switch (modelType.toLowerCase()) {
      case "mistral-small-latest":
        return await MistralAiLogic.generateQuestionsMistral(content,modelType,quizType,maxLength);
      case "mistral-medium":
        return await MistralAiLogic.generateQuestionsMistral(content,modelType,quizType,maxLength);
      case "pixtral-12b-2409":
        return  await MistralAiLogic.generateQuestionsMistral(content,modelType,quizType,maxLength);
      case "open-mistral-nemo":
        return  await MistralAiLogic.generateQuestionsMistral(content,modelType,quizType,maxLength);
      default:
        throw Exception("Unsupported model: $modelType");
    }
  }


}
