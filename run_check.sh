tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)

cp analyzeHeadless /ghidra/support

/ghidra/support/analyzeHeadless $tmp_dir ghidra -import $(realpath $1) -scriptPath `pwd` -postScript NewScript.java