import { Editor, Notice, EditorPosition, MarkdownView, Plugin } from "obsidian";
import { sortLines } from "src/sorter.gen";

// Remember to rename these classes and interfaces!

interface PluginSettings {
	indentWidth: 4;
}

const DEFAULT_SETTINGS: PluginSettings = {
	indentWidth: 4,
};

export default class Todork extends Plugin {
	settings: PluginSettings;

	async onload() {
		await this.loadSettings();

		// This adds an editor command that can perform some operation on the current editor instance
		this.addCommand({
			id: "sort-tasks",
			name: "Sort Tasks",
			editorCallback: (editor: Editor, _view: MarkdownView) => {
				const start: EditorPosition = {
					line: 0,
					ch: 0,
				};

				const lineCount = editor.lineCount();

				const end: EditorPosition = {
					line: lineCount - 1,
					ch: editor.getLine(lineCount - 1).length,
				};

				const text = editor.getRange(start, end);
				const lines = text.split("\n");
				const sortedLines = sortLines(lines);

				editor.replaceRange(sortedLines.join("\n"), start, end);
			},
		});
	}

	onunload() {}

	async loadSettings() {
		this.settings = Object.assign(
			{},
			DEFAULT_SETTINGS,
			await this.loadData()
		);
	}

	async saveSettings() {
		await this.saveData(this.settings);
	}
}
