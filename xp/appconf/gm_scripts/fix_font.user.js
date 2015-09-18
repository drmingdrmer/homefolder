// ==UserScript==
// @name           fix_font
// @namespace      xp
// @include        http://en.wikipedia.org/*
// ==/UserScript==

var d = document.createElement("div");
d.innerHTML = "<style>\
body {\
  font-family:宋体;\
}\
</style>";

document.body.appendChild(d);

