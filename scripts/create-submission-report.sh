#!/bin/bash
# Parse command line arguments

while getopts "mh" opt; do
    case $opt in
        m)
            DOCX=false
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        h)
            echo "Usage: $0 [-a action] [-o output_file]"
            echo "  -m    Create the markdown report only"
            echo "  -h    Display this help message"
            exit 0
            ;;
    esac
done

# Default values
DOCX=${DOCX:-true}
FINAL_REPORT=${FINAL_REPORT:-submission-report.md}
FINAL_REPORT_OUTPUT=${FINAL_REPORT_OUTPUT:-submission-report.docx}

# Determine script and root directory paths robustly
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}" )" &> /dev/null && pwd -P )"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"
echo "Project root: ${ROOT_DIR}"

pushd "$ROOT_DIR" > /dev/null || exit 1

# Clean previous builds and reports
rm -f $FINAL_REPORT
rm -f $FINAL_REPORT_OUTPUT
make clean 2>&1 > /dev/null

# Generate timestamp and machine info
TIMESTAMP_START=$(date +"%m/%d/%Y at %H:%M:%S")
MACHINE=$(uname -a)
echo "Generating submission report ..."

# Use a here document to write the initial content of the report
cat <<EOF > $FINAL_REPORT
# Submission Report
- Submission generated at $TIMESTAMP_START
- Machine info: $MACHINE

---

## Build Output
\`\`\`bash
$(make all 2>&1)
\`\`\`

---

## Coverage Report
\`\`\`bash
$(make report 2>&1)
\`\`\`

---

## Address Sanitizer Report
\`\`\`bash
$(make leak-test 2>&1)
\`\`\`

---

EOF

# Append the contents of all src/ files to the report
for file in src/*; do
    if [ -f "$file" ]; then
        echo -e "\n---\n" >> $FINAL_REPORT
        echo "## Source File: $(basename "$file")" >> $FINAL_REPORT
        echo '```c' >> $FINAL_REPORT
        cat "$file" >> $FINAL_REPORT
        echo "" >> $FINAL_REPORT
        echo '```' >> $FINAL_REPORT
        echo "" >> $FINAL_REPORT
    fi
done

# Append the contents of the tests/ directory to the report
if [ -d "tests" ]; then
    echo -e "\n---\n" >> $FINAL_REPORT
    echo "## Test Files" >> $FINAL_REPORT
    for test_file in tests/*; do
        if [ -f "$test_file" ]; then
            echo "### $(basename "$test_file")" >> $FINAL_REPORT
            echo '```bash' >> $FINAL_REPORT
            cat "$test_file" >> $FINAL_REPORT
            echo '```' >> $FINAL_REPORT
            echo "" >> $FINAL_REPORT
            echo "" >> $FINAL_REPORT
        fi
    done
fi

# Append the README file if it exists
if [ -f "README.md" ]; then
    echo -e "\n---\n" >> $FINAL_REPORT
    echo "## README" >> $FINAL_REPORT
    echo '```markdown' >> $FINAL_REPORT
    cat "README.md" >> $FINAL_REPORT
    echo "" >> $FINAL_REPORT
    echo '```' >> $FINAL_REPORT
    echo "" >> $FINAL_REPORT
fi

echo -e "\n---\n" >> $FINAL_REPORT
echo "## End of Report" >> $FINAL_REPORT

TIMESTAMP_END=$(date +"%m/%d/%Y at %H:%M:%S")
echo "Report generated on $TIMESTAMP_END" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

if [ "$DOCX" = true ]; then
    echo "Converting to DOCX format ..."
    pandoc -s -o $FINAL_REPORT_OUTPUT $FINAL_REPORT
    rm -f $FINAL_REPORT
    echo "Created DOCX report at $FINAL_REPORT_OUTPUT"
else
    echo "Created markdown report at $FINAL_REPORT"
fi
popd > /dev/null || exit 1
echo "Done."