{
    if ($1 == "source" && system("test -f '"$2"'") == 0) {
        while ((getline line < $2) > 0) {
            if (excludeline != "" && line !~ excludeline) {
                print line
            }
        }
        close($2)
    }
    else {
        print
    }
}
