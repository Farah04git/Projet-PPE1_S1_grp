#!/bin/bash

INPUT="$1"
OUTPUT="$2"

echo "<html><head><meta charset='UTF-8'><title>PALS arabe</title></head><body><table border='1'>" > "$OUTPUT"

# header
head -n 1 "$INPUT" | awk -F'\t' '{ 
  printf "<tr>"; 
  for(i=1;i<=NF;i++) printf "<th>%s</th>", $i; 
  print "</tr>"; 
}' >> "$OUTPUT"

# rows
tail -n +2 "$INPUT" | awk -F'\t' '{ 
  printf "<tr>"; 
  for(i=1;i<=NF;i++) printf "<td>%s</td>", $i; 
  print "</tr>"; 
}' >> "$OUTPUT"

echo "</table></body></html>" >> "$OUTPUT"
