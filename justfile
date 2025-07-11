run *args: build
    @ ./zig-out/bin/entrybook.exe {{args}}

build:
    @ zig build
