# lex-task_pruner: Task History Cleanup for LegionIO

**Repository Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-core/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Legion Extension that prunes old task history records from the LegionIO database. Runs periodically to prevent unbounded growth of task logs and status records. Requires `legion-data` (`data_required? true`).

**GitHub**: https://github.com/LegionIO/task_pruner
**License**: MIT
**Version**: 0.1.1

## Architecture

```
Legion::Extensions::TaskPruner
└── Runners/
    └── Prune              # Task cleanup logic (no explicit actor - auto-generated subscription)
        ├── find_expired   # Delete tasks older than N days (default: 31), limited batch size
        ├── delete_task    # Delete a specific task by task_id
        └── expire_queued  # Mark stuck queued tasks as task.expired
```

No explicit actors directory - the framework auto-generates a subscription actor for the Prune runner.

## Key Files

| Path | Purpose |
|------|---------|
| `lib/legion/extensions/task_pruner.rb` | Entry point (`data_required? true`) |
| `lib/legion/extensions/task_pruner/runners/prune.rb` | Pruning logic |

## Runner Details

**`find_expired(age: 31, limit: 1000, status: ['task.completed'], **)`**
Deletes task records older than `age` days using `Sequel.lit('created <= ?', cutoff)` for cross-DB compatibility. Runs in batches up to `limit`. Status filter is applied unless `status` is `'*'`, `nil`, or empty string.

**`delete_task(task_id:, **)`**
Deletes a specific task by primary key. Returns `{ success: false, error: 'task not found' }` if missing.

**`expire_queued(age: 1, limit: 10, **)`**
Finds tasks stuck in `conditioner.queued`, `transformer.queued`, or `task.queued` status older than `age` days and updates their status to `task.expired`.

## Dependencies

| Gem | Purpose |
|-----|---------|
| `legion-data` | Database access for task history tables |

## Testing

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

Spec count: 14 examples

---

**Maintained By**: Matthew Iverson (@Esity)
