#!/bin/bash
# Parse command line arguments
ACTION=${1:-default}

case $ACTION in
    default)
        FINAL_REPORT="submission-report.md"
        FINAL_REPORT_OUTPUT="submission-report.docx"
        ;;
    *)
        echo "Unknown action: $ACTION"
        echo "Usage: $0 [example]"
        exit 1
        ;;
esac

# Clean previous builds and reports
rm -f $FINAL_REPORT
rm -f $FINAL_REPORT_OUTPUT
make clean 2>&1 > /dev/null

# Generate timestamp and machine info
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
MACHINE=$(uname -a)
echo "# Submission Report" > $FINAL_REPORT
echo "- Submission generated at $TIMESTAMP" >> $FINAL_REPORT
echo "- Machine info: $MACHINE" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT
echo "---" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

# Build all in debug and release mode and capture output
echo "## Build Output" >> $FINAL_REPORT
echo '```bash' >> $FINAL_REPORT
make all 2>&1 | tee -a $FINAL_REPORT
echo '```' >> $FINAL_REPORT
echo "" >> $FINAL_REPORT
echo "---" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

# Capture coverage report
echo "## Coverage Report" >> $FINAL_REPORT
echo '```bash' >> $FINAL_REPORT
make report 2>&1 | tee -a $FINAL_REPORT
echo '```' >> $FINAL_REPORT
echo "" >> $FINAL_REPORT
echo "---" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

# Capture memory leak report
echo "## Address Sanitizer Report" >> $FINAL_REPORT
echo '```bash' >> $FINAL_REPORT
make leak-test 2>&1 | tee -a $FINAL_REPORT
echo '```' >> $FINAL_REPORT
echo "" >> $FINAL_REPORT
echo "---" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

# Capture all files in src/
echo "## Source Files" >> $FINAL_REPORT
for file in src/*; do
    if [[ -f $file ]]; then
        echo "### $(basename $file)" >> $FINAL_REPORT
        echo '```c' >> $FINAL_REPORT
        cat "$file" >> $FINAL_REPORT
        echo "" >> $FINAL_REPORT
        echo '```' >> $FINAL_REPORT
        echo "" >> $FINAL_REPORT
        echo "---" >> $FINAL_REPORT
        echo "" >> $FINAL_REPORT
    fi
done

# Capture all files in test/
echo "## Test Files" >> $FINAL_REPORT
for file in tests/*; do
    if [[ -f $file ]]; then
        echo "### $(basename $file)" >> $FINAL_REPORT
        echo '```c' >> $FINAL_REPORT
        cat "$file" >> $FINAL_REPORT
        echo "" >> $FINAL_REPORT
        echo '```' >> $FINAL_REPORT
        echo "" >> $FINAL_REPORT
        echo "---" >> $FINAL_REPORT
        echo "" >> $FINAL_REPORT
    fi
done

# Capture README.md
if [[ -f README.md ]]; then
    echo "## README.md" >> $FINAL_REPORT
    echo '```markdown' >> $FINAL_REPORT
    cat README.md >> $FINAL_REPORT
    echo "" >> $FINAL_REPORT
    echo '```' >> $FINAL_REPORT
    echo "" >> $FINAL_REPORT
    echo "---" >> $FINAL_REPORT
    echo "" >> $FINAL_REPORT
fi

exit 0