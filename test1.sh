#!/bin/bash
cd "$(dirname "$0")"

path_code="code"
path_test="Test"
CC="gcc"

get_cli_args() {
    local name=$1
    case "$name" in
        3-2)
            echo "apple mango ant banana cat anaconda"
            ;;
        *)
            echo ""
            ;;
    esac
}

run_case() {
    local name=$1
    local suf=$2
    local outfile infile label actual cli_args

    if [ -z "$suf" ]; then
        outfile="$path_test/${name}-out.txt"
        infile="$path_test/${name}-in.txt"
        label="${name}-out.txt"
        actual="$path_test/actual-${name}.txt"
    else
        outfile="$path_test/${name}-out${suf}.txt"
        infile="$path_test/${name}-in${suf}.txt"
        label="${name}-out${suf}.txt"
        actual="$path_test/actual-${name}-${suf}.txt"
    fi

    cli_args=$(get_cli_args "$name")

    if [ -f "$infile" ] && [ -n "$cli_args" ]; then
        "./$path_code/$name" $cli_args < "$infile" > "$actual"
    elif [ -f "$infile" ]; then
        "./$path_code/$name" < "$infile" > "$actual"
    elif [ -n "$cli_args" ]; then
        "./$path_code/$name" $cli_args > "$actual"
    else
        "./$path_code/$name" > "$actual"
    fi

    if diff -q "$actual" "$outfile" > /dev/null 2>&1; then
        echo "$label: PASS"
    else
        echo "$label: FAIL"
    fi
    rm -f "$actual"
}

shopt -s nullglob
c_files=("$path_code"/*.c)
shopt -u nullglob

if [ ${#c_files[@]} -eq 0 ]; then
    echo "No .c files in $path_code"
    exit 1
fi

IFS=$'\n' sorted=($(printf '%s\n' "${c_files[@]}" | sort))
unset IFS

for f in "${sorted[@]}"; do
    name=$(basename "$f" .c)
    outbin="$path_code/$name"

    $CC "$f" -o "$outbin" 2>/dev/null
    if [ ! -f "$outbin" ] || [ ! -x "$outbin" ]; then
        echo "$name: COMPILE FAIL"
        continue
    fi

    if [ -f "$path_test/${name}-out.txt" ]; then
        run_case "$name" ""
    elif [ -f "$path_test/${name}-out0.txt" ]; then
        n=0
        while [ -f "$path_test/${name}-out${n}.txt" ]; do
            run_case "$name" "$n"
            n=$((n + 1))
        done
    else
        echo "$name: SKIP (no ${name}-out.txt in Test)"
    fi
done
