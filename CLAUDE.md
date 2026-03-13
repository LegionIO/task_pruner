# lex-task_pruner: Task History Cleanup for LegionIO

**Repository Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-core/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Legion Extension that prunes old task history records from the LegionIO database. Runs periodically to prevent unbounded growth of task logs and status records. Requires `legion-data` (`data_required? true`).

**GitHub**: https://github.com/LegionIO/task_pruner
**License**: MIT
**Version**: 0.1.0

## Architecture

```
Legion::Extensions::TaskPruner
└── Runners/
    └── Prune              # Task cleanup logic (no explicit actor - auto-generated subscription)
        ├── find_expired   # Delete tasks older than N days (default: 31), limited batch size
        ├── delete_task    # Delete a specific task by task_id (stub)
        └── expire_queued  # Query tasks stuck in queued statuses (stub - does not delete)
```

No explicit actors directory - the framework auto-generates a subscription actor for the Prune runner.

## Key Files

| Path | Purpose |
|------|---------|
| `lib/legion/extensions/task_pruner.rb` | Entry point (`data_required? true`) |
| `lib/legion/extensions/task_pruner/runners/prune.rb` | Pruning logic |

## Runner Details

**`find_expired(age: 31, limit: 1000, status: ['task.completed'], **)`**
Deletes task records older than `age` days. Defaults to `task.completed` status, but accepts `'*'` or `nil` to skip status filtering. Uses `DATE_SUB(SYSDATE(), INTERVAL N DAY)`. Runs in batches up to `limit`.

**`delete_task(task_id:, **)`**
Stub - currently empty.

**`expire_queued(age: 1, limit: 10, **)`**
Queries tasks stuck in `conditioner.queued`, `transformer.queued`, or `task.queued` status. Currently assigns the dataset but does not delete (incomplete implementation).

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

---

**Maintained By**: Matthew Iverson (@Esity)
