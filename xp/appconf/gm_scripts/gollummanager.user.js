/* // ==UserScript== */
/* // @name           gollum manager */
/* // @namespace      xp */
/* // @include        http://gollum.easycp.de/gollum|+ */
/* // ==/UserScript== */

/**
 * TODO when click hyper link, add anchor
 * TODO read anchor on start up
 */
(function (win, doc){
    /* console.log("start"); */
    function res(evt){
      /* console.log("res"); */

      var tar = evt.target;
      /* console.log("click at ", tar); */
      if (tar.tagName.toUpperCase() != "A") { return; }

      var hr = tar.href;
      /* console.log("hyper link : ", hr); */

      hr = hr.match(/'(.*)'/);
      if (!hr) {return};

      hr = hr[1];
      doc.location.hash = escape(hr).replace(/\//g, '%2F');
    }
    doc.addEventListener("click", res, true);

    var scri = "";
    var hash = doc.location.hash;
    if (hash) {
      hash = unescape(hash.substr(1).replace(/\%2F/g, '/'));
      scri = hash.indexOf("search:") == 1 ?
        "wb.w._link('" + hash.substr(7) + "');" : 
        "wb.w._Searchterms = '" + hash.substr(7) + "'; wb.w._fetch();";
        /* "wb.w._search({keyCode:13}, '" + hash.substr(7) + "');"; */
      console.log("initload : " + scri);
    }
    var sc = doc.createElement("script");
    sc.innerHTML = "var __i = init;\
      init = function (){\
        __i();" 
        + scri + 
        "var __s = wb.w._search;\
        console.log(__s.toString());\
        wb.w._search = function (e, b){\
          console.log('evt : ' + e);\
          __s.call(this, e, b);\
          var v = this._searchfield.value;\
          v = encodeURIComponent(v);\
          document.location.hash = 'search:' + v;\
        };\
        console.log(wb.w._search.toString());\
      };";
      sc.id = "xp";
    doc.body.appendChild(sc);
  })(window, document);



