#!/bin/sh


# curl  "https://zh.wikipedia.org/w/api.php?format=json&action=query&prop=revisions&rvprop=content&rvformat=latex&titles=$title" | jq > src
#
# mathformat 灭有这个参数
# curl  "https://zh.wikipedia.org/api/rest_v1/page/html/$title?mathformat=tex"  > src.html

# mediawiki 源码:
# curl "https://zh.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=content&format=json&titles=$title" | jq > src

# 一种标记语言??
# curl "https://zh.wikipedia.org/w/api.php?action=parse&format=json&page=$title&prop=parsetree" | jq -r '.parse.parsetree["*"]' > src

# 文本的mediawiki源码
# curl "https://zh.wikipedia.org/w/api.php?action=parse&format=json&page=$title&prop=wikitext&formatversion=2" | jq -r '.parse.wikitext' > src

# curl  "https://zh.wikipedia.org/w/api.php?format=json&action=parse&prop=wikitext&page=$title" | jq > src
