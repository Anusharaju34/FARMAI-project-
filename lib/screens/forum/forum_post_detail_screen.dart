import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class ForumPostDetailScreen extends StatefulWidget {
  const ForumPostDetailScreen({super.key});

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  final _commentCtrl = TextEditingController();
  int _likesCount = 15;
  bool _isLiked = true;

  final List<Map<String, dynamic>> _replies = [
    {
      'author': 'Dr. Ramesh (Agronomist)',
      'role': 'Expert',
      'content': 'You can apply well-decomposed Neem Cake at 250 kg/acre. It acts as both a nutrient source and helps control soil nematodes.',
      'likes': 8,
      'time': '1d ago',
      'isExpert': true,
    },
    {
      'author': 'Sanjay Patel',
      'role': 'Farmer',
      'content': 'Vermicompost has worked wonders for my tomatoes. Apply about 2-3 kg per plant and water immediately.',
      'likes': 3,
      'time': '18h ago',
      'isExpert': false,
    },
    {
      'author': 'Gita Rao',
      'role': 'Farmer',
      'content': 'Make sure you also check the soil pH before applying heavy compost. Tomatoes do best around 6.0 to 6.8 pH.',
      'likes': 1,
      'time': '4h ago',
      'isExpert': false,
    },
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentCtrl.text.isEmpty) return;
    setState(() {
      _replies.add({
        'author': 'You (Farmer)',
        'role': 'Farmer',
        'content': _commentCtrl.text,
        'likes': 0,
        'time': 'Just now',
        'isExpert': false,
      });
      _commentCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FarmAIAppBar(
        title: 'Forum Thread',
        showBack: true,
      ),
      body: Column(
        children: [
          // Main Thread Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original Post Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppTheme.primaryGreen,
                              child: Text('AK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Anil Kumar',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                Text(
                                  'Salem, Tamil Nadu · 2d ago',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Best organic fertilizer for Tomato crop?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Suggest good organic options to improve yield. Soil is loamy and nitrogen levels seem slightly low. Looking for home-made or easily accessible market alternatives.',
                          style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey[800]),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Tomato', style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Fertilizer', style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLiked = !_isLiked;
                                  if (_isLiked) {
                                    _likesCount++;
                                  } else {
                                    _likesCount--;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    _isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                                    color: _isLiked ? AppTheme.primaryGreen : Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$_likesCount Likes',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _isLiked ? AppTheme.primaryGreen : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Icon(Icons.comment_rounded, color: Colors.grey[400], size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${_replies.length} Replies',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Replies & Solutions').animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 12),

                  // Replies List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _replies.length,
                    itemBuilder: (context, i) {
                      final r = _replies[i];
                      final isExpert = r['isExpert'] as bool;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isExpert ? AppTheme.primaryGreen.withOpacity(0.04) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isExpert ? AppTheme.primaryGreen.withOpacity(0.2) : Colors.grey[200]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  r['author'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: isExpert ? AppTheme.primaryGreen : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isExpert)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('EXPERT', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                                  ),
                                const Spacer(),
                                Text(
                                  r['time'] as String,
                                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              r['content'] as String,
                              style: const TextStyle(fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),
          ),

          // Bottom comment input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add an answer or comment...',
                      filled: true,
                      fillColor: AppTheme.surfaceLight,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send_rounded, color: AppTheme.primaryGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
