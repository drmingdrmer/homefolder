// ==UserScript==
// @name           util
// @namespace      xp
// @include        http://*
// ==/UserScript==

function $(id){ return document.getElementById(id);}
function $n(n){ return document.getElementsByTagName(n);}
function $c(n){ return document.createElement(n);}

function $switch(o, s, pn, v) {
  if (o["__"+pn]!=null){
    s[pn] = o["__"+pn];
    o["__"+pn] = null;
  } else {
    o["__"+pn] = s[pn];
    s[pn] = v;
  }
}
/* var $$dbg = $c("div"); */
/* $$dbg.style.cssText = "white-space:pre;position:absolute;bottom:0px;height:250px;width:100%;border:1px solid #ddd;"; */
/* document.body.appendChild($$dbg); */

/* function dbg(msg) { $$dbg.innerHTML += msg+"\n";} */


var $$cmds =[];
var $$o = null;
var $$last = null;
var $$startControl;

function startControl(ev){
  $$startControl = true;
  $$o={
    curNode : ev.target,
    update  : update
  };
  update();
  document.addEventListener("keypress", ctrl, true);
}

function stopControl(){
  $$startControl = false;
  $$o = null;
  $$last = null;
  /* update(); */
  document.removeEventListener("keypress", ctrl, true);
}

function update(){
  var n = $$o && $$o.curNode;

  if ($$last) {
    $$last.style.backgroundColor = $$last.$$bg;
  }
  if (!n) return;
  n.$$bg = n.style.backgroundColor;
  n.style.backgroundColor = "#ff7";
  $$last = n;
}

function ctrl(ev){
  var cd = ev.charCode;

  for (var i= 0; i < $$cmds.length; ++i){
    var no = $$cmds[i];
    if (cd == no.chr) {
      var re = no.func($$o);
      if (re) stopControl();
      return;
    }
  }
}

function docLis(ev){
  var tar = ev.target;
  if (ev.ctrlKey) {
    startControl(ev);
  }
}

document.addEventListener("click", docLis, true);

function addCmd(chr, f){
  $$cmds.push({chr : chr.charCodeAt(0), func : f});
}
/* q   e r */
/* s d */
/* x  */


/* quit */
addCmd("q", function(o){
    o.curNode = null;
    o.update();
  });
/* expand selection */
addCmd("e", function(o){
    o.curNode = o.curNode.parentNode;
    while (/tbody|tr/.test(o.curNode.tagName.toLowerCase())) {
      o.curNode = o.curNode.parentNode;
    }
    o.update();
  });
/* mark current */
addCmd("b", function(o){
    var n = o.curNode, s = n.style;

    o.curNode = null;
    o.update();

    $switch(n, s, "backgroundColor", "#8f8");

    return true;
  });
/* split */
addCmd("s", function(o){
    var n = o.curNode, s = n.style;
    s.MozColumnCount = 2 - s.MozColumnCount;
    s.MozColumnGap = "20px";

    $switch(n, s, "display", "block");

    o.curNode = null;
    o.update();

    return true;
  });
/* expand width to 100% */
addCmd("w", function (o){
    var n = o.curNode, s = n.style;
    $switch(n, s, "width", "100%");
    o.curNode = null;
    o.update();
    return true;
  });
/* white-space : pre*/
addCmd("r", function (o){
    var n = o.curNode, s = n.style;
    $switch(n, s, "whiteSpace", "pre");
    o.curNode = null;
    o.update();
    return true;
  })
/* remove blank line */
addCmd("d", function (o){
    var n = o.curNode, s = n.style;

    n.innerHTML = n.innerHTML.replace(/\n\s*\n/g, "\n").replace(/<font\s*\/>/g, "");

    o.curNode = null;
    o.update();
    return true;
  })
/* remove node */
addCmd("x", function (o){
    var n = o.curNode, s = n.style;

    n.parentNode.removeChild(n);

    o.curNode = null;
    o.update();
    return true;
  });
/* larger font */
addCmd("f", function (o){
    var n = o.curNode, s = n.style;
    var fs = parseInt(s.fontSize);
    if (isNaN(fs)) fs = 12;
    fs+=2;
    s.fontSize = fs + "px";
    o.curNode = null;
    o.update();
    return true;
  });

