import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class DriveItem {
  final String id;
  String name;
  final bool isFolder;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  
  // For files only
  final int? fileSize;
  final String? mimeType;
  final String? storagePath;
  
  // Local cache for file data (not stored in DB)
  Uint8List? _cachedData;
  
  DriveItem({
    required this.id,
    required this.name,
    required this.isFolder,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.fileSize,
    this.mimeType,
    this.storagePath,
    Uint8List? cachedData,
  }) : _cachedData = cachedData;
  
  factory DriveItem.fromMap(Map<String, dynamic> map) {
    return DriveItem(
      id: map['id'] as String,
      name: map['name'] as String,
      isFolder: map['is_folder'] as bool,
      parentId: map['parent_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toLocal(),
      createdBy: map['created_by'] as String?,
      fileSize: map['file_size'] as int?,
      mimeType: map['mime_type'] as String?,
      storagePath: map['storage_path'] as String?,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'is_folder': isFolder,
      'parent_id': parentId,
      'file_size': fileSize,
      'mime_type': mimeType,
      'storage_path': storagePath,
    };
  }
  
  Uint8List? get cachedData => _cachedData;
  set cachedData(Uint8List? data) => _cachedData = data;
}

class CompanyDriveService extends ChangeNotifier {
  List<DriveItem> _allItems = [];
  bool _isLoading = false;
  String? _error;
  
  List<DriveItem> get allItems => List.unmodifiable(_allItems);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  CompanyDriveService() {
    _init();
  }
  
  Future<void> _init() async {
    await fetchAll();
    
    // Subscribe to realtime changes
    try {
      SupabaseConfig.client
          .from('drive_items')
          .stream(primaryKey: ['id'])
          .listen(
            (data) {
              debugPrint('CompanyDrive: Received ${data.length} items from stream');
              _allItems = data.map((e) => DriveItem.fromMap(e)).toList();
              notifyListeners();
            },
            onError: (error) {
              debugPrint('CompanyDrive stream error: $error');
              _error = error.toString();
              notifyListeners();
            },
          );
    } catch (e) {
      debugPrint('CompanyDrive: Error setting up stream: $e');
    }
  }
  
  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await SupabaseConfig.client
          .from('drive_items')
          .select()
          .order('created_at', ascending: true);
      
      _allItems = (response as List).map((e) => DriveItem.fromMap(e)).toList();
      debugPrint('CompanyDrive: Fetched ${_allItems.length} items');
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching drive items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get children of a folder (or root if parentId is null)
  List<DriveItem> getChildren(String? parentId) {
    return _allItems.where((item) => item.parentId == parentId).toList();
  }
  
  // Get item by ID
  DriveItem? getById(String id) {
    try {
      return _allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Create folder
  Future<DriveItem?> createFolder({
    required String name,
    String? parentId,
  }) async {
    try {
      debugPrint('Creating folder: $name in parent: $parentId');
      
      final result = await SupabaseConfig.client
          .from('drive_items')
          .insert({
            'name': name,
            'is_folder': true,
            'parent_id': parentId,
          })
          .select()
          .single();
      
      final item = DriveItem.fromMap(result);
      debugPrint('Folder created: ${item.id}');
      return item;
    } catch (e) {
      debugPrint('Error creating folder: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // Upload file
  Future<DriveItem?> uploadFile({
    required String name,
    required Uint8List data,
    required String mimeType,
    String? parentId,
  }) async {
    try {
      debugPrint('Uploading file: $name (${data.length} bytes)');
      
      // Generate unique storage path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'files/$timestamp-$name';
      
      // Upload to Supabase Storage
      await SupabaseConfig.client.storage
          .from('company-drive')
          .uploadBinary(storagePath, data);
      
      debugPrint('File uploaded to storage: $storagePath');
      
      // Create database record
      final result = await SupabaseConfig.client
          .from('drive_items')
          .insert({
            'name': name,
            'is_folder': false,
            'parent_id': parentId,
            'file_size': data.length,
            'mime_type': mimeType,
            'storage_path': storagePath,
          })
          .select()
          .single();
      
      final item = DriveItem.fromMap(result);
      item.cachedData = data; // Cache the data locally
      debugPrint('File record created: ${item.id}');
      return item;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // Download file data
  Future<Uint8List?> downloadFile(DriveItem item) async {
    if (item.isFolder || item.storagePath == null) return null;
    
    // Return cached data if available
    if (item.cachedData != null) {
      debugPrint('Returning cached data for: ${item.name}');
      return item.cachedData;
    }
    
    try {
      debugPrint('Downloading file: ${item.name} from ${item.storagePath}');
      
      final data = await SupabaseConfig.client.storage
          .from('company-drive')
          .download(item.storagePath!);
      
      // Cache the data
      item.cachedData = data;
      debugPrint('File downloaded: ${data.length} bytes');
      return data;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // Rename item
  Future<bool> rename(String id, String newName) async {
    try {
      debugPrint('Renaming item $id to: $newName');
      
      await SupabaseConfig.client
          .from('drive_items')
          .update({'name': newName})
          .eq('id', id);
      
      debugPrint('Item renamed successfully');
      return true;
    } catch (e) {
      debugPrint('Error renaming item: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Delete item (and its children if folder)
  Future<bool> delete(String id) async {
    try {
      final item = getById(id);
      if (item == null) return false;
      
      debugPrint('Deleting item: ${item.name} (${item.id})');
      
      // If it's a file, delete from storage first
      if (!item.isFolder && item.storagePath != null) {
        try {
          await SupabaseConfig.client.storage
              .from('company-drive')
              .remove([item.storagePath!]);
          debugPrint('File deleted from storage: ${item.storagePath}');
        } catch (e) {
          debugPrint('Error deleting file from storage: $e');
          // Continue with DB deletion even if storage deletion fails
        }
      }
      
      // Delete from database (CASCADE will handle children)
      await SupabaseConfig.client
          .from('drive_items')
          .delete()
          .eq('id', id);
      
      debugPrint('Item deleted from database');
      return true;
    } catch (e) {
      debugPrint('Error deleting item: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Search items by name
  List<DriveItem> search(String query) {
    if (query.trim().isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _allItems
        .where((item) => item.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
  
  // Get full path for an item
  List<DriveItem> getPath(String? itemId) {
    if (itemId == null) return [];
    
    final path = <DriveItem>[];
    String? currentId = itemId;
    
    while (currentId != null) {
      final item = getById(currentId);
      if (item == null) break;
      path.insert(0, item);
      currentId = item.parentId;
    }
    
    return path;
  }
  
  // Get total size of all files
  int getTotalSize() {
    return _allItems
        .where((item) => !item.isFolder)
        .fold(0, (sum, item) => sum + (item.fileSize ?? 0));
  }
  
  // Count items
  int get folderCount => _allItems.where((item) => item.isFolder).length;
  int get fileCount => _allItems.where((item) => !item.isFolder).length;
}
