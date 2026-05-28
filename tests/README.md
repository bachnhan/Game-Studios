# Test Infrastructure

**Engine**: Godot 4.6.3
**Test Framework**: GdUnit4
**CI**: `.github/workflows/tests.yml`
**Setup date**: May 28, 2026

## Directory Layout

```
tests/
  unit/           # Isolated unit tests (formulas, state machines, logic)
  integration/    # Cross-system and save/load tests
  smoke/          # Critical path test list for /smoke-check gate
  evidence/       # Screenshot logs and manual test sign-off records
```

## Running Tests

Since Godot is not installed locally on development machines, tests run automatically on GitHub Actions on push and pull requests.
If you have Godot installed locally, you can run tests with:
```bash
godot --headless --script tests/gdunit4_runner.gd
```

## Test Naming

- **Files**: `[system]_[feature]_test.gd`
- **Functions**: `test_[scenario]_[expected]`
- **Example**: `monster_data_test.gd` → `test_spawn_active_isolates_runtime_state()`

## Story Type → Test Evidence

| Story Type | Required Evidence | Location |
|---|---|---|
| Logic | Automated unit test — must pass | `tests/unit/[system]/` |
| Integration | Integration test OR playtest doc | `tests/integration/[system]/` |
| Visual/Feel | Screenshot + lead sign-off | `tests/evidence/` |
| UI | Manual walkthrough OR interaction test | `tests/evidence/` |
| Config/Data | Smoke check pass | `production/qa/smoke-*.md` |

## CI

Tests run automatically on every push to `main` and on every pull request.
A failed test suite blocks merging.

## Installing GdUnit4 (Local Developer Guide)

1. Open Godot → AssetLib → search "GdUnit4" → Download & Install.
2. Enable the plugin: Project → Project Settings → Plugins → GdUnit4 ✓.
3. Restart the editor.
4. Verify: `res://addons/gdunit4/` exists.
