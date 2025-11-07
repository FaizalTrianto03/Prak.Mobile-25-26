import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/instrument_model.dart';
import '../services/supabase_service.dart';

class InstrumentProvider extends GetxService {
  final SupabaseService _supabaseService = Get.find();

  // Get all instruments
  Future<List<InstrumentModel>> getInstruments() async {
    try {
      final response = await _supabaseService
          .from('instruments')
          .select()
          .order('id', ascending: true);

      final List<InstrumentModel> instruments = (response as List)
          .map((json) => InstrumentModel.fromJson(json))
          .toList();

      debugPrint('Successfully loaded ${instruments.length} instruments');
      return instruments;
    } catch (e) {
      debugPrint('Error loading instruments: $e');
      rethrow;
    }
  }

  // Create instrument
  Future<void> createInstrument(InstrumentModel instrument) async {
    try {
      await _supabaseService
          .from('instruments')
          .insert(instrument.toJsonForInsert());
      debugPrint('Instrument added successfully: ${instrument.name}');
    } catch (e) {
      debugPrint('Error adding instrument: $e');
      rethrow;
    }
  }

  // Update instrument
  Future<void> updateInstrument(InstrumentModel instrument) async {
    try {
      await _supabaseService
          .from('instruments')
          .update(instrument.toJsonForInsert())
          .eq('id', instrument.id!);
      debugPrint(
        'Instrument updated successfully (ID: ${instrument.id}): ${instrument.name}',
      );
    } catch (e) {
      debugPrint('Error updating instrument: $e');
      rethrow;
    }
  }

  // Delete instrument
  Future<void> deleteInstrument(int id) async {
    try {
      await _supabaseService.from('instruments').delete().eq('id', id);
      debugPrint('Instrument deleted successfully (ID: $id)');
    } catch (e) {
      debugPrint('Error deleting instrument: $e');
      rethrow;
    }
  }
}
