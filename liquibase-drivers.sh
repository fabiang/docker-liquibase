#!/usr/bin/env bash

find "$LIQUIBASE_HOME/lib" "$LIQUIBASE_HOME/internal/lib" -type f -name "*.jar" \
  | xargs -I{} unzip -p {} META-INF/MANIFEST.MF 2>/dev/null \
  | grep -E "Main-Class|Bundle-Name|Implementation-Title" \
  | sed '/^\s*$/d' \
  | sort -u
