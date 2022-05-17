import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:foodigram/data_center.dart';
import 'package:foodigram/screens/loading_screen.dart';
import 'package:hashtagable/hashtagable.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../database/models.dart';
import 'dart:io';
import '../widgets/places_field.dart';

class NewPost extends StatefulWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  State<NewPost> createState() => _NowPostState();
}

class _NowPostState extends State<NewPost> {
  String? fileName;
  File? imageFile;
  Map<String, String?>? place;
  final _textAreaController = TextEditingController();
  late DataCenter _dataCenter;
  bool _isLoading = false;

  @override
  void initState() {
    _getImage(ImageSource.gallery);
    super.initState();
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      XFile? image = await ImagePicker().pickImage(source: source);

      if (image != null) {
        File? cropped = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
        );
        if (cropped != null) {
          setState(() {
            fileName = path.basename(cropped.path);
            imageFile = File(cropped.path);
          });
        }
      }
    } catch (err) {
      log("$err");
    }
    // If didn't capture the image
    if (fileName == null && imageFile == null) {
      Navigator.pop(context);
    }
  }

  void _unfocusAll(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void _snackBarMessenger(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
      ),
    );
  }

  void _placeFieldCallback(Map<String, String?>? queryPlace) {
    place = queryPlace;
  }

  Future<void> _savePost() async {
    final String content = _textAreaController.text;
    Map<String, bool> tags = {};
    Map<String, String?> location = {};
    //tags
    extractHashTags(content).forEach((tag) {
      tags[tag] = true;
    });
    setState(() => _isLoading = true);
    //location
    if (place != null && place!.isNotEmpty) {
      location['name'] = place!['name'];
      location['vicinity'] = place!['vicinity'];
      location['placeId'] = place!['placeId'];
    }
    //image & content
    try {
      //upload the image to storage
      UploadTask uploadTask = _dataCenter.addImage(fileName!, imageFile!);
      uploadTask.snapshotEvents.listen((event) async {
        switch (event.state) {
          case TaskState.success:
            String imageUrl = await event.ref.getDownloadURL();
            //store the post to database
            await _dataCenter.addPost(
              Post(
                timestamp: DateTime.now(),
                imageUrl: imageUrl,
                location: location,
                content: content,
                tags: tags,
              ),
            );
            //close the form screen
            Navigator.popUntil(context, ModalRoute.withName('lobby'));
            break;
          case TaskState.error:
            _snackBarMessenger('Post failed..', (Colors.red[200])!);
            setState(() => _isLoading = false);
            break;
          default:
            break;
        }
      });
    } on FirebaseException catch (error) {
      log("Failed to add post: $error");
    }
  }

  @override
  void dispose() {
    _textAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _dataCenter = context.read<DataCenter>();

    return (_isLoading || fileName == null || imageFile == null)
        ? const Loading()
        : GestureDetector(
            onTap: () {
              _unfocusAll(context);
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  "Foodigram",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    fontFamily: "Chewy",
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                      onPressed: () {
                        if (_textAreaController.text.isNotEmpty) {
                          _unfocusAll(context);
                          _savePost();
                        } else {
                          _snackBarMessenger(
                              'Content cannot be empty!', (Colors.grey[600])!);
                        }
                      },
                      icon: const Icon(Icons.add))
                ],
              ),
              body: Column(
                children: [
                  Form(
                    child: Column(
                      children: [
                        PlacesQuery(
                            placeInfoText: const {},
                            valueCallback: _placeFieldCallback),
                        HashTagTextField(
                          controller: _textAreaController,
                          decoratedStyle: Theme.of(context).textTheme.button,
                          maxLines: 5,
                          maxLength: 200,
                          autofocus: true,
                          basicStyle: Theme.of(context).textTheme.headline3,
                          decoration: InputDecoration(
                            helperStyle: Theme.of(context).textTheme.headline2,
                            border: const OutlineInputBorder(),
                            hintText: "What's your thought?",
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(child: Image.file(imageFile!)),
                ],
              ),
            ),
          );
  }
}
