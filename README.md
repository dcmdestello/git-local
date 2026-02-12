# git-local

A lightweight tool to keep local debug changes (print statements, config tweaks) out of your git status/diffs, while still allowing you to modify those files.

It uses `git update-index --skip-worktree` combined with a content-hash check to conditionally hide files **only when they match a specific "debug" state**. If you make further changes, they automatically reappear in `git status`.

## Installation

1.  Clone this repo:
    ```bash
    git clone https://github.com/yourname/git-local.git
    cd git-local
    ```

2.  Run the deploy script (installs to `~/bin/git-local`):
    ```bash
    ./deploy.sh
    ```

3.  (Highly Recommended) Install `fswatch` for instant background updates:
    ```bash
    brew install fswatch
    ```
    *Without fswatch, the background watcher falls back to polling every 3 seconds.*

## Usage

### 1. Mark files to hide
Add your debug code (e.g. `print("DEBUG")`), then run:

```bash
git local mark file.py       # Mark specific file
git local mark .             # Mark all modified files in current dir
git local mark               # Open interactive selection menu
```

These files will vanish from `git status` and `git diff`.
**This automatically starts a background watcher for this repo.**

### 2. Working with marked files
- **No changes:** File remains hidden.
- **You make a REAL change:** The watcher detects the file change -> verifies hash -> reveals file in `git status`.
- **You undo the real change:** The watcher detects change -> verifies hash -> hides file again.

### 3. Unmarking
To stop hiding a file and commit it (or just clean up):

```bash
git local unmark file.py
git local unmark .           # Unmark all in current dir
```

**If you unmark the last file, the background watcher stops automatically.**

### 4. Status
Check what's currently hidden and if the watcher is running:

```bash
git local status   # or 'git local ls'
```
Example output:
```
Watcher: RUNNING (PID 12345)

FILE          STATE     HASH
----          -----     ----
utils.py      hidden    a1b2c3d4
```

### 5. Managing the Watcher
The watcher runs in the background (daemonized) per repository.

- **Auto-Start:** Happens automatically when you `mark` files.
- **Auto-Stop:** Happens automatically when you `unmark` all files.
- **Manual Control:**
  ```bash
  git local watch   # Start watcher manually (if stopped)
  git local stop    # Stop watcher manually
  ```

**Important:** If you reboot your computer, the background watcher will die. Run `git local status` to check, and `git local watch` to restart it.

## Commands Reference

| Command | Description |
|---|---|
| `mark [files...]` | Snapshot content, hide from git, and **start watcher**. No args = interactive. |
| `unmark [files...]` | Unhide, stop tracking, and **stop watcher** if empty. |
| `ls` / `status` | Show marked files and watcher status. |
| `watch` | Manually start the background watcher. |
| `stop` | Manually stop the background watcher. |
| `sync` | One-off check (useful if you don't want the watcher running). |

## FAQ

**Q: What if I switch branches?**
A: **Dangerous.** `git checkout` can get confused by hidden files. Recommended workflow:
1. `git local unmark .` (or stash changes)
2. `git checkout other-branch`
3. Re-apply debug changes & `git local mark .`

**Q: Does this modify `.gitignore`?**
A: No. It uses `.git/local-marks` to track state and `git update-index` to hide files. It is purely local to your repo.

**Q: Why do I need fswatch?**
A: Without it, the background process has to wake up every 3 seconds to check file hashes. With `fswatch`, it sleeps until a file actually changes, which is better for battery and performance.
