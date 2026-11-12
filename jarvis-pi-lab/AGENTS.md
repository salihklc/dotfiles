# jarvis-pi-lab — multi-agent orchestration (pi + Herdr + mlplatform)

Orchestration kit for four **pi** agents in one Herdr workspace. Inference goes through **mlplatform** only (no Cursor agent). Coordination uses **`pi-agents-talk-to-each-other`** — **room name is per project** (`jarvis-pi-<8-char-hash>`); bootstrap prints the exact room. Optional Herdr CLI from the jarvis pane.

## Start (`jarvis` command)

From any clone (no symlink into the repo):

```bash
cd /path/to/your/repo   # e.g. monopd
jarvis                  # uses git root when inside a git repo
jarvis /other/path      # explicit path
jarvis --force          # second workspace for same repo (rare)
```

Kit lives at `~/lab/jarvis-pi-lab` (`JARVIS_PI_KIT`). Herdr workspace **cwd** = project root; agents edit files there. Rules stay in this `AGENTS.md` at the kit path.

Re-run `jarvis` without `--force`: focuses existing workspace, does not spawn duplicate agents.

## Agents

| Role        | Herdr name   | Model                            | Thinking | May edit repo files? |
|-------------|--------------|----------------------------------|----------|----------------------|
| jarvis      | `jarvis`     | `openai/gpt-5.6-sol`             | low      | No (orchestrate only) |
| developer   | `developer`  | `deepseek/deepseek-v4.1-flash`   | high     | Yes                  |
| reviewer    | `reviewer`   | `qwen3.8-125b`                   | low      | No                   |
| analyst     | `analyst`    | `openai/gpt-5.6-luna`            | medium   | No                   |

If `deepseek/deepseek-v4.1-flash` fails to resolve, use `deepseek/deepseek-v4.1-flash-1017`.

## Room setup (after bootstrap)

In **every** pane, once pi is running:

```text
/room connect <ROOM>    # printed at bootstrap (e.g. jarvis-pi-a1b2c3d4)
/room whoami
```

In **jarvis only**:

```text
/room control on
```

Optional default room for new pi sessions on this machine:

```text
/room connect <ROOM> --default
```

After a full pi restart, run `/room control on` again in jarvis (control does not survive new processes).

## jarvis (orchestrator)

You are **Jarvis**. You are the only agent the human talks to for coordination. You do **not** implement features yourself; you delegate.

**Project root** is `PROJECT_ROOT` from your system prompt (where `jarvis` was run), **not** `~/lab/jarvis-pi-lab`. Delegate work that references files under `PROJECT_ROOT`.

On each user request:

1. Classify: bug fix, feature, analysis, or pure Q&A.
2. Run `room_list_agents` and note agent ids for developer, reviewer, analyst (by cwd, model, or prior ids).
3. **Unclear requirements** → `room_send_message` to analyst first; wait for reply to your agent id.
4. **Implementation** → delegate to developer with explicit scope, files, constraints, and definition of done.
5. **After meaningful code changes** → delegate to reviewer with the same scope (diff paths or summary).
6. Merge outcomes into one clear answer for the human (summary + open risks + what was not done).

Delegation template (always include your agent id from `room_whoami`):

```text
<task>. When done or blocked, use room_send_message to reply to agent id <jarvis-id> with results only.
```

- Use `delivery: "followUp"` for normal work.
- Use `delivery: "steer"` only to stop a wrong turn urgently.

Do not use `room_control_agent` on workers unless the human asks.

## developer

You implement code in the **Herdr workspace cwd** (the project where `jarvis` was started). Run tests when relevant. When finished or blocked, message jarvis via `room_send_message` with: what changed, commands run, and blockers.

## reviewer

You review diffs and code quality. Do not edit files. Report: Critical / Warning / Suggestion. Message jarvis when complete.

## analyst

You produce requirements, acceptance criteria, risks, and trade-offs. Do not edit code. Message jarvis when complete.

## Herdr CLI (optional, jarvis pane only)

When `HERDR_ENV=1` and the Herdr skill is loaded, you may use:

```bash
herdr agent list
herdr agent read <name> --source recent-unwrapped --lines 120
herdr agent prompt <name> "..." --wait --timeout 120000
```

Prefer **room** tools for task delegation; use Herdr for visibility and human-visible pane state.

## Smoke test

Human asks jarvis: run orchestration smoke — analyst gives 3 bullet user story, developer creates `hello.txt`, reviewer comments on the change; jarvis summarizes.

## Pane crashed? Re-start pi the Herdr way

`pi --name analyst` only sets the **pi session title** (π status bar). Herdr sidebar name and `herdr agent prompt analyst` need **`herdr agent start`**.

From any terminal (pane must be at a shell prompt; quit pi first if needed):

```bash
cd ~/lab/jarvis-pi-lab
herdr agent start analyst --kind pi --pane wA:p4 -- \
  --name analyst \
  --provider mlplatform \
  --model openai/gpt-5.6-luna \
  --thinking medium
```

Replace `wA:p4` with `herdr pane list --workspace wA | jq '.result.panes[] | select(...)'`.

Then in that pane again:

```text
/room connect <ROOM>
```
