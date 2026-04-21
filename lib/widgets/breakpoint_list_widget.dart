import 'package:flutter/material.dart';
import '../models/breakpoint.dart';

/// Виджет списка точек останова (отдельный элемент списка)
class BreakpointListItem extends StatelessWidget {
  final Breakpoint breakpoint;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const BreakpointListItem({
    super.key,
    required this.breakpoint,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.6),
      child: ListTile(
        title: Text(breakpoint.name),
        subtitle: Text(breakpoint.description),
        onTap: onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// Диалог для добавления/редактирования точки останова
class BreakpointDialog extends StatelessWidget {
  final String title;
  final String initialName;
  final String initialDescription;
  final Function(String name, String description) onConfirm;

  const BreakpointDialog({
    super.key,
    required this.title,
    this.initialName = '',
    this.initialDescription = '',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          String name = initialName;
          String description = initialDescription;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Название'),
                onChanged: (value) => name = value,
                controller: TextEditingController(text: initialName),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Описание'),
                onChanged: (value) => description = value,
                controller: TextEditingController(text: initialDescription),
              ),
            ],
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Отмена'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Сохранить'),
          onPressed: () {
            onConfirm(initialName.isEmpty ? 'Без названия' : initialName,
                initialDescription);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

/// Диалог подтверждения удаления
class ConfirmDeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmDeleteDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Удалить точку'),
      content: const Text('Уверены, что хотите удалить эту точку?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Отмена'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Удалить'),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
