/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';
import 'package:supabase/supabase.dart';
import 'package:quickcheck/main.dart';

class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    required this.imageUrl,
    required this.onUpload,
  });

  final String? imageUrl;
  final void Function(String) onUpload;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1,milliseconds: 500),
                          content: Text("Double Tap to change your profile picture."),
                          backgroundColor: Theme.of(context).primaryColorDark,
                        ));
      },
      onDoubleTap: _isLoading ? null : _upload,
      child: Column(
        children: [
          if (widget.imageUrl == null || widget.imageUrl!.isEmpty)
            Container(
              // Later we can add default image based on gender blue and pink one
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    spreadRadius: -30.0,
                  ),
                ],
              ),
              child: ClipOval(
                child: SvgPicture.asset(
                  'assets/icons/malev.svg',
                  width: 250,
                  height: 250,

                ),
              ),
            )
          else
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  replaceBaseUrl(widget.imageUrl!),
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _upload() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (imageFile == null) {
      return;
    }
    if (mounted) {
      setState(() => _isLoading = true);
    }
    final userId = supabase.auth.currentUser!.id;
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;
      await supabase.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: imageFile.mimeType),
          );
      final imageUrlResponse = await supabase.storage
          .from('avatars')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
      widget.onUpload(imageUrlResponse);
      await supabase.rest
          .from('user_profiles')
          .update({'avatar_url': imageUrlResponse}).eq('user_id', userId);
    } on StorageException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unexpected error occurred'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
