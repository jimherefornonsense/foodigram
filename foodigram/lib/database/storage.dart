import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CloudStorageHandler {
  final FirebaseStorage storage = FirebaseStorage.instance;

  UploadTask addImage(String fileName, File imageFile) {
    // Uploading the selected image
    try {
      final imageRef = storage.ref().child("images/$fileName");
      return imageRef.putFile(imageFile);
    } on FirebaseException catch (error) {
      log("Failed to uplaod image: $error");
      rethrow;
    }
  }

  Future<Map<String, String>> getImageMap() async {
    Map<String, String> imageMap = {};
    try {
      final ListResult result = await storage.ref().list();

      await Future.forEach<Reference>(result.items, (file) async {
        final String fileUrl = await file.getDownloadURL();
        imageMap[file.fullPath] = fileUrl;
      });

      return imageMap;
    } catch (error) {
      log("Failed to delete image: $error");
      rethrow;
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      await storage.refFromURL(url).delete();
    } catch (error) {
      log("Failed to delete image: $error");
    }
  }
}
