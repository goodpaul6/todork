# Todork

This is an Obsidian plugin that formats my flavour of markdown TODO lists.

It transforms something like the following

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

into

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
