# git-local

A macOS/Linux tool to hide local changes you don't want to commit (debug prints, config tweaks, AI-generated `.md` files) from `git status` and `git diff` — without `.gitignore`, without stashing. This keeps your IDE's source control view clean as well.

Hidden files are pinned to a specific content snapshot. If a hidden file changes again, it resurfaces in `git status` automatically — so real changes are never accidentally missed.

## Installation

1. Place the `git-local` script somewhere on your `PATH` (e.g. `~/bin/git-local`):
   ```bash
   cp git-local ~/bin/
   chmod +x ~/bin/git-local
   ```

2. Git automatically discovers it as a subcommand — use `git local <command>`.

3. (Recommended) Install `fswatch` for instant file-change detection:
   ```bash
   # macOS
   brew install fswatch
   # Linux
   sudo apt-get install fswatch
   ```
   Without `fswatch`, the daemon falls back to polling every 5 seconds.

4. Install the background daemon so hidden files stay in sync automatically:
   ```bash
   git local service install
   ```

## Usage

Running `git local` with no arguments opens an interactive TUI where you can toggle which files to hide or unhide.

```bash
git local                    # open interactive selector (main workflow)
```

```bash
git local help               # see all commands
```

### Typical workflow

1. You add debug code (e.g. `console.log`) or tweak a local config that you want to keep long-term without polluting `git status`.
2. Run `git local` and select those files — they disappear from `git status`.
3. Keep working. If you make a *real* change to a hidden file, it automatically reappears so you don't miss it.

### Other commands

You won't need `hide`, `show`, or `status` directly — interactive mode covers them. Two commands worth knowing:

- **`git local rehide`** — Re-snapshots and hides all changed files at once. You can also do this from interactive mode.
- **`git local reset`** — Unhides everything and clears all state. A clean slate.

### Disable/enable for branch switching, merging, and rebasing

Git operations like `checkout`, `pull`, `merge`, and `rebase` can fail if a hidden file has conflicts. Stashing won't help since skip-worktree files are invisible to `git stash`. If you hit a conflict, temporarily reveal everything:

```bash
git local disable            # unhide all files, keep the list
git stash                    # stash the now-visible changes
git checkout other-branch    # or pull, merge, rebase, etc.
git stash pop
git local enable             # re-hide everything from the list
```

`disable` preserves your hidden-files list so `enable` can restore it exactly.

## How it works

- **Tracked files:** Uses `git update-index --skip-worktree` to hide changes, paired with a content hash to detect when the file diverges from the hidden snapshot.
- **Untracked files:** Adds entries to `.git/info/exclude` (a local-only gitignore).
- **Background daemon:** Watches hidden files and automatically reveals them when their contents change. Supports `fswatch` (event-driven) or falls back to polling.

All state is local to your machine — primarily stored in `.git/local-hidden`.