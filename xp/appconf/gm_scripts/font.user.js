// ==UserScript==
// @name           font
// @namespace      xp
// @description    ...
// @include        file:///C:/Hyper.Disc/.projects.out/C/bdb-4.6.18.tar/bdb-4.6.18/db-4.6.18/*
// ==/UserScript==

var div = document.createElement("div");
div.innerHTML = "<style>\
tt>a{\
font-size:30px;\
}\
<\/style>";
document.body.appendChild(div);
