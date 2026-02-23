import 'package:hive_flutter/hive_flutter.dart';
import 'package:split_expenses/models/settlement.dart';
import '../models/group.dart';
import '../models/expense.dart';
import '../models/participant.dart';

class StorageService {
  // NOTE: Box ka naam ek hi jagah se control hona chahiye.
  // Pehle init() me 'groups' open ho raha tha aur getGroupBox() me 'groups_box' access ho raha tha.
  // Is mismatch ki wajah se runtime par box-not-open error aata hai aur UI me groups nahi dikhte.
  static const String boxName = 'groups_box';

  Future<void> init() async {
    await Hive.initFlutter();

    // Sabhi adapters ko registration check ke saath
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(GroupAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ExpenseAdapter());

    // SplitType (ID 2)
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(SplitTypeAdapter());

    // Participant (ID 3)
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ParticipantAdapter());

    // Settlement (Zaroori hai!)
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SettlementAdapter());

    // Box open tabhi karo jab saare adapters register ho jayein
    await Hive.openBox<Group>(boxName);
  }

  Box<Group> getGroupBox() {
    return Hive.box<Group>(boxName);
  }

  // Helper to add a group
  Future<void> addGroup(Group group) async {
    final box = getGroupBox();
    await box.put(group.id, group);
  }

  // Helper to get all groups
  List<Group> getAllGroups() {
    final box = getGroupBox();
    return box.values.toList();
  }

  // Update/Save is handled by HiveObject's save() or strictly putting back in box.
  // Since we use objects, we should be careful to save() if we modify in place.
  // However, for simpler flow, we might just call .save() on the object if it extends HiveObject.
}
