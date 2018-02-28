zcat $1 | grep -v "^#" | awk '{print $1}' | sort | uniq -c | sort -k1nr | head -n $2
