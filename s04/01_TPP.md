# Get started

Open WSL in `2026Q2-proteomics` directory.

```bash
cd ~/projects/2026Q2-proteomics
```

Follow directions and copy code blocks into WSL shell.

# Run TPP docker

```bash
docker run -it --rm \
-v ~/data_s04:/data_s04 \
biocontainers/tpp:v5.2_cv1 bash
```

Now you are inside docker container.

Set input files as variables.

```bash
MGF="data_s04/ms/130327_o2_01_hu_C1_2hr.mgf"
FASTA="data_s04/db/UP000005640/UP000005640_9606.fasta"
BASE=$(basename "${MGF}" .mgf)
```

Generate Comet parameters file.

```bash
comet -p > comet.params
```

Check `comet.params` contents. Navigate with up/down arrows. To exit press `Ctrl+C`.

```bash
less comet.params
```
Set database path inside `comet.params` file.

```bash
sed -i "s|^database_name =.*|database_name = ${FASTA}|" comet.params
```

Run search.

```bash
comet -Pcomet.params $MGF
```

Check if expected output exist.

```bash
PEPXML="${BASE}.pep.xml"

if [[ ! -f $PEPXML ]]; then
    echo "ERROR: pepXML not produced"
    exit 1
fi
```

Check pepXML contents. Note the structure.

```bash
less $PEPXML
```

Run identifications rescoring.

```bash
xinteract -Ninteract.pep.xml $PEPXML
```

Run modifications localisation rescoring.

```bash
PTMProphetParser KEEPOLD interact.pep.xml interact.ptm.pep.xml
```

Run protein inference.

```bash
ProteinProphet interact.ptm.pep.xml interact.prot.xml
```

Check protXML contents. Note the structure.

```bash
less interact.prot.xml
```

Type `Ctrl+D` to exit interactive docker.


# Extra. Full run, less typing

Before lanching docker, copy `s04/sample_tpp_run.sh` into `data_s04/` directory.

```bash
cp s04/sample_tpp_run.sh data_s04/
```

After lanching docker, enter data directory and execute script.

```bash
bash s04/sample_tpp_run.sh
```

# Extra. Make TPP output readable by R

Turn pepXML and protXML into tsv.

```bash
PepXML2TSV interact.ptm.pep.xml > interact.ptm.pep.tsv
ProteinProphet2TSV interact.prot.xml > interact.prot.tsv
```

OR

Convert to mzIdentML and read file with `mzID` library in R. Works for PSM level only.

```bash
PepXML2MzIdentML interact.ptm.pep.xml psm.mzid
```

# Extra. Sample code for R parsing

For `.tsv`.

```r
install.packages(c("readr", "dplyr"))

library(readr)
library(dplyr)

psm <- read_tsv("interact.ptm.pep.tsv")
prot <- read_tsv("interact.prot.tsv")
```

For `.mzid`.

```r
library(mzID)

mzid <- mzID("psms.mzid")

psm <- flatResults(mzid)
```