import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';

class ProfilePart extends StatelessWidget {
  final ConsumerEntity user;
  final VoidCallback? onTapCamera;

  const ProfilePart({super.key, required this.user, this.onTapCamera});

  ImageProvider _imageProvider(BuildContext context) {
    final pic = user.profilePicture;
    if (pic == null || pic.isEmpty) return const AssetImage('assets/images/profile.png');
    if (pic.startsWith('http')) return NetworkImage(pic);
    return FileImage(File(pic));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(radius: 56, backgroundImage: _imageProvider(context)),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: onTapCamera,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)]),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(user.fullName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('@${user.username}', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}