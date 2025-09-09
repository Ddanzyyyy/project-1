import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'asset_model.dart';
import 'asset_detail_page.dart';

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
    _debounce = Timer(const Duration(milliseconds: 400), () {
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

  Widget _buildAssetCard(AssetModel asset) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssetDetailPage(asset: asset),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Asset Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(0xFF405189).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: asset.imageUrl.isNotEmpty
                      ? Image.network(
                          asset.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.inventory_2_outlined,
                              color: Color(0xFF405189),
                              size: 24,
                            );
                          },
                        )
                      : Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF405189),
                          size: 24,
                        ),
                ),
              ),
              SizedBox(width: 12),
              // Asset Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    if (asset.category != null && asset.category!.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF405189).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          asset.category!,
                          style: TextStyle(
                            fontFamily: 'Maison Bold',
                            fontSize: 10,
                            color: Color(0xFF405189),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    SizedBox(height: 2),
                    if (asset.description != null && asset.description!.isNotEmpty)
                      Text(
                        asset.description!,
                        style: TextStyle(
                          fontFamily: 'Maison Book',
                          color: Colors.grey[600],
                          fontSize: 11,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(12),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final asset = _searchResults[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: _buildAssetCard(asset),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
              SizedBox(height: 12),
              Text(
                'No assets found',
                style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Try adjusting your search',
                style: TextStyle(
                    fontFamily: 'Maison Book',
                    fontSize: 13,
                    color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_outlined, size: 48, color: Colors.grey[400]),
              SizedBox(height: 12),
              Text(
                'Start searching',
                style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Search assets by title/name only.',
                style: TextStyle(
                    fontFamily: 'Maison Book',
                    fontSize: 13,
                    color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF405189),
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search Asset',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            fontFamily: 'Maison Bold',
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF405189),
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, statusBarHeight + 8, 12, 16),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: _onSearchChanged,
                  style: TextStyle(fontSize: 14, fontFamily: 'Maison Book'),
                  decoration: InputDecoration(
                    hintText: 'Search asset title...',
                    hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontFamily: 'Maison Book'),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.search,
                          color: Color(0xFF405189), size: 18),
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: Icon(Icons.clear,
                                color: Colors.grey, size: 20),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : (_searchResults.isEmpty && _searchController.text.isNotEmpty)
                    ? _buildNoResults()
                    : (_searchResults.isEmpty)
                        ? _buildEmptyState()
                        : _buildResultsList(),
          ),
        ],
      ),
    );
  }
}