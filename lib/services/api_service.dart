import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatgpt/constants/api_consts.dart';
import 'package:chatgpt/models/chat_model.dart';
import 'package:chatgpt/models/models_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {'Authorization': 'Bearer $API_KEY'},
      );

      Map jasonResponse = jsonDecode(response.body);
      if (jasonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jasonResponse['error']["message"]}");
        throw HttpException(jasonResponse['error']["message"]);
      }
      List temp = [];
      for (var value in jasonResponse["data"]) {
        temp.add(value);
        //log("temp ${value["id"]}");
      }
      // print("jasonResponse $jasonResponse");
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  // Send Message using ChatGPT API
  static Future<List<ChatModel>> sendMessageGPT(
      {required String message, required String modelId}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "messages": [
              {
                "role": "user",
                "content": message,
              }
            ]
          },
        ),
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
            msg: jsonResponse["choices"][index]["message"]["content"],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  //send message fct
  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(Uri.parse("$BASE_URL/completions"),
          headers: {
            'Authorization': 'Bearer $API_KEY',
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "model": modelId,
            "prompt": message,
            "max_tokens": 300,
          }));

      Map jasonResponse = jsonDecode(response.body);
      if (jasonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jasonResponse['error']["message"]}");
        throw HttpException(jasonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jasonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jasonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jasonResponse["choices"].length,
          (index) => ChatModel(
            msg: jasonResponse["choices"][index]["text"],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}
