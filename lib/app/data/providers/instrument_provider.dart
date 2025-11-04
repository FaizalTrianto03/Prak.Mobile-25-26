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

      print('Successfully loaded ${instruments.length} instruments');
      return instruments;
    } catch (e) {
      print('Error loading instruments: $e');
      rethrow;
    }
  }

  // Create instrument
  Future<void> createInstrument(InstrumentModel instrument) async {
    try {
      await _supabaseService
          .from('instruments')
          .insert(instrument.toJsonForInsert());
      print('Instrument added successfully: ${instrument.name}');
    } catch (e) {
      print('Error adding instrument: $e');
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
      print(
          'Instrument updated successfully (ID: ${instrument.id}): ${instrument.name}');
    } catch (e) {
      print('Error updating instrument: $e');
      rethrow;
    }
  }

  // Delete instrument
  Future<void> deleteInstrument(int id) async {
    try {
      await _supabaseService.from('instruments').delete().eq('id', id);
      print('Instrument deleted successfully (ID: $id)');
    } catch (e) {
      print('Error deleting instrument: $e');
      rethrow;
    }
  }
}
