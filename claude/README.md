# Claude Code settings kept with the flake

| Path | What it is |
| --- | --- |
| `mcp-servers.json` | The MCP servers Claude Code should have (user scope) |
| `npm-tools.txt` | Programs installed with npm (into `~/.npm-global`), one `name@version` per line. Now: `@nanonets/graft` |
| `skills/<name>/SKILL.md` | Your skills, one folder each. Skills taken from other people's repositories keep their licence file and a `NOTICE.md` that says where they came from |

Skills installed so far: `tech-guidelines` (the `karpathy-guidelines` skill from forrestchang/andrej-karpathy-skills, renamed), `frontend-design` (Anthropic's skills repository), `caveman` (juliusbrussee/caveman, only this one skill), `matt-code-review` (his code-review, renamed because Claude Code has a built-in skill of that name), `codebase-design` and `diagnosing-bugs` (mattpocock/skills).

Everything below happens by itself: the flake installs Claude Code (`claude-code` in `home/packages.nix`) and a small service (`home/claude-sync.nix`) runs `claude-sync auto` at every login, and again whenever Claude Code is installed or updated. It sets up the skills, the npm programs and the MCP servers from this folder, skips what is already done, and retries in a few minutes when there is no network. You only log in to Claude once. The commands, for doing it by hand:

- `~/.scripts/claude-sync apply` puts the servers from `mcp-servers.json` into Claude Code and links every skill from `skills/` into `~/.claude/skills/`. Run it after a fresh install, or after editing the files here. `claude-sync tools` installs only the npm programs, `claude-sync skills` does only the skills, `claude-sync mcp [name]` only the servers (all, or the ones you name).
- `~/.scripts/claude-sync save` copies the servers you added with `claude mcp add` back into `mcp-servers.json`, so they are saved with the flake. Values under `env` and `headers` are replaced by `${NAME}` placeholders, so keys and tokens are not written here. Read the file once before you push it.

Never put an API key or token in these files: this folder is copied into the Nix store (readable by every user of the machine) and into the GitHub repo.

The skills that Anthropic syncs from your account (`~/.claude/skills/synced/`) are not kept here: they come back by themselves when you log in, and they are Anthropic's, not yours to publish.

## graft

`graft` is installed with npm (`npm-tools.txt`), its MCP server is in `mcp-servers.json` and its `/graft` skill is in `skills/graft/`, so it works in every folder. It builds nothing by itself. In a project where you want it, run `graft init --agents claude --no-global` once: that builds the map and adds the statusline and the hooks that keep the map fresh to that project's `.claude/`. Do not use `graft init` without `--no-global`: the machine-wide hooks it adds would create a `graft/.cache` folder in every folder you open Claude in.
