import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart'; // ✅ FIXED IMPORT

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final SupabaseService _service = SupabaseService();

  List<Map<String, dynamic>> images = [];

  bool loading = true;
  bool loadingMore = false;

  int limit = 12;
  int offset = 0;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  /// ===============================
  /// 📥 INITIAL LOAD
  /// ===============================
  Future<void> loadImages() async {
    setState(() => loading = true);

    final data =
        await _service.fetchDetectionsPaginated(limit, offset);

    setState(() {
      images = data;
      offset = data.length;
      loading = false;
    });
  }

  /// ===============================
  /// ➕ LOAD MORE
  /// ===============================
  Future<void> loadMore() async {
    setState(() => loadingMore = true);

    final data =
        await _service.fetchDetectionsPaginated(limit, offset);

    setState(() {
      images.addAll(data);
      offset = offset + data.length; // ✅ FIXED TYPE ISSUE
      loadingMore = false;
    });
  }

  /// ===============================
  /// 🗑 DELETE IMAGE
  /// ===============================
  Future<void> deleteImage(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Image"),
        content: const Text(
            "Are you sure you want to delete this image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    /// 🔥 DELETE FROM STORAGE + DB
    await _service.deleteImageFromStorage(item['image_url']);
    final success = await _service.deleteDetection(item['id']);

    if (success) {
      setState(() {
        images.removeWhere((e) => e['id'] == item['id']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image deleted")),
      );
    }
  }

  /// ===============================
  /// 🧾 DETAILS
  /// ===============================
  void showDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Detection Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Disease: ${item['disease'] ?? 'N/A'}"),
            Text("Severity: ${item['severity'] ?? 'N/A'}"),
            Text("Confidence: ${item['confidence'] ?? 'N/A'}%"),
            Text("Date: ${item['created_at'] ?? 'N/A'}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteImage(item);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// UI
  /// ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Gallery"),
        backgroundColor: Colors.green,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                /// ================= GRID =================
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final item = images[index];

                      return GestureDetector(
                        onTap: () => showDetails(item),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      item['image_url']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            /// QUICK DELETE BUTTON
                            Positioned(
                              right: 4,
                              top: 4,
                              child: GestureDetector(
                                onTap: () => deleteImage(item),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.delete,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// ================= LOAD MORE =================
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: loadingMore
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: loadMore,
                          child: const Text("Load More"),
                        ),
                ),
              ],
            ),
    );
  }
}