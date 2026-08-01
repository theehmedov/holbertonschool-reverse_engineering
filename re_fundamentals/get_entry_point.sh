#!/bin/bash
# Extracts and displays key fields from the ELF header of a given file.

# Load the display functions from the same directory as this script.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -f "$script_dir/messages.sh" ]; then
    echo "Error: messages.sh not found in $script_dir" >&2
    exit 1
fi
# shellcheck source=messages.sh
source "$script_dir/messages.sh"

# 1. Exactly one argument is required.
if [ "$#" -ne 1 ]; then
    display_usage
    exit 1
fi

file_name="$1"

# 2. The file must exist and be a regular, readable file.
if [ ! -e "$file_name" ]; then
    display_error "'$file_name' does not exist."
    exit 1
fi

if [ ! -f "$file_name" ]; then
    display_error "'$file_name' is not a regular file."
    exit 1
fi

if [ ! -r "$file_name" ]; then
    display_error "'$file_name' is not readable."
    exit 1
fi

# 3. The file must actually be an ELF file: the first four bytes must be
#    0x7F 'E' 'L' 'F'. Checking the magic directly is more reliable than
#    trusting the extension or the output of file(1).
magic_bytes=$(head -c 4 "$file_name" | od -An -tx1 | tr -d ' \n')
if [ "$magic_bytes" != "7f454c46" ]; then
    display_error "'$file_name' is not an ELF file."
    exit 1
fi

# 4. Read the header once, then pull each field out of it.
header=$(readelf -h "$file_name" 2>/dev/null)
if [ -z "$header" ]; then
    display_error "Could not read the ELF header of '$file_name'."
    exit 1
fi

# Pulls the value after the first ':' on the matching line and trims the
# surrounding whitespace. sed is used instead of xargs because some values
# contain an apostrophe ("2's complement"), which xargs would misparse.
function header_field() {
    echo "$header" | grep -m1 "$1" | cut -d: -f2- \
        | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

magic_number=$(header_field 'Magic:')
class=$(header_field '^[[:space:]]*Class:')
# readelf reports Data as "2's complement, little endian"; only the
# endianness itself is wanted, so drop everything up to the last comma.
byte_order=$(header_field '^[[:space:]]*Data:' | sed 's/.*,[[:space:]]*//')
entry_point_address=$(header_field 'Entry point address:')

# 5. Hand everything to the shared formatter.
display_elf_header_info
