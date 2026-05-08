```bash
#!/usr/bin/env bash

set -euo pipefail

############################################
# INPUT FILES
############################################

MGF="ms/130327_o2_01_hu_C1_2hr.mgf"
FASTA="db/UP000005640/UP000005640_9606.fasta"

############################################
# OUTPUT PREFIX
############################################

BASE=$(basename "${MGF}" .mgf)

############################################
# CHECK REQUIRED TOOLS
############################################

echo "Checking tools..."

which comet
which xinteract
which PTMProphetParser
which ProteinProphet

############################################
# GENERATE DEFAULT COMET PARAMETERS
############################################

echo "Generating Comet parameters..."

comet -p > comet.params

############################################
# MODIFY COMET PARAMETERS
############################################

echo "Setting FASTA database..."

sed -i "s|^database_name =.*|database_name = ${FASTA}|" comet.params

############################################
# RUN COMET SEARCH
############################################

echo "Running Comet..."

comet \
-Pcomet.params \
"${MGF}"

############################################
# EXPECTED OUTPUT:
# sample.pep.xml
############################################

PEPXML="${BASE}.pep.xml"

if [[ ! -f "${PEPXML}" ]]; then
    echo "ERROR: pepXML not produced"
    exit 1
fi

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
