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
        if [ "$gen_type" = "llvm-ir" ]; then
            local ir_file="$dst_dir/$(basename "$base_name").ll"
            echo "Validating LLVM IR for $ir_file..."
            llc "$ir_file" -o /dev/null
            if [ $? -ne 0 ]; then
                echo "Validation failed for $ir_file"
            else
                echo "Validation successful for $ir_file"
            fi
        fi
    done
}

# Call the function with the command-line argument
compile_files $1


