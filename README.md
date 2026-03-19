# lex-task_pruner

Task history cleanup extension for [LegionIO](https://github.com/LegionIO/LegionIO). Prunes old task history records from the database to prevent unbounded growth of task logs and status records.

## Installation

```bash
gem install lex-task_pruner
```

## Functions

- **find_expired** - Delete completed tasks older than N days (default: 31 days, batch size: 1000)
- **delete_task** - Delete a specific task by ID
- **expire_queued** - Find tasks stuck in queued statuses and update them to `task.expired`

## Configuration

`find_expired` accepts optional parameters:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `age` | `31` | Delete tasks older than this many days |
| `limit` | `1000` | Maximum records to delete per run |
| `status` | `['task.completed']` | Status filter; pass `'*'`, `nil`, or `''` to delete all statuses |

`expire_queued` accepts:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `age` | `1` | Find tasks stuck longer than this many days |
| `limit` | `10` | Maximum records to update per run |

Affected statuses for `expire_queued`: `conditioner.queued`, `transformer.queued`, `task.queued`.

## Requirements

- Ruby >= 3.4
- [LegionIO](https://github.com/LegionIO/LegionIO) framework
- `legion-data` (database access required)

## License

MIT
