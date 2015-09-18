// ==UserScript==
// @name           mark
// @namespace      xp
// @include        http://www.ibm.com/developerworks/linux/library/l-linux-slab-allocator/#rate
// ==/UserScript==

document.addEventListener ("click", function (ev){
    var t = ev.target;

    if (ev.shiftKey) {
      var bg = t.style.backgroundColor;
      (t.__tint) ? (t.style.backgroundColor = "", t.__tint = false) : (t.style.backgroundColor = "#ffd", t.__tint = true);
    }

  }, true);

