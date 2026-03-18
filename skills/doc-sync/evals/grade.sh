#!/bin/bash
# Grade all doc-sync eval runs
#
# Usage: bash grade.sh [workspace-dir]
#   workspace-dir: directory containing eval run outputs (default: ./workspace)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="${1:-$SCRIPT_DIR/workspace}"

grade_json() {
  local run_dir="$1"
  local eval_name="$2"
  local expectations="$3"

  mkdir -p "$run_dir"
  cat > "$run_dir/grading.json" << ENDOFGRADING
{
  "eval_name": "$eval_name",
  "expectations": $expectations
}
ENDOFGRADING
}

# Helper: resolve docs dir from outputs
resolve_docs() {
  local dir="$1"
  if [ -d "$dir/docs" ]; then
    echo "$dir/docs"
  else
    echo "$dir"
  fi
}

# ============================================================
# TEST 1: Bootstrap Docs
# ============================================================

echo "=== Grading Test 1: Bootstrap Docs ==="

for run in run-1 run-2; do
  for variant in with_skill without_skill; do
    echo "--- $run/$variant ---"
    DIR="$BASE/bootstrap-docs/$run/$variant/outputs"
    [ ! -d "$DIR" ] && echo "  Skipped (no outputs)" && continue
    DOCS=$(resolve_docs "$DIR")

    # Assertion 1: docs/index.md exists
    [ -f "$DOCS/index.md" ] && A1='{"text":"docs/index.md exists","passed":true,"evidence":"File found"}' || A1='{"text":"docs/index.md exists","passed":false,"evidence":"File not found"}'

    # Assertion 2: docs/functional/index.md exists
    [ -f "$DOCS/functional/index.md" ] && A2='{"text":"docs/functional/index.md exists","passed":true,"evidence":"File found"}' || A2='{"text":"docs/functional/index.md exists","passed":false,"evidence":"File not found"}'

    # Assertion 3: docs/technical/index.md exists
    [ -f "$DOCS/technical/index.md" ] && A3='{"text":"docs/technical/index.md exists","passed":true,"evidence":"File found"}' || A3='{"text":"docs/technical/index.md exists","passed":false,"evidence":"File not found"}'

    # Assertion 4: README links to docs/index.md
    README=""
    [ -f "$DIR/README.md" ] && README="$DIR/README.md"
    [ -z "$README" ] && [ -f "$DOCS/../README.md" ] && README="$DOCS/../README.md"
    if [ -n "$README" ] && grep -q "docs/index.md\|docs/" "$README"; then
      A4='{"text":"README.md links to docs/index.md","passed":true,"evidence":"Link found in README"}'
    else
      A4='{"text":"README.md links to docs/index.md","passed":false,"evidence":"No link to docs/ found in README"}'
    fi

    # Assertion 5: README under 10 lines
    if [ -n "$README" ]; then
      LINES=$(wc -l < "$README" | tr -d ' ')
      [ "$LINES" -le 10 ] && A5="{\"text\":\"README.md is under 10 lines\",\"passed\":true,\"evidence\":\"README has $LINES lines\"}" || A5="{\"text\":\"README.md is under 10 lines\",\"passed\":false,\"evidence\":\"README has $LINES lines\"}"
    else
      A5='{"text":"README.md is under 10 lines","passed":false,"evidence":"README not found"}'
    fi

    # Assertion 6: functional/ has at least one feature spec beyond index.md
    FUNC_COUNT=0
    [ -d "$DOCS/functional" ] && FUNC_COUNT=$(find "$DOCS/functional" -name "*.md" ! -name "index.md" | wc -l | tr -d ' ')
    [ "$FUNC_COUNT" -ge 1 ] && A6="{\"text\":\"functional/ has at least one feature spec\",\"passed\":true,\"evidence\":\"Found $FUNC_COUNT feature spec(s)\"}" || A6='{"text":"functional/ has at least one feature spec","passed":false,"evidence":"No feature specs found"}'

    # Assertion 7: No implementation details in functional specs
    IMPL_FOUND=false
    if [ -d "$DOCS/functional" ]; then
      for f in "$DOCS/functional"/*.md; do
        [ "$(basename "$f")" = "index.md" ] && continue
        [ ! -f "$f" ] && continue
        if grep -qE '```(sql|clojure|java|python|bash|dockerfile)|CREATE |SELECT |INSERT |defn |def ' "$f"; then
          IMPL_FOUND=true; break
        fi
      done
    fi
    [ "$IMPL_FOUND" = "false" ] && A7='{"text":"Functional specs have no implementation details","passed":true,"evidence":"No code blocks or SQL found"}' || A7='{"text":"Functional specs have no implementation details","passed":false,"evidence":"Code blocks or implementation details found"}'

    grade_json "$BASE/bootstrap-docs/$run/$variant" "bootstrap-docs-$run-$variant" "[$A1,$A2,$A3,$A4,$A5,$A6,$A7]"
    echo "  Graded -> grading.json"
  done
done

# ============================================================
# TEST 2: Reorganize Docs
# ============================================================

echo "=== Grading Test 2: Reorganize Docs ==="

for run in run-1 run-2; do
  for variant in with_skill without_skill; do
    echo "--- $run/$variant ---"
    DIR="$BASE/reorganize-docs/$run/$variant/outputs"
    [ ! -d "$DIR" ] && echo "  Skipped (no outputs)" && continue
    DOCS=$(resolve_docs "$DIR")

    # Assertion 1: docs/functional/index.md exists with links
    if [ -f "$DOCS/functional/index.md" ] && grep -qE '\.md\)' "$DOCS/functional/index.md"; then
      A1='{"text":"docs/functional/index.md exists with links","passed":true,"evidence":"File found with links to specs"}'
    elif [ -f "$DOCS/functional/index.md" ]; then
      A1='{"text":"docs/functional/index.md exists with links","passed":false,"evidence":"File found but no links to child specs"}'
    else
      A1='{"text":"docs/functional/index.md exists with links","passed":false,"evidence":"File not found"}'
    fi

    # Assertion 2: docs/technical/index.md exists with links
    if [ -f "$DOCS/technical/index.md" ] && grep -qE '\.md\)' "$DOCS/technical/index.md"; then
      A2='{"text":"docs/technical/index.md exists with links","passed":true,"evidence":"File found with links to docs"}'
    elif [ -f "$DOCS/technical/index.md" ]; then
      A2='{"text":"docs/technical/index.md exists with links","passed":false,"evidence":"File found but no links to child docs"}'
    else
      A2='{"text":"docs/technical/index.md exists with links","passed":false,"evidence":"File not found"}'
    fi

    # Assertion 3: README under 15 lines
    README=""
    [ -f "$DIR/README.md" ] && README="$DIR/README.md"
    [ -z "$README" ] && [ -f "$DOCS/../README.md" ] && README="$DOCS/../README.md"
    if [ -n "$README" ]; then
      LINES=$(wc -l < "$README" | tr -d ' ')
      [ "$LINES" -le 15 ] && A3="{\"text\":\"README.md under 15 lines\",\"passed\":true,\"evidence\":\"README has $LINES lines\"}" || A3="{\"text\":\"README.md under 15 lines\",\"passed\":false,\"evidence\":\"README has $LINES lines\"}"
    else
      A3='{"text":"README.md under 15 lines","passed":false,"evidence":"README not found"}'
    fi

    # Assertion 4: Functional specs contain no code blocks
    CODE_IN_FUNC=false
    if [ -d "$DOCS/functional" ]; then
      for f in "$DOCS/functional"/*.md; do
        [ ! -f "$f" ] && continue
        [ "$(basename "$f")" = "index.md" ] && continue
        if grep -qE '```(sql|clojure|dockerfile|bash)|CREATE |defn |def |FROM |COPY |CMD ' "$f"; then
          CODE_IN_FUNC=true; break
        fi
      done
    fi
    [ "$CODE_IN_FUNC" = "false" ] && A4='{"text":"Functional specs have no code blocks","passed":true,"evidence":"No code found in functional specs"}' || A4='{"text":"Functional specs have no code blocks","passed":false,"evidence":"Code blocks found in functional specs"}'

    # Assertion 5: Technical doc exists for sync/real-time
    FOUND_SYNC=false
    if [ -d "$DOCS/technical" ]; then
      for f in "$DOCS/technical"/*.md; do
        [ ! -f "$f" ] && continue
        if grep -qiE 'redis|pub.sub|real.time|sync|websocket' "$f"; then
          FOUND_SYNC=true; break
        fi
      done
    fi
    [ "$FOUND_SYNC" = "true" ] && A5='{"text":"Technical doc covers sync/real-time architecture","passed":true,"evidence":"Sync/real-time content found in technical docs"}' || A5='{"text":"Technical doc covers sync/real-time architecture","passed":false,"evidence":"No sync/real-time content in technical docs"}'

    # Assertion 6: No content duplicated between README and docs/index.md
    DUP_FOUND=false
    IDX="$DOCS/index.md"
    if [ -n "$README" ] && [ -f "$IDX" ]; then
      if grep -qE 'clojure -P|createdb|clojure -M:migrate' "$README" && grep -qE 'clojure -P|createdb|clojure -M:migrate' "$IDX"; then
        DUP_FOUND=true
      fi
      if grep -qE '/api/' "$README" && grep -qE '/api/' "$IDX"; then
        DUP_FOUND=true
      fi
    fi
    [ "$DUP_FOUND" = "false" ] && A6='{"text":"No content duplicated between README and docs/index.md","passed":true,"evidence":"No duplicate setup commands or endpoints found"}' || A6='{"text":"No content duplicated between README and docs/index.md","passed":false,"evidence":"Setup commands or API endpoints found in both README and docs/index.md"}'

    # Assertion 7: docs/index.md favors category indexes over leaf docs
    FUNC_LEAF_COUNT=0
    TECH_LEAF_COUNT=0
    if [ -f "$IDX" ]; then
      FUNC_LEAF_COUNT=$(grep -oE 'notes[^/]*\.md|notebook[^/]*\.md|sharing[^/]*\.md|search[^/]*\.md|collaborat[^/]*\.md' "$IDX" | wc -l | tr -d ' ')
      TECH_LEAF_COUNT=$(grep -oE 'deployment\.md|sync[^/]*\.md|database[^/]*\.md|architecture\.md' "$IDX" | wc -l | tr -d ' ')
    fi
    if [ "$FUNC_LEAF_COUNT" -ge 3 ] || [ "$TECH_LEAF_COUNT" -ge 3 ]; then
      A7="{\"text\":\"docs/index.md favors category indexes over leaf docs\",\"passed\":false,\"evidence\":\"Recreates category index: $FUNC_LEAF_COUNT functional + $TECH_LEAF_COUNT technical leaf links\"}"
    else
      A7="{\"text\":\"docs/index.md favors category indexes over leaf docs\",\"passed\":true,\"evidence\":\"$FUNC_LEAF_COUNT functional + $TECH_LEAF_COUNT technical leaf links (OK)\"}"
    fi

    grade_json "$BASE/reorganize-docs/$run/$variant" "reorganize-docs-$run-$variant" "[$A1,$A2,$A3,$A4,$A5,$A6,$A7]"
    echo "  Graded -> grading.json"
  done
done

# ============================================================
# TEST 3: Audit & Fix
# ============================================================

echo "=== Grading Test 3: Audit & Fix ==="

for run in run-1 run-2; do
  for variant in with_skill without_skill; do
    echo "--- $run/$variant ---"
    DIR="$BASE/audit-fix-docs/$run/$variant/outputs"
    [ ! -d "$DIR" ] && echo "  Skipped (no outputs)" && continue
    DOCS=$(resolve_docs "$DIR")

    README_FILE="$DIR/README.md"
    [ ! -f "$README_FILE" ] && README_FILE="$DOCS/../README.md"

    # Assertion 1: Quick start in only one place
    QS_COUNT=0
    [ -f "$README_FILE" ] && grep -qE 'clojure -P|createdb|clojure -M:migrate' "$README_FILE" && QS_COUNT=$((QS_COUNT+1))
    [ -f "$DOCS/index.md" ] && grep -qE 'clojure -P|createdb|clojure -M:migrate' "$DOCS/index.md" && QS_COUNT=$((QS_COUNT+1))
    [ "$QS_COUNT" -le 1 ] && A1="{\"text\":\"Quick start in only one place\",\"passed\":true,\"evidence\":\"Found setup commands in $QS_COUNT locations\"}" || A1="{\"text\":\"Quick start in only one place\",\"passed\":false,\"evidence\":\"Setup commands found in $QS_COUNT locations\"}"

    # Assertion 2: API endpoints in at most one place
    EP_COUNT=0
    [ -f "$README_FILE" ] && grep -qE '/api/v1/' "$README_FILE" && EP_COUNT=$((EP_COUNT+1))
    [ -f "$DOCS/index.md" ] && grep -qE '/api/v1/' "$DOCS/index.md" && EP_COUNT=$((EP_COUNT+1))
    [ "$EP_COUNT" -le 1 ] && A2="{\"text\":\"API endpoints in at most one place\",\"passed\":true,\"evidence\":\"Endpoints found in $EP_COUNT top-level locations\"}" || A2="{\"text\":\"API endpoints in at most one place\",\"passed\":false,\"evidence\":\"Endpoints found in $EP_COUNT locations\"}"

    # Assertion 3: README under 10 lines
    if [ -f "$README_FILE" ]; then
      LINES=$(wc -l < "$README_FILE" | tr -d ' ')
      [ "$LINES" -le 10 ] && A3="{\"text\":\"README.md under 10 lines\",\"passed\":true,\"evidence\":\"README has $LINES lines\"}" || A3="{\"text\":\"README.md under 10 lines\",\"passed\":false,\"evidence\":\"README has $LINES lines\"}"
    else
      A3='{"text":"README.md under 10 lines","passed":false,"evidence":"README not found"}'
    fi

    # Assertion 4: product-catalog.md has no SQL
    PC="$DOCS/functional/product-catalog.md"
    if [ -f "$PC" ] && ! grep -qE 'CREATE TRIGGER|tsvector_update_trigger|```sql' "$PC"; then
      A4='{"text":"product-catalog.md has no SQL code","passed":true,"evidence":"No SQL found"}'
    elif [ ! -f "$PC" ]; then
      A4='{"text":"product-catalog.md has no SQL code","passed":true,"evidence":"File removed or not in outputs"}'
    else
      A4='{"text":"product-catalog.md has no SQL code","passed":false,"evidence":"SQL code still present"}'
    fi

    # Assertion 5: order-processing.md has no Clojure code
    OP="$DOCS/functional/order-processing.md"
    if [ -f "$OP" ] && ! grep -qE '```clojure|defn |async/pipeline' "$OP"; then
      A5='{"text":"order-processing.md has no Clojure code","passed":true,"evidence":"No Clojure code found"}'
    elif [ ! -f "$OP" ]; then
      A5='{"text":"order-processing.md has no Clojure code","passed":true,"evidence":"File removed or not in outputs"}'
    else
      A5='{"text":"order-processing.md has no Clojure code","passed":false,"evidence":"Clojure code still present"}'
    fi

    # Assertion 6: docs/index.md favors category indexes over leaf docs
    IDX="$DOCS/index.md"
    FUNC_LEAF_COUNT=0
    TECH_LEAF_COUNT=0
    if [ -f "$IDX" ]; then
      FUNC_LEAF_COUNT=$(grep -oE 'product-catalog\.md|shopping-cart\.md|order-processing\.md' "$IDX" | wc -l | tr -d ' ')
      TECH_LEAF_COUNT=$(grep -oE 'architecture\.md|development\.md|order-pipeline\.md' "$IDX" | wc -l | tr -d ' ')
    fi
    if [ "$FUNC_LEAF_COUNT" -ge 3 ] || [ "$TECH_LEAF_COUNT" -ge 3 ]; then
      A6="{\"text\":\"docs/index.md favors category indexes over leaf docs\",\"passed\":false,\"evidence\":\"Recreates category index: $FUNC_LEAF_COUNT functional + $TECH_LEAF_COUNT technical leaf links\"}"
    else
      A6="{\"text\":\"docs/index.md favors category indexes over leaf docs\",\"passed\":true,\"evidence\":\"$FUNC_LEAF_COUNT functional + $TECH_LEAF_COUNT technical leaf links (OK)\"}"
    fi

    # Assertion 7: Tech stack not duplicated
    TS_COUNT=0
    [ -f "$README_FILE" ] && grep -qiE 'Clojure 1\.12|Ring.*Reitit|next\.jdbc|buddy' "$README_FILE" && TS_COUNT=$((TS_COUNT+1))
    [ -f "$DOCS/technical/architecture.md" ] && grep -qiE 'Clojure 1\.12|Ring.*Reitit' "$DOCS/technical/architecture.md" && TS_COUNT=$((TS_COUNT+1))
    [ "$TS_COUNT" -le 1 ] && A7="{\"text\":\"Tech stack not duplicated\",\"passed\":true,\"evidence\":\"Stack info in $TS_COUNT location(s)\"}" || A7="{\"text\":\"Tech stack not duplicated\",\"passed\":false,\"evidence\":\"Stack info in $TS_COUNT locations\"}"

    grade_json "$BASE/audit-fix-docs/$run/$variant" "audit-fix-docs-$run-$variant" "[$A1,$A2,$A3,$A4,$A5,$A6,$A7]"
    echo "  Graded -> grading.json"
  done
done

echo "=== Grading complete ==="
