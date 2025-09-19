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

  List<Asset> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;
  String _selectedSearchType = 'all';

  final String baseUrl = 'http://192.168.8.138:8000';

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
      var params = {
        'keyword': query,
        'search_type': _selectedSearchType,
        'per_page': '50',
      };
      final url = Uri.parse('$baseUrl/api/assets/search').replace(queryParameters: params);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> data = [];
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          data = responseData['data'] as List;
        }

        final results = data.map((e) => Asset.fromJson(e)).toList();

        setState(() {
          _searchResults = results;
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
      print('Search error: $e');
    }
  }

  Widget _buildSearchTypeChips() {
    final searchTypes = [
      {'key': 'all', 'label': 'All'},
      {'key': 'name', 'label': 'Name'},
      {'key': 'code', 'label': 'Asset No'},
      {'key': 'category', 'label': 'Category'},
      {'key': 'location', 'label': 'Department'},
      {'key': 'pic', 'label': 'Control Dept'},
      {'key': 'status', 'label': 'Status'},
    ];

    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: searchTypes.length,
        itemBuilder: (context, index) {
          final type = searchTypes[index];
          final isSelected = _selectedSearchType == type['key'];

          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                type['label']!,
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Color(0xFF405189),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSearchType = type['key']!;
                });
                if (_searchController.text.isNotEmpty) {
                  _searchAssets(_searchController.text);
                }
              },
              selectedColor: Color(0xFF405189),
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? Color(0xFF405189) : Color(0xFF405189).withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssetCard(Asset asset) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssetDetailPage(asset: asset),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFF405189).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildAssetImage(asset),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.title,
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    if (asset.assetNo.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF405189).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          asset.assetNo,
                          style: TextStyle(
                            fontFamily: 'Maison Bold',
                            fontSize: 11,
                            color: Color(0xFF405189),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        if (asset.category.isNotEmpty) ...[
                          Icon(Icons.category_outlined, size: 12, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            asset.category,
                            style: TextStyle(
                              fontFamily: 'Maison Book',
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (asset.category.isNotEmpty && asset.department.isNotEmpty) ...[
                          SizedBox(width: 8),
                          Text('•', style: TextStyle(color: Colors.grey[400])),
                          SizedBox(width: 8),
                        ],
                        if (asset.department.isNotEmpty) ...[
                          Icon(Icons.location_on_outlined, size: 12, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              asset.department,
                              style: TextStyle(
                                fontFamily: 'Maison Book',
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(asset.assetStatus).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            asset.assetStatus,
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 10,
                              color: _getStatusColor(asset.assetStatus),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (asset.quantity > 0) ...[
                          SizedBox(width: 8),
                          Icon(Icons.inventory_outlined, size: 12, color: Colors.grey[600]),
                          SizedBox(width: 2),
                          Text(
                            'Qty: ${asset.quantity}',
                            style: TextStyle(
                              fontFamily: 'Maison Book',
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (asset.photosCount != null && asset.photosCount! > 0) ...[
                          SizedBox(width: 8),
                          Icon(Icons.photo_library_outlined, size: 12, color: Colors.grey[600]),
                          SizedBox(width: 2),
                          Text(
                            '${asset.photosCount}',
                            style: TextStyle(
                              fontFamily: 'Maison Book',
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
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

  Widget _buildAssetImage(Asset asset) {
    String? imageUrl = asset.primaryImageUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderIcon();
        },
      );
    } else {
      return _buildPlaceholderIcon();
    }
  }

  Widget _buildPlaceholderIcon() {
    return Icon(
      Icons.inventory_2_outlined,
      color: Color(0xFF405189),
      size: 28,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
      case 'active':
        return Color(0xFF10B981);
      case 'unscanned':
      case 'pending':
        return Color(0xFFF59E0B);
      case 'damaged':
      case 'broken':
        return Color(0xFFEF4444);
      case 'lost':
        return Color(0xFFDC2626);
      case 'maintenance':
        return Color(0xFF8B5CF6);
      case 'available':
        return Color(0xFF059669);
      default:
        return Color(0xFF6B7280);
    }
  }

  Widget _buildResultsList() {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final asset = _searchResults[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
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
              Icon(Icons.search_off_outlined, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No assets found',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search terms\nor change the search filter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Maison Book',
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
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
              Icon(Icons.search_outlined, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Start searching',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Search assets by name, asset no, category,\ndepartment, control dept, or status',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Maison Book',
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontFamily: 'Maison Bold',
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF405189),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Maison Book',
                ),
                decoration: InputDecoration(
                  hintText: _getSearchHint(),
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontFamily: 'Maison Book',
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.search,
                      color: Color(0xFF405189),
                      size: 20,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.clear,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
          Container(
            color: Color(0xFFF8F9FA),
            child: _buildSearchTypeChips(),
          ),
          SizedBox(height: 8),
          if (_searchResults.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_searchResults.length} assets found',
                    style: TextStyle(
                      fontFamily: 'Maison Book',
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Search: ${_selectedSearchType.toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'Maison Bold',
                      fontSize: 11,
                      color: Color(0xFF405189),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF405189),
                    ),
                  )
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

  String _getSearchHint() {
    switch (_selectedSearchType) {
      case 'name':
        return 'Search by asset name...';
      case 'code':
        return 'Search by asset no...';
      case 'category':
        return 'Search by category...';
      case 'location':
        return 'Search by department...';
      case 'pic':
        return 'Search by control department...';
      case 'status':
        return 'Search by status...';
      case 'all':
      default:
        return 'Search assets...';
    }
  }
}