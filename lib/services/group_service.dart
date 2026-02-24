import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split_expenses/models/settlement.dart';
import 'package:split_expenses/services/notification_service.dart';
import 'package:uuid/uuid.dart';
import '../models/group.dart';
import '../models/participant.dart';
import '../models/expense.dart';
import '../storage/storage_service.dart';
import 'firestore_service.dart';

class GroupService extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();
  List<Group> _groups = [];
  bool _isLoading = false;
  StreamSubscription<QuerySnapshot>? _groupsSubscription;
  final Map<String, StreamSubscription<QuerySnapshot>> _expenseSubscriptions =
      {};
  final Map<String, StreamSubscription<QuerySnapshot>>
  _settlementSubscriptions = {};


  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _groupsSubscription?.cancel();
    for (var subscription in _expenseSubscriptions.values) {
      subscription.cancel();
    }
    _expenseSubscriptions.clear();

    for (var subscription in _settlementSubscriptions.values) {
      subscription.cancel();
    }
    _settlementSubscriptions.clear();

    super.dispose();
  }
  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Cancel existing subscriptions
      _groupsSubscription?.cancel();
      for (var subscription in _expenseSubscriptions.values) {
        subscription.cancel();
      }
      _expenseSubscriptions.clear();

      // Set up real-time listener for groups
      _groupsSubscription = _firestoreService
          .getUserGroups(user.uid)
          .listen(
            (groupsSnapshot) async {
          final firestoreGroups = <Group>[];

          for (final doc in groupsSnapshot.docs) {
            try {
              final data = doc.data() as Map<String, dynamic>;

              // Load participants from members array FIRST
              final memberIds = List<String>.from(data['members'] ?? []);
              final participants = <Participant>[];

              // Look up user info for each member
              for (final memberId in memberIds) {
                try {
                  final userDoc = await _firestoreService.getUserDocument(
                    memberId,
                  );

                  if (userDoc != null && userDoc.exists) {
                    final userData = userDoc.data() as Map<String, dynamic>;
                    participants.add(
                      Participant(
                        id: memberId, // Use uid as participant id
                        name: userData['name'] ?? 'Unknown',
                        email: userData['email'],
                        userId: memberId,
                      ),
                    );
                  } else {
                    // Member not found, create placeholder
                    participants.add(
                      Participant(
                        id: memberId,
                        name: 'Unknown User',
                        userId: memberId,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Error loading user $memberId: $e');
                }
              }

              // Create a map of userId -> participant for quick lookup
              final participantMap = {
                for (var p in participants) p.userId ?? p.id: p,
              };

              // Load expenses for this group
              final expensesSnapshot = await _firestoreService
                  .getGroupExpenses(doc.id)
                  .first;

              final expenses = expensesSnapshot.docs.map((expDoc) {
                final expData = expDoc.data() as Map<String, dynamic>;

                // paidBy and splitWith are now user IDs (Firebase UIDs) from Firestore
                final paidByUserId = expData['paidBy'] ?? '';
                final splitWithUserIds = List<String>.from(
                  expData['splitWith'] ?? [],
                );

                // Convert user IDs to participant IDs for local Expense model
                // Find participant ID from userId (participants use UID as ID)
                final payerParticipant = participantMap[paidByUserId];
                final payerParticipantId =
                    payerParticipant?.id ?? paidByUserId;

                final involvedParticipantIds = splitWithUserIds.map((uid) {
                  final participant = participantMap[uid];
                  return participant?.id ?? uid;
                }).toList();

                return Expense(
                  id: expDoc.id,
                  title: expData['title'] ?? '',
                  amount: (expData['amount'] ?? 0.0).toDouble(),
                  payerId: payerParticipantId,
                  involvedParticipantIds: involvedParticipantIds,
                  date: (expData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  // 🔥 CRITICAL FIX: Agar null hai toh 0 (Equal) pe default karo
                  splitType: SplitType.values[(expData['splitType'] ?? 0) as int],
                  // 🔥 NULL CHECK: Agar customValues nahi hain toh empty map ya null do
                  customValues: expData['customValues'] != null
                      ? (expData['customValues'] as Map).map(
                        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
                  )
                      : null,
                );
              }).toList();

              final settlementsSnapshot = await _firestoreService
                  .getGroupSettlements(doc.id)
                  .first;

              final settlements = settlementsSnapshot.docs.map((setDoc) {
                final data = setDoc.data() as Map<String, dynamic>;
                return Settlement(
                  id: setDoc.id,
                  fromParticipantId: data['from'],
                  toParticipantId: data['to'],
                  amount: (data['amount'] ?? 0).toDouble(),
                  date: (data['createdAt'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                );
              }).toList();


              final group = Group(
                id: doc.id,
                name: data['name'] ?? '',
                participants: participants,
                expenses: expenses,
                settlements: settlements,
                createdAt:
                (data['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              );

              // Save to local Hive for offline access
              await _storageService.addGroup(group);

              firestoreGroups.add(group);

              // Set up real-time listener for expenses of this group
              _expenseSubscriptions[doc.id]?.cancel();
              _expenseSubscriptions[doc
                  .id] = _firestoreService.getGroupExpenses(doc.id).listen((
                  expensesSnapshot,
                  ) async {
                // Rebuild participant map for this group
                final groupIndex = _groups.indexWhere(
                      (g) => g.id == doc.id,
                );
                if (groupIndex == -1) return;

                final currentGroup = _groups[groupIndex];
                final participantMap = {
                  for (var p in currentGroup.participants)
                    p.userId ?? p.id: p,
                };



                // Convert expenses from Firestore (user IDs) to local format (participant IDs)
                final updatedExpenses = expensesSnapshot.docs.map((expDoc) {
                  final expData = expDoc.data() as Map<String, dynamic>;
                  final paidByUserId = expData['paidBy'] ?? '';
                  final splitWithUserIds = List<String>.from(
                    expData['splitWith'] ?? [],
                  );

                  final payerParticipant = participantMap[paidByUserId];
                  final payerParticipantId =
                      payerParticipant?.id ?? paidByUserId;

                  final involvedParticipantIds = splitWithUserIds.map((
                      uid,
                      ) {
                    final participant = participantMap[uid];
                    return participant?.id ?? uid;
                  }).toList();

                  return Expense(
                    id: expDoc.id,
                    title: expData['title'] ?? '',
                    amount: (expData['amount'] ?? 0.0).toDouble(),
                    payerId: payerParticipantId,
                    involvedParticipantIds: involvedParticipantIds,
                    date: (expData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                    // 🔥 CRITICAL FIX: Agar null hai toh 0 (Equal) pe default karo
                    splitType: SplitType.values[(expData['splitType'] ?? 0) as int],
                    // 🔥 NULL CHECK: Agar customValues nahi hain toh empty map ya null do
                    customValues: expData['customValues'] != null
                        ? (expData['customValues'] as Map).map(
                          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
                    )
                        : null,
                  );
                }).toList();



                // Update the group with new expenses
                _groups[groupIndex] = Group(
                  id: currentGroup.id,
                  name: currentGroup.name,
                  participants: currentGroup.participants,
                  expenses: updatedExpenses,
                  settlements: currentGroup.settlements,
                  createdAt: currentGroup.createdAt,
                );

                // Save to local Hive
                await _storageService.addGroup(_groups[groupIndex]);

                notifyListeners();
              });

              // 🔥 SETTLEMENT LISTENER (SEPARATE, PARALLEL)
              _settlementSubscriptions[doc.id]?.cancel();
              _settlementSubscriptions[doc.id] =
                  _firestoreService.getGroupSettlements(doc.id).listen(
                        (snapshot) async {
                      final groupIndex =
                      _groups.indexWhere((g) => g.id == doc.id);
                      if (groupIndex == -1) return;

                      final currentGroup = _groups[groupIndex];

                      final updatedSettlements = snapshot.docs.map((setDoc) {
                        final data = setDoc.data() as Map<String, dynamic>;
                        return Settlement(
                          id: setDoc.id,
                          fromParticipantId: data['from'],
                          toParticipantId: data['to'],
                          amount: (data['amount'] ?? 0).toDouble(),
                          date: (data['createdAt'] as Timestamp).toDate(),
                        );
                      }).toList();

                      _groups[groupIndex] = Group(
                        id: currentGroup.id,
                        name: currentGroup.name,
                        participants: currentGroup.participants,
                        expenses: currentGroup.expenses,
                        settlements: updatedSettlements, // ✅ YAHAN
                        createdAt: currentGroup.createdAt,
                      );

                      await _storageService.addGroup(_groups[groupIndex]);
                      notifyListeners();
                    },
                  );

            } catch (e) {
              debugPrint('Error loading group ${doc.id}: $e');
            }
          }

          _groups = firestoreGroups;
          // Sort by date (newest first)
          _groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error in groups stream: $error');
          // Fallback to local storage
          _groups = _storageService.getAllGroups();
          _groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _isLoading = false;
          notifyListeners();
        },
      );
    } else {
      // Not logged in, use local storage only
      _groups = _storageService.getAllGroups();
      _groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGroup(String name) async {
    final user = FirebaseAuth.instance.currentUser;

    final newGroup = Group(
      id: const Uuid().v4(),
      name: name,
      participants: [],
      expenses: [],
      settlements: [],
      createdAt: DateTime.now(),
    );

    // Local (Hive)
    await _storageService.addGroup(newGroup);

    // Cloud (Firestore) if logged in
    if (user != null) {
      await _firestoreService.upsertGroup(
        id: newGroup.id,
        name: newGroup.name,
        ownerId: user.uid,
        createdAt: newGroup.createdAt,
        memberIds: [user.uid],
      );
    }

    await loadGroups();
  }

  Future<void> deleteGroup(String groupId) async {
    final box = _storageService.getGroupBox();
    await box.delete(groupId);

    // Cancel expense subscription for this group
    _expenseSubscriptions[groupId]?.cancel();
    _expenseSubscriptions.remove(groupId);

    // Also delete from Firestore
    await _firestoreService.deleteGroup(groupId);

    await loadGroups();
  }

  Future<void> addParticipant(
    Group group,
    String name, {
    String? email,
    String? phone,
    String? contactId,
    String? userId,
  }) async {
    final newParticipant = Participant(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      contactId: contactId,
      userId: userId,
    );
    group.participants.add(newParticipant);
    await group.save(); // HiveObject save

    // Update group members in Firestore if logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final memberIds = <String>{
        user.uid,
        ...group.participants
            .where((p) => p.userId != null)
            .map((p) => p.userId!),
      }.toList();

      await _firestoreService.upsertGroup(
        id: group.id,
        name: group.name,
        ownerId: user.uid,
        createdAt: group.createdAt,
        memberIds: memberIds,
      );
    }

    notifyListeners();
  }

  Future<void> addExpense(
      Group group,
      String title,
      double amount,
      String payerId,
      List<String> involvedIds, {
        SplitType splitType = SplitType.equal, // 🔥 NEW
        Map<String, double>? customValues,     // 🔥 NEW
      }) async {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();

    final newExpense = Expense(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      payerId: payerId,
      involvedParticipantIds: involvedIds,
      date: now,
      splitType: splitType, // 🔥 NEW
      customValues: customValues, // 🔥 NEW
    );
    group.expenses.add(newExpense);
    await group.save();

    if (user != null) {
      final payerParticipant = group.participants.firstWhere(
            (p) => p.id == payerId,
        orElse: () => Participant(id: payerId, name: 'Unknown'),
      );
      final paidByUserId = payerParticipant.userId ?? payerId;

      final splitWithUserIds = involvedIds.map((participantId) {
        final participant = group.participants.firstWhere(
              (p) => p.id == participantId,
          orElse: () => Participant(id: participantId, name: 'Unknown'),
        );
        return participant.userId ?? participantId;
      }).toList();

      await _firestoreService.addExpense(
        id: newExpense.id,
        title: newExpense.title,
        amount: newExpense.amount,
        paidBy: paidByUserId,
        splitWith: splitWithUserIds,
        groupId: group.id,
        createdAt: now,
        // 🔥 FIRESTORE MEIN BHI BHEJEIN
        splitType: splitType.index,
        customValues: customValues,
      );

      // Notification bhej do
      if (splitWithUserIds.isNotEmpty) {
        NotificationService.sendExpenseNotification(
          receiverUserIds: splitWithUserIds,
          title: title,
          amount: amount,
          payerName: payerParticipant.name,
        );
      }
    }
    notifyListeners();
  }


  Future<void> deleteExpense(Group group, String expenseId) async {
    group.expenses.removeWhere((e) => e.id == expenseId);
    await group.save();

    // Remove from Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.deleteExpense(
        groupId: group.id,
        expenseId: expenseId,
      );
    }

    notifyListeners();
  }


  /// Calculates net balances: Participant ID -> Amount
  /// Positive: Owed money (Credit)
  /// Negative: Owes money (Debt)
  Map<String, double> getNetBalances(Group group) {
    Map<String, double> balances = {};

    for (var p in group.participants) {
      balances[p.id] = 0.0;
    }

    for (var expense in group.expenses) {
      if (expense.involvedParticipantIds.isEmpty) continue;

      // 🔥 UPDATE: Payer gets full credit
      if (!balances.containsKey(expense.payerId)) balances[expense.payerId] = 0.0;
      balances[expense.payerId] = (balances[expense.payerId] ?? 0.0) + expense.amount;

      // 🔥 UPDATE: Split logic badal gaya
      for (var id in expense.involvedParticipantIds) {
        if (!balances.containsKey(id)) balances[id] = 0.0;

        double debt = 0;
        final type = expense.splitType ?? SplitType.equal;

        if (type == SplitType.equal) {
          debt = expense.amount / expense.involvedParticipantIds.length;
        } else if (type == SplitType.percentage) {
          double pct = expense.customValues?[id] ?? 0.0;
          debt = (expense.amount * pct) / 100;
        } else if (type == SplitType.exact) {
          debt = expense.customValues?[id] ?? 0.0;
        }

        balances[id] = (balances[id] ?? 0.0) - debt;
      }
    }

    for (final settlement in group.settlements) {
      balances[settlement.fromParticipantId] = (balances[settlement.fromParticipantId] ?? 0.0) + settlement.amount;
      balances[settlement.toParticipantId] = (balances[settlement.toParticipantId] ?? 0.0) - settlement.amount;
    }

    return balances;
  }


  /// Returns a list of strings describing debts: "Alice owes Bob $10.00"
  List<String> getSettlements(Group group) {
    Map<String, double> balances = getNetBalances(group);

    List<MapEntry<String, double>> debtors = [];
    List<MapEntry<String, double>> creditors = [];

    balances.forEach((id, amount) {
      if (amount < -0.01) debtors.add(MapEntry(id, amount));
      if (amount > 0.01) creditors.add(MapEntry(id, amount));
    });

    // Sort by magnitude desc (optional heuristic)
    debtors.sort(
      (a, b) => a.value.compareTo(b.value),
    ); // Ascending (most negative first)
    creditors.sort(
      (a, b) => b.value.compareTo(a.value),
    ); // Descending (most positive first)

    List<String> settlements = [];

    int i = 0; // debtors index
    int j = 0; // creditors index

    int safetyCount = 0;
    while (i < debtors.length && j < creditors.length) {
      if (safetyCount++ > 1000) {
        print("Safety break triggered in getSettlements");
        break;
      }

      var debtor = debtors[i];
      var creditor = creditors[j];

      // Amount to settle is min of abs(debt) and credit
      double amount = (-debtor.value) < creditor.value
          ? (-debtor.value)
          : creditor.value;

      // Prevent infinite loop if amount is effectively zero
      if (amount < 0.0001) {
        i++;
        j++;
        continue;
      }

      // Name lookup
      String debtorName = group.participants
          .firstWhere(
            (p) => p.id == debtor.key,
            orElse: () => Participant(id: '?', name: 'Unknown'),
          )
          .name;
      String creditorName = group.participants
          .firstWhere(
            (p) => p.id == creditor.key,
            orElse: () => Participant(id: '?', name: 'Unknown'),
          )
          .name;

      settlements.add(
        "$debtorName owes $creditorName \$${amount.toStringAsFixed(2)}",
      );

      // Adjust remaining
      double remainingDebt = debtor.value + amount;
      double remainingCredit = creditor.value - amount;

      // Update local values for next iteration
      debtors[i] = MapEntry(debtor.key, remainingDebt);
      creditors[j] = MapEntry(creditor.key, remainingCredit);

      // Relaxed thresholds slightly to handle float imprecision
      if (remainingDebt.abs() < 0.001) i++;
      if (remainingCredit < 0.001) j++;
    }

    return settlements;
  }

  Future<void> settleUp({
    required Group group,
    required String fromParticipantId,
    required String toParticipantId,
    required double amount,
  }) async {
    final settlement = Settlement(
      id: const Uuid().v4(),
      fromParticipantId: fromParticipantId,
      toParticipantId: toParticipantId,
      amount: amount,
      date: DateTime.now(),
    );

    // 1️⃣ Local (Hive)
    group.settlements.add(settlement);


    await group.save();

    // 2️⃣ Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.addSettlement(
        groupId: group.id,
        from: fromParticipantId,
        to: toParticipantId,
        amount: amount,
        createdAt: settlement.date,
      );

      // 🟢 NAYA: Notification Trigger
      try {
        // Payer ka naam (Jo paise de raha hai)
        final fromP = group.participants.firstWhere(
          (p) => p.id == fromParticipantId,
          orElse: () => Participant(id: fromParticipantId, name: 'Someone'),
        );

        // Receiver ka data (Jise paise mil rahe hain)
        final toP = group.participants.firstWhere(
          (p) => p.id == toParticipantId,
          orElse: () => Participant(id: toParticipantId, name: 'User'),
        );

        // Receiver ki asli Firebase UID nikal lo
        final receiverUid = toP.userId ?? toParticipantId;
        print("Notification target UID: ${toP.userId}");

        // Agar receiver main khud nahi hoon, toh notification bhej do
        if (receiverUid != user.uid) {
          print("Notification target UID: ${toP.userId}");
          NotificationService.sendSettlementNotification(
            receiverUserId: receiverUid,
            fromName: fromP.name,
            amount: amount,
          );
        }
      } catch (e) {
        debugPrint('Notification bhejne mein error: $e');
      }

    }

    


    notifyListeners();
  }



  // Update Participant
  Future<void> updateParticipant(
    Group group,
    Participant participant, {
    String? newName,
    String? email,
    String? phone,
  }) async {
    final index = group.participants.indexWhere((p) => p.id == participant.id);
    if (index != -1) {
      group.participants[index] = Participant(
        id: participant.id,
        name: newName ?? participant.name,
        email: email ?? participant.email,
        phone: phone ?? participant.phone,
        contactId: participant.contactId,
      );
      await group.save();
      notifyListeners();
    }
  }

  // Delete Participant
  Future<String?> deleteParticipant(Group group, String participantId) async {
    // Check if participant is involved in any expense
    bool isInvolved = group.expenses.any(
      (e) =>
          e.payerId == participantId ||
          e.involvedParticipantIds.contains(participantId),
    );

    if (isInvolved) {
      return "Cannot delete: Participant is part of existing expenses.";
    }

    group.participants.removeWhere((p) => p.id == participantId);
    await group.save();
    notifyListeners();
    return null; // Success
  }


}

