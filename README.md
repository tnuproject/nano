# nano for TNU

Standalone repository for the TNU `nano` port.

## Output

The build produces:

```sh
build/nano
```

## Requirements

- A checkout of the TNU source tree, or another tree exposing:
  - `userspace/libc/include`
  - `kernel/include`
  - `userspace/linker.ld`
  - `build/obj/userspace/libc/src/crt0.o`
  - `build/user/libtnu.a`
- GNU nano upstream source tree placed at `src/upstream`

## Build

```sh
make TNU_ROOT=../tnu
```

If you place this repo inside a TNU checkout, `TNU_ROOT` can usually stay at
its default.
