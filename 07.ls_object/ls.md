```mermaid
classDiagram
    class LsCommand {
        -option: Option
        +run(): String
    }
    class Option {
        -is_all: Boolean
        -is_reverse: Boolean
        -is_long: Boolean
        +is_all(): Boolean
        +is_reverse(): Boolean
        +is_long(): Boolean
        -parse(args: Array): OptionPaser
    }
    class Entry {
        -entry: String
        -type: String
        -permissions: String
        -nlink: Integer
        -user: String
        -group: String
        -size: Integer
        -mtime: String
        -name: String
        +entry(): String
        +type(): String
        +permissions(): String
        +nlink(): Integer
        +user(): String
        +group(): String
        +size(): Integer
        +mtime(): String
        +name(): String
        -convert_filetype_to_char(ftype: String): String
        -convert_octal_to_rwx(octal_permissions: Array): String
        -transform_special_bit(rwx: String, has_special_bit: Boolean, set: String, unset: String): String
        -format_mtime(mtime: Time): String
    }
    class EntryList {
        -is_all: Boolean
        -is_reverse: Boolean
        -entries: Array
        +fetch_and_sort(): Array
    }
    class ShortList {
        -COLUMNS: Integer
        -entries: Array
        +format(): String
        -create_formatted_list(rows: int): Array
        -create_list(rows: int): Array
        -format_list(list: Array): Array
        -calculate_column_max_lengths(list: Array): Array
        -list_to_string(list: Array): string
    }
    class LongList {
        -KBYTE_PER_BLOCK: Float
        -entries: Array
        +format_total_block_kbyte(): String
        +format(): String
        -calculate_total_block_kbyte(entries: Array): Integer
        -calculate_entry_block_kbyte(entry: String): Integer
        -calculate_max_col_lengths(entry_details: Array): Hash
        -format_entry_details(entry_details: Array, max_col_lengths: Hash): String
    }
    LsCommand --> Option : uses
    LsCommand --> EntryList: uses
    LsCommand --> ShortList : uses
    LsCommand --> LongList : uses
    EntryList --> Entry : uses
```
