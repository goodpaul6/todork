import {
	App,
	PluginSettingTab,
	Setting,
	Editor,
	Notice,
	EditorPosition,
	MarkdownView,
	Plugin,
} from "obsidian";
import { sortLines } from "src/sorter.gen";

interface PluginSettings {
	indentWidth: 4;
	completedToTop: boolean;
}

const DEFAULT_SETTINGS: PluginSettings = {
	indentWidth: 4,
	completedToTop: true,
};

export default class Todork extends Plugin {
	settings: PluginSettings;

	async onload() {
		await this.loadSettings();

		this.addSettingTab(new SettingTab(this.app, this));

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
				const sortedLines = sortLines(lines, {
					completedToTop: this.settings.completedToTop,
				});

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

export class SettingTab extends PluginSettingTab {
	plugin: Todork;

	constructor(app: App, plugin: Todork) {
		super(app, plugin);
		this.plugin = plugin;
	}

	display(): void {
		let { containerEl } = this;

		containerEl.empty();

		new Setting(containerEl)
			.setName("Task ordering")
			.setDesc(
				"Whether your completed tasks should move to the top or bottom of your list."
			)
			.addDropdown((option) =>
				option
					.addOption("top", "Top")
					.addOption("bottom", "Bottom")
					.setValue(
						this.plugin.settings.completedToTop ? "top" : "bottom"
					)
					.onChange(async (value) => {
						this.plugin.settings.completedToTop = value === "top";
						await this.plugin.saveSettings();
					})
			);
	}
}
