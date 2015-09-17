let b:current_buf="module"

syntax keyword javaScriptGlobalObjects  Module Loader
syntax match moduleNativeFunc    /\%(\$initialize\|nodeValue\|nodeType\|parentNode\|childNodes\|firstChild\|lastChild\|previousSibling\|nextSibling\|attributes\|ownerDocument\|namespaceURI\|prefix\|localName\|tagName\)\>/

hi link moduleNativeFunc         PreProc

