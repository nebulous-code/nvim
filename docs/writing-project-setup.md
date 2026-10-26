# Writing Project Setup

How a manuscript repo has to be laid out for the writing layout (`W` on the dashboard, `:WritingLayout`, or `Space W`) and the reverse-outline toggle (`Space ro`) to find everything.

Launch Neovim from the **project root** — every path below is resolved against the current working directory, so starting inside `Manuscript/` leaves the layout empty.

## Directories

Three directory names are hardcoded and case-sensitive.

| Directory | Holds |
|---|---|
| `Manuscript/` | the prose |
| `Reverse Outline/` | one outline per scene, plus the outline template |
| `Meta/` | `Style Guide.md`, opened in the bottom-right pane |

`Reverse Outline` is two words with a space — not a hyphen or an underscore.

Subfolders inside `Manuscript/` and `Reverse Outline/` are fine. Files are found recursively, so organizing by act or part changes nothing.

## File names

Both prose and outline names split on the first **` - `** — space, hyphen, space. Everything before that separator is the **identifier**, and the identifier is what pairs a scene with its outline.

```
Manuscript/C1 S1 - The Gate Opens.md
Reverse Outline/RO C1 S1 - The Gate Opens.md
```

- Prose: `<identifier> - <title>.md`
- Outline: `RO <identifier> - <title>.md`

The `RO ` prefix is capital letters followed by a space. The identifier has to match character for character between the pair; the title after the separator does not, so renaming a scene title on one side will not break the link.

Use a plain hyphen-minus in the separator, not an en dash or em dash.

## Outline template

```
Reverse Outline/RO C_ S_ - Title.md
```

That exact filename. When `Space ro` is pressed in a prose file with no matching outline, this file is copied to `RO <identifier> - <title>.md` and opened, so the template is where the standing structure of an outline lives.

Going the other direction — `Space ro` from an outline with no matching prose file — creates an empty prose file named from the identifier. There is no prose template.

## Full example

```
my-novel/                              <- start nvim here
  Manuscript/
    Act One/
      C1 S1 - The Gate Opens.md
      C1 S2 - Smoke Over Water.md
    Act Two/
      C2 S1 - What the River Kept.md
  Reverse Outline/
    RO C_ S_ - Title.md                <- template
    RO C1 S1 - The Gate Opens.md
    RO C1 S2 - Smoke Over Water.md
  Meta/
    Style Guide.md
```

## What the layout does with it

| Pane | Contents |
|---|---|
| far left | file tree |
| center | the most recently modified `.md` under `Manuscript/`, cursor at the end of the file |
| top right | the reverse outline matching that file |
| bottom right | `Meta/Style Guide.md` |

Picking the most recently modified file is what makes `nvim` then `W` drop you back into whatever you were last working on.

| Key | Action |
|---|---|
| `W` on the dashboard | open the writing layout |
| `Space W` | open the writing layout |
| `Space ro` | jump between the current prose file and its outline, creating the other side if it does not exist |
