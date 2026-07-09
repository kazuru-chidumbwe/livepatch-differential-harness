# ELF normalization (Channel 1)

Extracts a normalized structural representation `N(ELF)` from livepatch `.ko` modules.

## Normalized relocation tuple

Per [kernel livepatch module ELF format](https://docs.kernel.org/livepatch/module-elf-format.html), for each `.klp.rela.<objname>.<section>` section:

```
(objname, section_name, r_offset, r_info_type, symbol_name, r_addend)
```

Tuples are sorted and hashed (SHA-256) for comparison.

## Usage (planned)

```bash
python3 normalize/elf_normalize.py path/to/livepatch.ko
python3 normalize/elf_normalize.py --diff a.ko b.ko
```

## Dependencies

- `pyelftools` (parse SHT_RELA, symbol names via `sh_link`)

## Self-test

`make smoke` runs `elf_normalize.py --self-test` against fixture modules when available.
