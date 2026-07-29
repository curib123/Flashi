import 'dart:io';
import 'package:flashi/features/ai/data/services/image_recognition_service.dart';
import 'package:flashi/features/ai/data/services/mistral_ai_service.dart';

class AiQuestionGenerator {
  static Future<List<Map<String, String>>> generateQuestionsFromFile(
      String content, String modelType, String quizType, int maxLength) async {
    return await MistralAiService.generateQuestionsFromFile(
        content, modelType, quizType, maxLength);
  }

  static Future<List<Map<String, String>>> generateQuestionsFromCustom(
      String topic,
      String description,
      String modelType,
      String quizType,
      int maxLength) async {
    return await MistralAiService.generateQuestionsCustomAiGenerated(
        topic, description, modelType, quizType, maxLength);
  }

  static analyzeImage(Future<File?> imageFileFuture, String instruction) async {
    return ImageRecognitionService.analyzeImage(imageFileFuture, instruction);
  }
}
