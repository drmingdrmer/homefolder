// ==UserScript==
// @name           htmlblock.adjust
// @namespace      xp
// @include        http://www.htmlblock.co.uk/*
// ==/UserScript==
//

var d = document.getElementsByTagName("div")[0];
d.style.opacity = .8;
d.style.position="absolute";
d.style.zIndex=1000;
d.style.left="0px";
d.style.top="0px";

d.addEventListener("mousedown", function (e){
    d.startDrag = true;
    d.x = e.clientX - parseInt(d.style.left);
    d.y = e.clientY - parseInt(d.style.top);
  }, true);

d.addEventListener("mouseup", function (e){
    d.startDrag = false;
  }, true);

document.addEventListener("mousemove", function (e){
    if (!d.startDrag) return;
    var w = parseInt(d.clientWidth);
    var h = parseInt(d.clientHeight);
    d.style.left = e.clientX - d.x + "px";
    d.style.top = e.clientY - d.y + "px";

  }, true);
