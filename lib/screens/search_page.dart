import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<SearchResult> _searchResults = [];
  List<SearchResult> _filteredResults = [];

  // Dummmy data
  final List<SearchResult> _allResults = [
    SearchResult(
      title: 'SHE Logistic',
      subtitle: 'Safety Health Environment Department',
      icon: Icons.local_shipping_outlined,
      iconColor: Color(0xFF4CAF50),
      type: 'Division',
    ),
    SearchResult(
      title: 'Logistic Dispatch',
      subtitle: 'Dispatch and Distribution Center',
      icon: Icons.airport_shuttle_outlined,
      iconColor: Color(0xFF405189),
      type: 'Division',
    ),
    SearchResult(
      title: 'IT Division',
      subtitle: 'Information Technology Department',
      icon: Icons.computer_outlined,
      iconColor: Color(0xFF2196F3),
      type: 'Division',
    ),
    SearchResult(
      title: 'Finance Department',
      subtitle: 'Financial Management Division',
      icon: Icons.account_balance_outlined,
      iconColor: Color(0xFFFF9800),
      type: 'Division',
    ),
    SearchResult(
      title: 'Warehouse A',
      subtitle: 'Main Storage Facility',
      icon: Icons.warehouse_outlined,
      iconColor: Color(0xFF795548),
      type: 'Place',
    ),
    SearchResult(
      title: 'Office Building 1',
      subtitle: 'Administrative Center',
      icon: Icons.business_outlined,
      iconColor: Color(0xFF9C27B0),
      type: 'Place',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchResults = _allResults;
    _filteredResults = [];

    // Auto focus when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterResults(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredResults = [];
      } else {
        _filteredResults = _allResults
            .where((result) =>
                result.title.toLowerCase().contains(query.toLowerCase()) ||
                result.subtitle.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF405189),
      body: Column(
        children: [
          // Top section with search bar
          Container(
            height: screenHeight * 0.25,
            padding: EdgeInsets.only(
              top: statusBarHeight + 10,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: _filterResults,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF405189),
                        size: 22,
                      ),
                      hintText: 'Find',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _filterResults('');
                              },
                              child: const Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 20,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results section
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 20), 
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28), 
                  topRight: Radius.circular(28), 
                ),
              ),
              child:
                  _filteredResults.isEmpty && _searchController.text.isNotEmpty
                      ? _buildNoResults()
                      : _filteredResults.isEmpty
                          ? _buildEmptyState()
                          : _buildResultsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final result = _filteredResults[index];
        return _buildResultItem(result);
      },
    );
  }

  Widget _buildResultItem(SearchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: result.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              result.icon,
              color: result.iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF405189),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF405189).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              result.type,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF405189),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Start searching',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for places, divisions, or assets',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResult {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String type;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.type,
  });
}
