var editor = ace.edit("input", {
    mode: "ace/mode/r",
    selectionStyle: "text",
    maxLines: 10,
    minLines: 1,
    autoScrollEditorIntoView: true,
    showLineNumbers: false,
    showGutter: false, // ??
});
// editor.setTheme("ace/theme/monokai");
editor.session.setUseSoftTabs(true);
editor.session.setTabSize(4);
editor.commands.addCommand({
    name: 'myCommand',
    bindKey: {win: 'Ctrl-Enter',  mac: 'Command-Enter'},
    // bindKey: {win: 'Enter',  mac: 'Enter'},
    exec: function(editor) { 
	sendInputACE(); // if Enter, need to change several
	// things, like insert newline if incomplete, and
	// preferably no matching parens / braces
    },
    readOnly: false, // false if this command should not apply in readOnly mode
});

