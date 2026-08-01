#!/bin/bash
# Reusable display functions for ELF header information.

function display_elf_header_info() {
    echo "ELF Header Information for '$file_name':"
    echo "----------------------------------------"
    echo "Magic Number: $magic_number"
    echo "Class: $class"
    echo "Byte Order: $byte_order"
    echo "Entry Point Address: $entry_point_address"
}

function display_usage() {
    echo "Usage: $0 <elf_file>" >&2
}

function display_error() {
    echo "Error: $1" >&2
}
