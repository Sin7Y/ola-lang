#!/bin/bash

set -e

src_dir="examples/source"

find "$src_dir" -name "*.ola" | while read src_file; do
    base_name="${src_file%.*}"

    sub_dir="$(dirname "$base_name")"

    dst_dir="examples/irgen"

    if [ "$sub_dir" != "$src_dir" ]; then

        sub_dir=${sub_dir#$src_dir/}
        dst_dir="$dst_dir/$sub_dir"
    fi

    mkdir -p "$dst_dir"

    ./target/debug/olac compile "$src_file" --gen llvm-ir --output "$dst_dir"

done

