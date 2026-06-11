import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common/common_widgets.dart';

class CommunityForumScreen extends ConsumerStatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  ConsumerState<CommunityForumScreen> createState() =>
      _CommunityForumScreenState();
}

class _CommunityForumScreenState
    extends ConsumerState<CommunityForumScreen> {
  final _searchCtrl = TextEditingController();
  final List<Map<String, dynamic>> _mockPosts = [
    {
      'id': '1',
      'user_id': 'u1',
      'user_full_name': 'Ravi Kumar',
      'title': 'Best practices for Rice cultivation in Kharif season?',
      'content': 'Looking for advice on managing water levels and fertilizer application for high-yield rice cultivation. Has anyone tried SRI method?',
      'likes_count': 24,
      'comments_count': 12,
      'is_liked': false,
      'tags': ['Rice', 'Kharif', 'Irrigation'],
      'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
    },
    {
      'id': '2',
      'user_id': 'u2',
      'user_full_name': 'Priya Devi',
      'title': 'Tomato leaf curl virus – how to control it effectively?',
      'content': 'My tomato crop is showing severe leaf curl symptoms. Tried neem oil spray but minimal effect. Looking for tested solutions.',
      'likes_count': 38,
      'comments_count': 19,
      'is_liked': true,
      'tags': ['Tomato', 'Disease', 'Virus'],
      'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
    },
    {
      'id': '3',
      'user_id': 'u3',
      'user_full_name': 'Suresh Patel',
      'title': 'Which drip irrigation brand is best for cotton fields?',
      'content': 'Planning to switch from flood to drip irrigation for my 5-acre cotton farm. Budget is around ₹80,000. Any recommendations?',
      'likes_count': 15,
      'comments_count': 7,
      'is_liked': false,
      'tags': ['Cotton', 'Irrigation', 'Equipment'],
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': '4',
      'user_id': 'u4',
      'user_full_name': 'Anita Singh',
      'title': 'Organic fertilizer vs chemical – share your experiences',
      'content': 'I have been doing organic farming for 3 years now. Initial yields were lower but soil health improved drastically. Happy to share my compost recipe!',
      'likes_count': 67,
      'comments_count': 34,
      'is_liked': false,
      'tags': ['Organic', 'Fertilizer', 'Soil Health'],
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': '5',
      'user_id': 'u5',
      'user_full_name': 'Mohan Das',
      'title': 'PM Kisan 17th installment – when to expect?',
      'content': "Anyone received the 17th installment of PM-Kisan yet? I submitted my eKYC but still waiting. What's the process to check status?",
      'likes_count': 91,
      'comments_count': 45,
      'is_liked': true,
      'tags': ['Government Scheme', 'PM-Kisan'],
      'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    },
  ];

  List<Map<String, dynamic>> get _filteredPosts {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _mockPosts;
    return _mockPosts.where((p) {
      return (p['title'] as String).toLowerCase().contains(q) ||
          (p['content'] as String).toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_rounded),
            onPressed: () => _showCreatePost(context),
            tooltip: 'Create Post',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search discussions...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ).animate().fadeIn(),

          // Stats Strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _QuickStat(
                    icon: Icons.people_rounded,
                    value: '12.4K',
                    label: 'Farmers'),
                const SizedBox(width: 12),
                _QuickStat(
                    icon: Icons.forum_rounded,
                    value: '3.2K',
                    label: 'Discussions'),
                const SizedBox(width: 12),
                _QuickStat(
                    icon: Icons.help_rounded,
                    value: '98%',
                    label: 'Answered'),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn(),

          // Posts List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredPosts.length,
              itemBuilder: (_, i) => _PostCard(
                post: _filteredPosts[i],
                onLike: () => setState(() {
                  _filteredPosts[i]['is_liked'] =
                      !(_filteredPosts[i]['is_liked'] as bool);
                  _filteredPosts[i]['likes_count'] =
                      (_filteredPosts[i]['likes_count'] as int) +
                          ((_filteredPosts[i]['is_liked'] as bool) ? 1 : -1);
                }),
              )
                  .animate(delay: Duration(milliseconds: 80 * i))
                  .fadeIn()
                  .slideY(begin: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePost(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    bool posting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx2).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('New Discussion',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx2),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title / Question',
                  hintText: 'Ask your farming question...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  hintText: 'Describe the problem or situation in detail...',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  isLoading: posting,
                  onPressed: () async {
                    if (titleCtrl.text.isEmpty) return;
                    setModal(() => posting = true);
                    final userId = Supabase.instance.client.auth.currentUser?.id;
                    await SupabaseService.createForumPost({
                      'user_id': userId,
                      'user_full_name': 'You',
                      'title': titleCtrl.text,
                      'content': contentCtrl.text,
                      'likes_count': 0,
                      'comments_count': 0,
                      'is_liked': false,
                      'tags': [],
                      'created_at': DateTime.now().toIso8601String(),
                    });
                    setModal(() => posting = false);
                    Navigator.pop(ctx2);
                    setState(() {
                      _mockPosts.insert(0, {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'user_id': userId ?? '',
                        'user_full_name': 'You',
                        'title': titleCtrl.text,
                        'content': contentCtrl.text,
                        'likes_count': 0,
                        'comments_count': 0,
                        'is_liked': false,
                        'tags': [],
                        'created_at': DateTime.now().toIso8601String(),
                      });
                    });
                  },
                  label: 'Post Discussion',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _QuickStat(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryGreen),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(label,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;

  const _PostCard({required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final isLiked = post['is_liked'] as bool;
    final tags = (post['tags'] as List).cast<String>();
    final createdAt = DateTime.parse(post['created_at'] as String);
    final timeAgo = _timeAgo(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author & Time
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                child: Text(
                  (post['user_full_name'] as String)[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['user_full_name'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(timeAgo,
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            post['title'] as String,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 6),

          // Content Preview
          Text(
            post['content'] as String,
            style: TextStyle(
                color: Colors.grey[600], fontSize: 13, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$t',
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          const Divider(height: 16),

          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isLiked ? AppTheme.alertRed : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likes_count']}',
                      style: TextStyle(
                        color: isLiked ? AppTheme.alertRed : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${post['comments_count']} replies',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.bookmark_border_rounded,
                  size: 18, color: Colors.grey[400]),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
