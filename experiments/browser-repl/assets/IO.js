
var lastSubmission = '';
var lastInputBlock = null;

logmessage = function(s) {
    document.getElementById("logmessages").innerHTML += '<p>' + s + '</p>';
}


ws.onmessage = function(msg) {
    var rconsoleDiv, inDiv, outDiv, inCode;
    // logmessage("<" + msg.data + ">");
    if (msg.data === "~~INCOMPLETE~~") {
	logmessage("Incomplete input")
	return; // do nothing
    }
    // clear input area
//    document.getElementById('input').value = '';
    editor.session.setValue('');
    // add input
    var rconsoleDiv = document.getElementById("rconsole");
    if (lastInputBlock === null)
	inDiv = document.createElement("pre");
    else
	inDiv = lastInputBlock;
    inCode = document.createElement("code"); // TODO: syntax highlight via prism
    inCode.classList.add("language-R");
    inCode.innerHTML = lastSubmission.replace(/&/g, "&amp;").replace(/\</g, "&lt;");
    inDiv.appendChild(inCode);
    Prism.highlightElement(inCode);
    rconsoleDiv.appendChild(inDiv);
    // add output (if any)
    if (msg.data === '') { // re-use the current inDiv next time
	lastInputBlock = inDiv;
    }
    else {
	lastInputBlock = null;
	outDiv = document.createElement("pre");
	// outDiv.innerHTML = msg.data.replace(/&/g, "&amp;").replace(/\</g, "&lt;");
	outDiv.innerHTML = msg.data;
	rconsoleDiv.appendChild(outDiv);
    }
}
function sendInput() {
    var input = document.getElementById('input');
    lastSubmission = input.value;
    ws.send(lastSubmission);
}

function sendInputACE() {
    lastSubmission = editor.getValue();
    ws.send(lastSubmission);
}

      
// automatic highlight disabled using 'data-manual' attribute below
// window.Prism = window.Prism || {};
// Prism.manual = true;


