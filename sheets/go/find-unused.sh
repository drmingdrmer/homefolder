go get honnef.co/go/tools/unused
unused -tests=0  ./...  // 检查私有unused
unused -tests=0 -exported  ./...  // 也检查public的unused
