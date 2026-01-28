import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/group_model.dart';
import '../data/verbs_repository.dart';

final groupsProvider = FutureProvider<List<GroupModel>>((ref) async {
  final repo = VerbsRepository();
  return repo.loadGroups();
});

/// Selected group (set when user taps a group). Used by mode/count and session screens.
final selectedGroupProvider = StateProvider<GroupModel?>((ref) => null);
