import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yayvo/widgets/my_button.dart';
import 'package:yayvo/widgets/my_text_form_field.dart';
import 'package:yayvo/common/show_my_snack_bar.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();


  final List<String> selectedEmotions = [];


  final List<Map<String, String>> emotions = [
    {"name": "Joy", "icon": "assets/icons/joy.png"},
    {"name": "Calm", "icon": "assets/icons/calm.png"},
    {"name": "Excitement", "icon": "assets/icons/excited.png"},
    {"name": "Nostalgia", "icon": "assets/icons/nostalgic.png"},
    {"name": "Minimalist", "icon": "assets/icons/minimalistic.png"},
  ];

  double rating = 3;

  void toggleEmotion(String emotion) {
    setState(() {
      if (selectedEmotions.contains(emotion)) {
        selectedEmotions.remove(emotion);
      } else {
        selectedEmotions.add(emotion);
      }
    });
  }



  void _submitReview() {
    if (_formKey.currentState!.validate()) {
      showMySnackBar(
        context: context,
        message: "Review submitted successfully!",
        status: SnackBarStatus.success,
      );

      _titleController.clear();
      _reviewController.clear();
      selectedEmotions.clear();
      rating = 3;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add Review"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextFormField(
                  controller: _titleController,
                  label: "Title",
                  prefixIcon: Icons.title,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),

                MyTextFormField(
                  controller: _reviewController,
                  label: "Your Review",
                  prefixIcon: Icons.comment,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 24),

                Text(
                  "Add Image",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(12),
                      color: theme.cardColor,
                    ),
                    child: Center(
                      child: Icon(Icons.add_a_photo,
                          size: 40, color: theme.colorScheme.primary),
                    )
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  "Select Emotions",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: emotions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final emotion = emotions[index];
                    final isSelected =
                    selectedEmotions.contains(emotion["name"]);
                    return GestureDetector(
                      onTap: () => toggleEmotion(emotion["name"]!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                            width: 2,
                          ),
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : theme.cardColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              emotion["icon"]!,
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              emotion["name"]!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: MyButton(
                    onPressed: _submitReview,
                    text: "Submit Review",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}