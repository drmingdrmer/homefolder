// ==UserScript==
// @name           font for proxy
// @namespace      xp
// @include        http://www.htmlblock.co.uk/anonymous_web_browser/browse.php?u=aHR0cDovL2VuLndpa2lwZWRpYS5vcmcvd2lraS9TbGFiX2FsbG9jYXRvcg%3D%3D&b=31
// ==/UserScript==


var div = document.createElement("div");
div.innerHTML = "\
<style>\
  #content{\
    -moz-column-count:2;\
    -moz-column_gap:20px;\
  }\
<\/style>";

document.body.appendChild(div);

document.addEventListener ("click", function (ev){
  if (ev.ctrlKey) {
    var t = ev.target.parentNode;
    while (/font/.test(t.tagName)) t = t.parentNode;
    t.style.MozColumnCount= 2 - t.style.MozColumnCount;
    t.style.MozColumnGap= "20px";

    if (t.style.MozColumnCount == 2) {
      t.oldDis = t.style.display;
      t.style.display = "block";
    } else {
      t.style.display = t.oldDis;
    }


  }
}, true);

