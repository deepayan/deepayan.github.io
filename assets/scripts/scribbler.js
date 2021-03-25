
// Include something like the following in your HTML

// <canvas height=400 width=400 id="scribbler"
//     style="position: fixed; background: transparent; z-index: -1;">
// </canvas>

// - Customize z-index value below if needed: the canvas needs be on top when active
//
// - This code only handles drag events. 
//
// - The safest way to do this is to add event listeners to the window
// - element. But this effectively disables other handlers (like text
// - selection). use [de]activateScribbler() to choose


// global variables

var gcontext; // graphics context

var gdrag = {
    // settings
    cid: "scribbler",   // id - must match canvas id in HTML
    method: "scribble", // "none" / "highlight"
    zindex: "3",        // "3" works with remark.js
    active: false,      // whether active; needed to toggle
    // state variables
    on: false,          // drag in progress
    startx: undefined,  // start event position (x)
    starty: undefined,  // start event position (y)
};


// FIXME: Need UI to control

var gpar = {
    stroke: "blue",
    lwd: 2
};

function handleKeyDown(e) {
    if (e.code == "Escape") // toggle scribbler
    {
	if (gdrag.active) 
	    deactivateScribbler();
	else
	    activateScribbler();
    }
}

function activateScribbler() // add event handlers
{
    var ltarget = window; // or something else ?
    // ltarget.addEventListener("mousewheel", on_wheel, false);
    ltarget.addEventListener("mousedown", on_mousedown, false);
    ltarget.addEventListener("mouseup", on_mouseup, false);
    ltarget.addEventListener("mousemove", on_mousemove, false);
    // ltarget.addEventListener("click", on_click, false);
    // touch events for tablets/mobile
    ltarget.addEventListener("touchstart", handleTouch, true);
    ltarget.addEventListener("touchmove", handleTouch, true);
    ltarget.addEventListener("touchend", handleTouch, true);
    document.getElementById(gdrag.cid).style.zIndex = gdrag.zindex;
    gdrag.active = true;
    console.log("scribbler activated"); // FIXME: use visual indicator
}

function deactivateScribbler() // add event handlers
{
    var ltarget = window;
    ltarget.removeEventListener("mousedown", on_mousedown, false);
    ltarget.removeEventListener("mouseup", on_mouseup, false);
    ltarget.removeEventListener("mousemove", on_mousemove, false);
    ltarget.removeEventListener("touchstart", handleTouch, true);
    ltarget.removeEventListener("touchmove", handleTouch, true);
    ltarget.removeEventListener("touchend", handleTouch, true);
    document.getElementById(gdrag.cid).style.zIndex = "-1";
    gdrag.active = false;
    console.log("scribbler deactivated"); // FIXME: use visual indicator
}

// Only scribbling currently supported. Easy to add: highlight by
// semi-transparent rectangle.

// Strategy: just draw segments whenever mouse drags (i.e., moves
// while mouse is down). A more sophisticated version could try to
// smooth. This would probably need an extra canvas to draw
// temporarily while recording, then once mouse is up, re-draw after
// smoothing (and erase the temporary drawing on the extra canvas). Or
// could we could smooth while drawing? Anyway, all this is for later.

function drawSegment(x0, y0, x1, y1)
{
    gcontext.strokeStyle = gpar.stroke;
    gcontext.lineWidth = gpar.lwd;
    gcontext.beginPath();
    gcontext.moveTo(x0, y0);
    gcontext.lineTo(x1, y1);
    gcontext.stroke();
}

function setup() // add event handlers
{
    // var cookie_id = getKeyValue("gid="); // cookie or url
    var mycanvas = document.getElementById(gdrag.cid);
    // this part should run again when window is resized
    mycanvas.width = window.innerWidth;
    mycanvas.height = window.innerHeight;
    gcontext = mycanvas.getContext('2d'); // global
    // set event handlers
    // activateScribbler();
    // deactivateScribbler();
    document.addEventListener('keydown', handleKeyDown);
}

// Maybe do this only if nothing has been drawn. We can always reload
// to refresh.

function reset() // desructively resize canvas (called when window is resized)
{
    // log("reset");
    var mycanvas = document.getElementById(gdrag.cid);
    // this part should run when window is resized
    mycanvas.width = window.innerWidth;
    mycanvas.height = window.innerHeight;
    // gcontext = mycanvas.getContext('2d'); // global
}

function on_mousedown(ev) 
{
    // console.log(ev);
    // shift(1, 1);
    if (ev.button == 0) { // left button
	gdrag.on = true;
	gdrag.startx = ev.clientX;
	gdrag.starty = ev.clientY;
    }
}

function on_mouseup(ev) 
{
    if (ev.button == 0) { // left button
	gdrag.on = false;
    }
}

function on_mousemove(ev) 
{
    if (gdrag.on)
    {
	var newx = ev.clientX, newy = ev.clientY;
	drawSegment(gdrag.startx, gdrag.starty, newx, newy);
	gdrag.startx = newx;
	gdrag.starty = newy;
    }
}

function handleTouch(e)
{
    e.preventDefault();
    // log(e.type + "-> " + [e.touches.length, e.targetTouches.length, e.changedTouches.length]);
    if (e.changedTouches.length == 1) {
	var touch = e.changedTouches[0];
	var tx = touch.pageX, ty = touch.pageY, tt = e.type;
	switch (tt) 
	{
	case "touchstart": 
	    // log(tt + ": " + tx + "," + ty);
	    gdrag.on = true;
	    gdrag.startx = tx;
	    gdrag.starty = ty;
	    break;
	case "touchmove":
	    // log(tt + ": " + tx + "," + ty);
	    if (gdrag.on)
	    {
		var newx = tx - gdrag.startx, newy = ty - gdrag.starty;
		drawSegment(gdrag.startx, gdrag.starty, newx, newy);
		gdrag.startx = newx;
		gdrag.starty = newy;
	    }
	    break;
	case "touchend":
	    // log(tt + ": " + tx + "," + ty);
	    gdrag.on = false;
	    break;
	}
    }
}




// These may eventually be useful for storing parameters (color, line
// width, etc) across session. Currently unused.

function setCookie(key, value) {
    document.cookie = key + value + "; max-age=" + (60 * 60 * 24 * 366);
}

function getValueFromString(key, srcString) {
    var pos, start, end, value;
    var len = key.length;
    pos = srcString.indexOf(key);
    if (pos != -1) {
	start = pos + len;
	end = srcString.indexOf(";", start);
	if (end == -1) end = srcString.length;
	value = srcString.substring(start, end);
	return value;
    }
    else return "NA";
}

function getCookieValue(key) {
    return getValueFromString(key, document.cookie);
}
function getLocationValue(key) {
    return getValueFromString(key, location.href);
}
function getKeyValue(key) {
    // first try location.  If that's empty, try cookies
    var ans = getLocationValue(key);
    if (ans == "NA") ans = getCookieValue(key);
    if (ans == "NA") ans = "";
    return ans;
}

// function log(s)
// {
//     document.getElementById("pid").innerHTML += "<br/>" + s;
// }

