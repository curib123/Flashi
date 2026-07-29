import 'dart:io';
import 'package:flashi/util/helpers/classes/api/ai/core/image_recognition.dart';
import 'package:flashi/util/helpers/classes/api/ai/core/mistralai_logic.dart';

class AIQuestionGenerator {
  static Future<List<Map<String, String>>> generateQuestionsFromFile(
      String content, String modelType, String quizType, int maxLength) async {
    return await MistralAiLogic.generateQuestionsFromFile(
        content, modelType, quizType, maxLength);
  }

  static Future<List<Map<String, String>>> generateQuestionsFromCustom(
      String topic,
      String description,
      String modelType,
      String quizType,
      int maxLength) async {
    return await MistralAiLogic.generateQuestionsCustomAiGenerated(
        topic, description, modelType, quizType, maxLength);
  }

  static analyzeImage(Future<File?> imageFileFuture, String instruction) async {
    return ImageRecognition.analyzeImage(imageFileFuture, instruction);
  }
}
