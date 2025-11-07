import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/note_model.dart';
import '../services/supabase_service.dart';

class NoteProvider extends GetxService {
  final SupabaseService _supabaseService = Get.find();

  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await _supabaseService
          .from('notes')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NoteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading notes: $e');
      rethrow;
    }
  }

  Future<void> createNote(NoteModel note) async {
    try {
      await _supabaseService.from('notes').insert(note.toJsonForWrite());
      debugPrint('Note created successfully: ${note.title}');
    } catch (e) {
      debugPrint('Error creating note: $e');
      rethrow;
    }
  }

  Future<void> updateNote(NoteModel note) async {
    final noteId = note.id;
    if (noteId == null) {
      throw ArgumentError('Note ID is required for update');
    }

    try {
      await _supabaseService
          .from('notes')
          .update(note.toJsonForWrite())
          .eq('id', noteId);
      debugPrint('Note updated successfully (ID: $noteId)');
    } catch (e) {
      debugPrint('Error updating note: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _supabaseService.from('notes').delete().eq('id', id);
      debugPrint('Note deleted successfully (ID: $id)');
    } catch (e) {
      debugPrint('Error deleting note: $e');
      rethrow;
    }
  }
}

