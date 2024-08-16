import 'dart:convert';
import 'dart:io';
import 'package:client/constants/app_colors.dart';
import 'package:client/constants/app_dimensions.dart';
import 'package:client/constants/app_styles.dart';
import 'package:client/helpers/asset_images.dart';
import 'package:client/helpers/socket_io.dart';
import 'package:client/services/message_service.dart';
import 'package:client/widgets/appbar_widget.dart';
import 'package:client/widgets/icon_appbar_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path_provider/path_provider.dart';

class ChatMessageScreen extends StatefulWidget {
  const ChatMessageScreen({
    super.key,
    required this.token,
    required this.chat,
  });

  final String token;
  final Map chat;

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  List messages = [];
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    fetchMessages();
    userInfo = JwtDecoder.decode(widget.token);
    socket.emit('join-chat', widget.chat['_id']);
    socket.on(widget.chat['_id'], (message) {
      if (mounted) {
        setState(() {
          messages.add(message);
        });
      }
    });
  }

  fetchMessages() async {
    final response =
        await MessageService.fetchMessages(widget.token, widget.chat['_id']);
    setState(() {
      messages = jsonDecode(response.body);
    });
  }

  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<void> showCaptionDialog(File file) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Caption', style: TextStyle(fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: "Enter caption",
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                "Selected File: ${file.path.split('/').last}",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: AppColors.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Send', style: TextStyle(color: AppColors.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
                sendFile(file, caption: _captionController.text);
                _captionController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  sendMessage() async {
    if (formKey.currentState!.validate()) {
      final reqBody = {
        "chatId": widget.chat['_id'],
        "content": _contentController.text,
      };
      try {
        final response = await MessageService.sendMessage(widget.token, reqBody);
        if (response.statusCode == 200) {
          var decodedResponse = jsonDecode(response.body);
          socket.emit('on-chat', decodedResponse);
          _contentController.clear();
          socket.emit('all', true);
        } else {
          print('Failed to send message: ${response.statusCode}');
        }
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  sendFile(File file, {String? caption}) async {
    Map<String, dynamic> reqBody = {
      "chatId": widget.chat['_id'],
    };
    
    if (caption != null && caption.isNotEmpty) {
      reqBody["caption"] = caption;
    }

    try {
      final response = await MessageService.sendMessage(widget.token, reqBody, file: file);
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        socket.emit('on-chat', decodedResponse);
        socket.emit('all', true);
      } else {
        print('Failed to send file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending file: $e');
    }
  }

  Future<void> _downloadFile(String fileName) async {
    try {
      print(fileName);
      final response = await MessageService.downloadFile(widget.token, fileName);
      if (response.statusCode == 200) {
        // Get the device's external storage directory
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/$fileName';
        
        // Write the file
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to: $filePath')),
        );
      } else {
        print('Failed to download file: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download file')),
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file')),
      );
    }
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        avatar: AssetImages.avatar,
        text: widget.chat['user']['name'] != null ? widget.chat['user']['name'] : 'unknown',
        actions: [
          IconAppBarWidget(
            icon: Icons.more_vert,
            func: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: messages.map((e) {
                    return Container(
                      alignment: e['sender']['_id'] == userInfo['_id']
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      margin: const EdgeInsets.only(
                        bottom: AppDimensions.smallSpacing,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.mediumSpacing),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: e['file'] != null
                          ? Column(
                              children: [
                                Text('File: ${e['file']['originalname']}'),
                                if (e['caption'] != null) Text('Caption: ${e['caption']}'),
                                TextButton(
                                  onPressed: () {
                                    _downloadFile(e['file']['filename']);
                                  },
                                  child: Text('Download'),
                                ),
                              ],
                            )
                          : Text(e['content']),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: AppDimensions.largeSpacing,
              ),
              child: Form(
                key: formKey,
                child: TextFormField(
                  controller: _contentController,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.primaryColor,
                  ),
                  decoration: AppStyles.inputDecoration(
                    'Type message...',
                    null,
                  ).copyWith(
                    prefixIcon: IconButton(
                      splashRadius: AppDimensions.splashRadius,
                      onPressed: () async {
                        File? file = await pickFile();
                        if (file != null) {
                          await showCaptionDialog(file);
                        }
                      },
                      icon: const Icon(Icons.attach_file),
                    ),
                    suffixIcon: IconButton(
                      splashRadius: AppDimensions.splashRadius,
                      onPressed: sendMessage,
                      icon: const Icon(Icons.send),
                    ),
                    suffixIconColor: AppColors.primaryColor,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}