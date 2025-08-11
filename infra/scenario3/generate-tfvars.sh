#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="main.tfvars.json"
OUTPUT_FILE="terraform.tfvars.json"

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Input file $INPUT_FILE not found."
  exit 1
fi

# Replace ${VAR} with the value of the environment variable VAR
delimiter="\x1e" # Use a non-printable delimiter to avoid collision
perl -pe 's/\$\{([A-Za-z_][A-Za-z0-9_]*)\}/exists $ENV{$1} ? $ENV{$1} : $&/ge' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE from $INPUT_FILE with environment variable substitutions."
