import 'dart:async';
import 'dart:convert';
import 'package:Simba/screens/home_screen/search_page/asset_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'asset_detail_page.dart'; // Import detail page

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<AssetModel> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchAssets(query);
    });
  }

  Future<void> _searchAssets(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.1.9:8000/api/assets?search=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final results = data.map((e) => AssetModel.fromJson(e)).toList();

        setState(() {
          _searchResults = results.cast<AssetModel>();
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
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
                      'Search Assets',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF405189),
                        size: 22,
                      ),
                      hintText: 'Search asset name, code, category, description, location, pic, status...',
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
                                _onSearchChanged('');
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
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : (_searchResults.isEmpty && _searchController.text.isNotEmpty)
                      ? _buildNoResults()
                      : (_searchResults.isEmpty)
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
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final asset = _searchResults[index];
        return _buildAssetItem(asset);
      },
    );
  }

  Widget _buildAssetItem(AssetModel asset) {
    Color statusColor;
    switch (asset.status.toLowerCase()) {
      case 'registered':
        statusColor = Colors.green;
        break;
      case 'unscanned':
        statusColor = Colors.orange;
        break;
      case 'damage':
        statusColor = Colors.red;
        break;
      case 'lost':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Color(0xFF405189);
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AssetDetailPage(asset: asset)),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 14),
        child: ListTile(
          leading: asset.imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(asset.imageUrl, width: 48, height: 48, fit: BoxFit.cover))
              : Icon(Icons.inventory_2_rounded, color: statusColor, size: 40),
          title: Text(asset.name,
              style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Location: ${asset.location}', style: TextStyle(fontSize: 13)),
              Text('Status: ${asset.status}', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: statusColor)),
              if(asset.category != null && asset.category!.isNotEmpty)
                Text("Category: ${asset.category}", style: TextStyle(fontSize: 12)),
              if(asset.description != null && asset.description!.isNotEmpty)
                Text("Description: ${asset.description}", style: TextStyle(fontSize: 12)),
              if(asset.pic != null && asset.pic!.isNotEmpty)
                Text("PIC: ${asset.pic}", style: TextStyle(fontSize: 12)),
              if(asset.assetCode != null && asset.assetCode!.isNotEmpty)
                Text("Asset Code: ${asset.assetCode}", style: TextStyle(fontSize: 12)),
            ],
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 20, color: statusColor),
        ),
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
            Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text('No results found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text('Try searching with different keywords',
                style: TextStyle(fontSize: 16, color: Colors.grey[500])),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text('Start searching',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text('Search for assets by name, code, category, description, location, pic, status...',
                style: TextStyle(fontSize: 16, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}