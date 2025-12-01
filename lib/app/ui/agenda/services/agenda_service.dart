import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:orgtrack/app/data/models/AgendaModel.dart';

class AgendaService {
  final SupabaseClient _client = Supabase.instance.client;
  final String table = 'agenda_organisasi';

  // GET ALL
  Future<List<AgendaOrganisasi>> getAll() async {
    final data = await _client
        .from(table)
        .select()
        .order('date', ascending: true);

    print("GET ALL RESPONSE: $data");

    return (data as List)
        .map((e) => AgendaOrganisasi.fromMap(e))
        .toList();
  }

  // INSERT
  Future<AgendaOrganisasi> create(AgendaOrganisasi agenda) async {
    print("INSERT DATA: ${agenda.toInsertMap()}");

    final res = await _client
        .from(table)
        .insert(agenda.toInsertMap())
        .select()
        .single();

    print("INSERT RESPONSE: $res");

    return AgendaOrganisasi.fromMap(res);
  }

  // UPDATE
  Future<void> update(AgendaOrganisasi agenda) async {
    print("UPDATE: ${agenda.toUpdateMap()}");

    await _client
        .from(table)
        .update(agenda.toUpdateMap())
        .eq('id', agenda.id!);
  }

  // DELETE
  Future<void> delete(int id) async {
    print("DELETE: $id");
    await _client.from(table).delete().eq('id', id);
  }

  // MARK AS READ
  Future<void> markRead(int id, bool value) async {
    await _client
        .from(table)
        .update({'isread': value})
        .eq('id', id);
  }
}
