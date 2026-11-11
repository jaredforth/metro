#!/bin/sh
# Compiles the pure logic with tools/test.swift (asserts on, no -O) and runs it.
set -e
cd "$(dirname "$0")"
t=$(mktemp -d)
cp tools/test.swift "$t/main.swift" # top-level code is only allowed in main.swift
swiftc Metro/Tick.swift "$t/main.swift" -o "$t/test"
"$t/test"; rm -rf "$t"
