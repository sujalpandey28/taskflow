import 'package:flutter/foundation.dart';
import 'package:taskflow/data/models/comment_model.dart';
import 'package:taskflow/data/repositories/task_flowrepository.dart';

enum CommentStatus { initial, loading, loaded, error }

class CommentProvider extends ChangeNotifier {
  final TaskFlowRepository repository;

  CommentProvider({required this.repository});

  CommentStatus _status = CommentStatus.initial;

  CommentStatus get status => _status;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  List<CommentModel> _comments = [];

  List<CommentModel> get comments => List.unmodifiable(_comments);

  Future<void> loadComments(String taskId) async {
    _status = CommentStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await repository.getComments(taskId);

      _status = CommentStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = CommentStatus.error;
      _errorMessage = 'Failed to load comments.';
      notifyListeners();
    }
  }

  Future<bool> createComment(CommentModel comment) async {
    try {
      _errorMessage = null;

      final createdComment = await repository.createComment(comment);

      _comments.add(createdComment);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create comment.';
      notifyListeners();

      return false;
    }
  }

  Future<bool> updateComment(CommentModel comment) async {
    try {
      _errorMessage = null;

      final updatedComment = await repository.updateComment(comment);

      final index = _comments.indexWhere((item) => item.id == comment.id);

      if (index != -1) {
        _comments[index] = updatedComment;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update comment.';
      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      _errorMessage = null;

      await repository.deleteComment(commentId);

      _comments.removeWhere((comment) => comment.id == commentId);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete comment.';
      notifyListeners();

      return false;
    }
  }
}
