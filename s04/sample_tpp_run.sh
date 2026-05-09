```bash
#!/usr/bin/env bash

set -euo pipefail

############################################
# INPUT FILES
############################################

MGF="130327_o2_01_hu_C1_2hr.mgf"
FASTA="UP000005640_9606.fasta"
BASE=$(basename "${MGF}" .mgf)
MZML="${BASE}.mzML"

############################################
# CHECK REQUIRED TOOLS
############################################

echo "Checking tools..."

which comet
which xinteract
which PTMProphetParser
which ProteinProphet

############################################
# CONVERT FILE
############################################

msconvert $MGF --mzML

############################################
# GENERATE DEFAULT COMET PARAMETERS
############################################

echo "Generating Comet parameters..."

comet -p

############################################
# MODIFY COMET PARAMETERS
############################################

echo "Setting FASTA database..."

sed -i "s|^database_name =.*|database_name = ${FASTA}|" comet.params.new
sed -i "s|^decoy_search =.*|decoy_search = 1|" comet.params.new
sed -i 's/^variable_mod02.*/variable_mod02 = 79.966331 STY 0 3 -1 0 0/' comet.params.new
sed -i "s|^fragment_bin_tol =.*|fragment_bin_tol = 0.02|" comet.params.new
sed -i "s|^fragment_bin_offset =.*|fragment_bin_offset = 0.0|" comet.params.new
sed -i "s|^theoretical_fragment_ions =.*|theoretical_fragment_ions = 0|" comet.params.new
sed -i "s|^spectrum_batch_size =.*|spectrum_batch_size = 10000|" comet.params.new

############################################
# RUN COMET SEARCH
############################################

echo "Running Comet..."

comet \
-Pcomet.params \
"${MZML}"

############################################
# EXPECTED OUTPUT:
# sample.pep.xml
############################################

PEPXML="${BASE}.pep.xml"
ls $PEPXML

############################################
# RUN PEPTIDEPROPHET
############################################

echo "Running PeptideProphet..."

xinteract \
-Ninteract.pep.xml \
"${PEPXML}"

############################################
# RUN PTMPROPHET
############################################

echo "Running PTMProphet..."

PTMProphetParser \
KEEPOLD \
interact.pep.xml \
interact.ptm.pep.xml

############################################
# RUN PROTEINPROPHET
############################################

echo "Running ProteinProphet..."

ProteinProphet \
interact.ptm.pep.xml \
interact.prot.xml

############################################
# FINISHED
############################################

echo "Pipeline finished."

echo "Generated files:"
ls -lh interact*
```
