#!/bin/bash

set -e

compile_files() {
    local src_dir="examples/source"
    local gen_type=$1

    find "$src_dir" -name "*.ola" | while read src_file; do
        local base_name="${src_file%.*}"

        local sub_dir="$(dirname "$base_name")"

        local dst_dir="examples/$gen_type"

        if [ "$sub_dir" != "$src_dir" ]; then
            sub_dir=${sub_dir#$src_dir/}
            dst_dir="$dst_dir/$sub_dir"
        fi

        mkdir -p "$dst_dir"
        
        echo "Compiling $src_file..."
        ./target/debug/olac compile "$src_file" --gen "$gen_type" --output "$dst_dir"
    done
}

# Call the function with the command-line argument
compile_files $1


