import 'package:flutter/material.dart';
import 'widgets/app_header_clean.dart';
import 'package:go_router/go_router.dart';
import 'data/post_store.dart';

class JobsListingPage extends StatefulWidget {
  const JobsListingPage({super.key});

  @override
  State<JobsListingPage> createState() => _JobsListingPageState();
}

class _JobsListingPageState extends State<JobsListingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search jobs by title, location, or description...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF782B)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF782B), width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                // Responsive columns
                int crossAxisCount = 1;
                if (width >= 1200) crossAxisCount = 3;
                else if (width >= 800) crossAxisCount = 2;

                final cardAspect = width < 600 ? 1.7 : 1.6;

                return AnimatedBuilder(
                  animation: PostStore.I,
                  builder: (context, _) {
                    var items = PostStore.I.jobs;
                    
                    // Filter items based on search query
                    if (_searchQuery.isNotEmpty) {
                      items = items.where((job) {
                        return job.title.toLowerCase().contains(_searchQuery) ||
                               job.location.toLowerCase().contains(_searchQuery) ||
                               job.description.toLowerCase().contains(_searchQuery);
                      }).toList();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: cardAspect,
                        ),
                        itemCount: items.isEmpty ? 1 : items.length,
                        itemBuilder: (context, index) {
                          if (items.isEmpty) {
                            // Show message when no results
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.work_off_outlined, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isEmpty ? 'No jobs available' : 'No jobs found matching "$_searchQuery"',
                                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            );
                          }
                          final j = items[index];
                          return _JobCard(
                            title: j.title,
                            date: j.postingDate,
                            description: j.description,
                            location: j.location,
                            jobId: j.id,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final String location;
  final String jobId;

  const _JobCard({
    required this.title,
    required this.date,
    required this.description,
    required this.location,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFFFF782B).withOpacity(0.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/jobs/$jobId'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF782B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.work_outline, color: Color(0xFFFF782B)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                date,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(color: Colors.black87),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFFFF782B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF782B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      jobId,
                      style: const TextStyle(color: Color(0xFFFF782B), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.push('/jobs/$jobId'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF782B)),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
