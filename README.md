# Todork

![Todork in action](https://github.com/goodpaul6/todork/assets/3721423/59ea0a05-bcf8-4ed4-b36c-9cc35a7148be)

This is an Obsidian plugin that formats my flavour of markdown TODO lists.

## Installation

Todork is not available on the Obsidian community plugins directory. I recommend installing [BRAT](https://tfthacker.com/BRAT)
and pointing it to this repo. 

Alternatively, you can download `main.js` and `manifest.json` from a [release](https://github.com/goodpaul6/todork/releases/latest) into a folder within your `.obsidian/plugins` directory within your vault (e.g. `.obsidian/plugins/todork`).

## Example

```
This is a top-level note.

- [ ] This is a task
- [x] This is a completed task
	- [ ] This is a subtask
		- [x] This is a completed sub-subtask
		- This is a note underneath the task

- [ ] This is a separate "group" of tasks
- [x] It will be formatted separately from the tasks above
```

gets formatted into

```
This is a top-level note.

- [x] This is a completed task
	- [ ] This is a subtask
		- This is a note underneath the task
		- [x] This is a completed sub-subtask
- [ ] This is a task

- [x] It will be formatted separately from the tasks above
- [ ] This is a separate "group" of tasks
```

This is somewhat non-trivial because it has to retain the hierarchy of tasks,
top-level notes, and whitespace.

## Details

The plugin is written in ReScript, and the core formatting logic can be found in `src/sorter.res`. 

Tasks and notes are parsed into a hierarchical record type called `element`.
The hierarchy is determined based on indentation level. Currently counts every 4 spaces or a single
tab character as one indentation level. You can adjust this in the `indentLevel` function.

Once parsed, elements are sorted using the `compareElements` function as a comparator.

Here are the comparison rules at the moment:

- The position of empty lines is maintained
- Notes are sorted before tasks
- Completed tasks are sorted before incomplete tasks

The sorted tasks are then converted back into lines and returned from the `sortLines` function, which
is the only function the Obsidian plugin (located in `main.ts`) calls.
