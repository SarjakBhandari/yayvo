import 'package:flutter/material.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreen();
}

class _AddReviewScreen extends State<AddReviewScreen> {
  final List<Map<String, String>> emotions = [
    {"emoji": "😊", "label": "Joy"},
    {"emoji": "😌", "label": "Calm"},
    {"emoji": "🤩", "label": "Excite"},
    {"emoji": "🥰", "label": "Nostalgia"},
    {"emoji": "✨", "label": "Minimalist"},
    {"emoji": "☕", "label": "Cozy"},
    {"emoji": "💎", "label": "Luxurious"},
    {"emoji": "😔", "label": "Disappoint"},
  ];

  List<String> selectedEmotions = [];
  int intensity = 50;
  String sentimentText = "";
  String mentionedProduct = "";

  void toggleEmotion(String label) {
    setState(() {
      if (selectedEmotions.contains(label)) {
        selectedEmotions.remove(label);
      } else {
        selectedEmotions.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canPost = selectedEmotions.isNotEmpty && sentimentText.trim().isNotEmpty;

    return SizedBox.expand(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: const Border(bottom: BorderSide(color: Colors.grey)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text("Share Sentiment"),
                    ElevatedButton(
                      onPressed: canPost ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Your emotional insight has been shared!")),
                        );
                        Navigator.pop(context);
                      } : null,
                      child: const Text("Post"),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Emotion Picker
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("How does this make you feel?"),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                childAspectRatio: 2, // keep square buttons
                              ),
                              itemCount: emotions.length,
                              itemBuilder: (context, index) {
                                final emotion = emotions[index];
                                final isSelected = selectedEmotions.contains(emotion["label"]);
                                return GestureDetector(
                                  onTap: () => toggleEmotion(emotion["label"]!),
                                  child: Container(
                                    padding: const EdgeInsets.all(3), // smaller padding
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? Colors.blue : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          emotion["emoji"]!,
                                          style: const TextStyle(fontSize: 18), // smaller emoji
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          emotion["label"]!,
                                          style: const TextStyle(fontSize: 10), // smaller label
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mood Intensity
                    if (selectedEmotions.isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text("Intensity 🎚️"),
                              Slider(
                                value: intensity.toDouble(),
                                min: 0,
                                max: 100,
                                divisions: 100,
                                label: "$intensity",
                                onChanged: (val) {
                                  setState(() => intensity = val.toInt());
                                },
                              ),
                              Text(
                                intensity < 30
                                    ? "Subtle feeling"
                                    : intensity < 70
                                    ? "Moderate feeling"
                                    : "Intense feeling",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Text Input
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Describe your experience"),
                            const SizedBox(height: 8),
                            TextField(
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: "Share what this product or experience means to you...",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) => setState(() => sentimentText = val),
                            ),
                            const SizedBox(height: 8),
                            Text("${sentimentText.length} characters",
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mention Product
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Mention a Product (optional)"),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.tag),
                                hintText: "e.g., Artisan Coffee Blend",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) => setState(() => mentionedProduct = val),
                            ),
                            const SizedBox(height: 8),
                            const Text("Link your review to a specific product.",
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Media Upload
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Add media (optional)"),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.image),
                                  label: const Text("Add Photo"),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.video_call),
                                  label: const Text("Add Video"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}