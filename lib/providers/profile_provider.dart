import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/group_service.dart';
import '../services/auth_service.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  // Profile fields
  String? _displayName;
  String? _email;
  bool _isEmailVerified = false;
  DateTime? _memberSince;
  String? _photoUrl;

  // Statistics
  int _totalGroupsJoined = 0;
  int _totalExpensesCreated = 0;
  double _totalAmountPaid = 0.0;
  int _totalSettlementsMade = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _auth.currentUser;
  String get displayName =>
      _displayName ??
      currentUser?.displayName ??
      (currentUser?.email != null ? currentUser!.email!.split('@')[0] : 'User');
  String get email => _email ?? currentUser?.email ?? 'No email';
  bool get isEmailVerified => _isEmailVerified;
  DateTime? get memberSince => _memberSince;
  String? get photoUrl => _photoUrl ?? currentUser?.photoURL;

  int get totalGroupsJoined => _totalGroupsJoined;
  int get totalExpensesCreated => _totalExpensesCreated;
  double get totalAmountPaid => _totalAmountPaid;
  int get totalSettlementsMade => _totalSettlementsMade;

  /// Loads profile info & computes user metrics from groups list
  Future<void> loadProfileData(List<Group> userGroups) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Reload user from server to get fresh emailVerified flag
        try {
          await user.reload();
        } catch (_) {}

        final refreshedUser = _auth.currentUser ?? user;
        _email = refreshedUser.email;
        _isEmailVerified = refreshedUser.emailVerified;
        _displayName = refreshedUser.displayName;
        _photoUrl = refreshedUser.photoURL;

        // Creation time fallback from FirebaseAuth metadata
        _memberSince = refreshedUser.metadata.creationTime;

        // Fetch Firestore profile doc if available
        try {
          final doc = await _db.collection('users').doc(refreshedUser.uid).get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            if (data['name'] != null && (data['name'] as String).isNotEmpty) {
              _displayName = data['name'];
            }
            if (data['photoUrl'] != null && (data['photoUrl'] as String).isNotEmpty) {
              _photoUrl = data['photoUrl'];
            }
            if (data['createdAt'] != null) {
              if (data['createdAt'] is Timestamp) {
                _memberSince = (data['createdAt'] as Timestamp).toDate();
              }
            }
          }
        } catch (e) {
          debugPrint("Error fetching user document from Firestore: $e");
        }

        // Calculate statistics based on userGroups & current user ID/email
        _calculateStatistics(refreshedUser.uid, refreshedUser.email, userGroups);
      }
    } catch (e) {
      _errorMessage = "Failed to load profile details.";
      debugPrint("Error in loadProfileData: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateStatistics(String uid, String? userEmail, List<Group> userGroups) {
    _totalGroupsJoined = userGroups.length;

    int expenseCount = 0;
    double amountPaid = 0.0;
    int settlementCount = 0;

    final lowerEmail = userEmail?.toLowerCase();

    for (final group in userGroups) {
      // Find matching participant id for current user in this group
      String? matchedParticipantId;
      for (final p in group.participants) {
        if (p.userId == uid ||
            (lowerEmail != null &&
                p.email != null &&
                p.email!.toLowerCase() == lowerEmail)) {
          matchedParticipantId = p.id;
          break;
        }
      }

      for (final expense in group.expenses) {
        // Payer can be participant ID, UID, or name match
        bool isPayer = false;
        if (expense.payerId == uid) {
          isPayer = true;
        } else if (matchedParticipantId != null && expense.payerId == matchedParticipantId) {
          isPayer = true;
        }

        if (isPayer) {
          expenseCount++;
          amountPaid += expense.amount;
        }
      }

      for (final settlement in group.settlements) {
        if (settlement.fromParticipantId == uid ||
            settlement.toParticipantId == uid ||
            (matchedParticipantId != null &&
                (settlement.fromParticipantId == matchedParticipantId ||
                    settlement.toParticipantId == matchedParticipantId))) {
          settlementCount++;
        }
      }
    }

    _totalExpensesCreated = expenseCount;
    _totalAmountPaid = amountPaid;
    _totalSettlementsMade = settlementCount;
  }

  /// Edit Full Name (updates Auth displayName, Firestore, AuthService & GroupService in real-time)
  Future<bool> updateName(
    String newName, {
    GroupService? groupService,
    AuthService? authService,
  }) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(trimmed);
        await _db.collection('users').doc(user.uid).set({
          'name': trimmed,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _displayName = trimmed;

        if (authService != null) {
          await authService.refreshUser();
        }

        if (groupService != null) {
          await groupService.updateUserProfileData(
            userId: user.uid,
            newName: trimmed,
            photoUrl: _photoUrl,
          );
          _calculateStatistics(user.uid, user.email, groupService.groups);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = "Failed to update profile name.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update Profile Picture URL (updates Auth photoURL, Firestore, AuthService & GroupService)
  Future<bool> updatePhotoUrl(
    String photoUrl, {
    GroupService? groupService,
    AuthService? authService,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(photoUrl);
        await _db.collection('users').doc(user.uid).set({
          'photoUrl': photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _photoUrl = photoUrl;

        if (authService != null) {
          await authService.refreshUser();
        }

        if (groupService != null) {
          await groupService.updateUserProfileData(
            userId: user.uid,
            newName: displayName,
            photoUrl: photoUrl,
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = "Failed to update profile picture.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change Password
  Future<bool> changePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "Failed to update password.";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Failed to update password. You may need to re-login.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Resend Verification Email
  Future<bool> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = "Failed to send verification email.";
      notifyListeners();
      return false;
    }
  }

  /// Refresh Profile state from server
  Future<void> refresh(List<Group> userGroups) async {
    await loadProfileData(userGroups);
  }
}
