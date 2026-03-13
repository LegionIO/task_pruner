# lex-task_pruner: Task History Cleanup for LegionIO

**Repository Level 3 Documentation**
- **Category**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Legion Extension that prunes old task history records from the LegionIO database. Runs periodically to prevent unbounded growth of task logs and status records.

**GitHub**: https://github.com/LegionIO/task_pruner
**License**: MIT

## Architecture

```
Legion::Extensions::TaskPruner
└── Runners/
    └── Prune              # Executes task history cleanup queries
```

## Key Files

| Path | Purpose |
|------|---------|
| `lib/legion/extensions/task_pruner.rb` | Entry point, extension registration |
| `lib/legion/extensions/task_pruner/runners/prune.rb` | Pruning logic |

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
