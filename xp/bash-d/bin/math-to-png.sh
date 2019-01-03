#!/bin/sh

# from stdin

latex="$(cat)"

quote='
$$
'
if [ "$1" = "-i" ]; then
    quote='$'
fi

# make a latex file

{
cat <<-'END'
\documentclass{article}
\pagestyle{empty}
\begin{document}
END

echo "$quote$latex$quote"

cat <<-'END'
\end{document}
END
} > /tmp/math-latex.latex

(
cd /tmp
latex2png.sh math-latex.latex >/dev/null
)

echo '/tmp/math-latex.png'
