### Install CPP protobuf

https://developers.google.com/protocol-buffers/

On mac:

```
brew install protobuf
```

Other platform:

```
PROTOC_ZIP=protoc-3.3.0-osx-x86_64.zip
curl -OL https://github.com/google/protobuf/releases/download/v3.3.0/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
rm -f $PROTOC_ZIP
```

See: http://google.github.io/proto-lens/installing-protoc.html


### Install go plugin for protoc to generate go code

```
go get -u github.com/golang/protobuf/protoc-gen-go
```

### Install go protobuf runtime proto

```
go get -u github.com/golang/protobuf/proto
```

Or install them in one step:

```
go get -u github.com/golang/protobuf/{proto,protoc-gen-go}
```

### Choose version of generated code

If you see compilation error such as `proto.ProtoPackageIsVersion2` undefined.

Most of the time it is because the version of `protoc-gen-go` to generate the code and the runtime
lib `proto` have different versions.

To solve this, such as `v1.2.0`:

```
cd $GOPATH/github.com/golang/protobuf
git checkout v1.2.0
go install github.com/golang/protobuf/protoc-gen-go

# And then update the version of `proto` of your working dir.
```

