#!/bin/bash

# Script to spell out "hire me" on the GitHub contributions graph
# Each column is a week, each row is a day (Sunday=0, Saturday=6)
# Starts on Sunday, Feb 2nd, 2025


set -e

dummy_file="greenlight_dummy.txt"
commit_messages=(
  "Update progress"
  "Refactor code"
  "Fix typo"
  "Improve docs"
  "Tweak config"
  "Update README"
  "Minor changes"
  "Polish UI"
  "Add tests"
  "Cleanup"
  "Update dependencies"
  "Enhance UX"
  "Bugfix"
  "Optimize logic"
  "Update script"
)

# 5x3 bitmaps for each letter (H, I, R, E, space, M, E)
# 1 = commit, 0 = no commit
# Each sub-array is a row (Sunday=0), each string is 3 columns (weeks)
letters=(
  # H
  "101" "101" "111" "101" "101"
  # I
  "111" "010" "010" "010" "111"
  # R
  "110" "101" "110" "101" "101"
  # E
  "111" "100" "111" "100" "111"
  # space (1 col between letters)
  "000" "000" "000" "000" "000"
  # M
  "101" "111" "111" "101" "101"
  # E
  "111" "100" "111" "100" "111"
)

# Helper: add a double space (2 columns) between words (as rows)
double_space=("000" "000" "000" "000" "000" "000" "000" "000" "000" "000")



# Build the bitmap for "hire me" as a 5-row grid, each row is a string of columns (weeks)
bitmap_rows=()
# Helper to append letter rows to bitmap_rows
append_letter() {
  local offset=$1
  for ((r=0; r<5; r++)); do
    bitmap_rows[$r]="${bitmap_rows[$r]:-}${letters[$((offset+r))]}"
  done
}
# Helper to append space (single or double)
append_space() {
  local count=$1
  for ((r=0; r<5; r++)); do
    for ((s=0; s<count; s++)); do
      bitmap_rows[$r]="${bitmap_rows[$r]:-}000"
    done
  done
}

# H
append_letter 0
append_space 1
# I
append_letter 5
append_space 1
# R
append_letter 10
append_space 1
# E
append_letter 15
# double space between words
append_space 2
# M
append_letter 25
append_space 1
# E
append_letter 30

# Start date: Sunday, Feb 2nd, 2025
start_date="2024-10-07"

# Loop over columns (weeks)
cols=${#bitmap_rows[0]}
for ((col=0; col<cols; col++)); do
  # Loop over rows (days 0-4, Sunday-Thursday)
  for ((row=0; row<5; row++)); do
    pixel=${bitmap_rows[$row]:$col:1}
    if [ "$pixel" = "1" ]; then
      commit_date=$(date -d "$start_date +$((col*7+row)) days" +"%Y-%m-%d 12:00:00")
      msg_idx=$(( RANDOM % ${#commit_messages[@]} ))
      msg=${commit_messages[$msg_idx]}
      echo "$commit_date $msg" >> $dummy_file
      GIT_AUTHOR_DATE="$commit_date" GIT_COMMITTER_DATE="$commit_date" git add $dummy_file
      GIT_AUTHOR_DATE="$commit_date" GIT_COMMITTER_DATE="$commit_date" git commit -m "$msg"
    fi
  done
done
