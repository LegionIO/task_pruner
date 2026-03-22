# Changelog

## [0.1.2] - 2026-03-22

### Changed
- Updated `legion-data` dependency constraint to `>= 1.4.15`

## [0.1.1] - 2026-03-18

### Fixed
- `find_expired` status filter now applied (was silently dropped due to missing reassignment)
- `find_expired` uses cross-DB `Sequel.lit` instead of MySQL-specific `DATE_SUB(SYSDATE())`

### Added
- `delete_task(task_id:)` deletes a specific task by ID (was an empty stub)
- `expire_queued(age:, limit:)` marks stuck queued tasks as `task.expired` (was incomplete)
- All three runner methods return structured `{ success:, ... }` result hashes
- 13 new specs for `find_expired`, `delete_task`, and `expire_queued`
- Guard clauses on `include` statements for standalone loading

## [0.1.0]

### Added
- Initial release
