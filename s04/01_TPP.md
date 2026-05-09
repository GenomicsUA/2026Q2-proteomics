# Get started

Open WSL in `2026Q2-proteomics` directory.

```bash
cd ~/projects/2026Q2-proteomics
```

Follow directions and copy code blocks into WSL shell.

# Run TPP docker

```bash
docker run -it --rm \
-u 0 \
-v ~/projects/2026Q2-proteomics/data_s04:/data \
biocontainers/tpp:v5.2_cv1 bash
```

Now you are inside docker container.

Set input files as variables.

```bash
MGF="130327_o2_01_hu_C1_2hr.mgf"
FASTA="UP000005640_9606.fasta"
BASE=$(basename "${MGF}" .mgf)
MZML="${BASE}.mzML"
```

Convert file.

```bash
msconvert $MGF --mzML
```

Generate Comet parameters file.

```bash
comet -p
```

Check `comet.params.new` contents. Navigate with up/down arrows. To exit press `Ctrl+C`.

```bash
less comet.params.new
```
Set database path and mode inside `comet.params.new` file.

```bash
sed -i "s|^database_name =.*|database_name = ${FASTA}|" comet.params.new
sed -i "s|^decoy_search =.*|decoy_search = 1|" comet.params.new
```

Add another variable modification - phosphorilation.

```bash
sed -i \
's/^variable_mod02.*/variable_mod02 = 79.966331 STY 0 3 -1 0 0/' \
comet.params.new
```

Change default parameters to high resolution mode.

```bash
sed -i "s|^fragment_bin_tol =.*|fragment_bin_tol = 0.02|" comet.params.new
sed -i "s|^fragment_bin_offset =.*|fragment_bin_offset = 0.0|" comet.params.new
sed -i "s|^theoretical_fragment_ions =.*|theoretical_fragment_ions = 0|" comet.params.new
sed -i "s|^spectrum_batch_size =.*|spectrum_batch_size = 10000|" comet.params.new
```

Run search.

```bash
comet -Pcomet.params.new $MZML
```

Check if expected output exist.

```bash
PEPXML="${BASE}.pep.xml"
ls $PEPXML ]]
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

Install xml parcer.

```bash
apt-get update
apt-get install -y xmlstarlet
```

Convert to mzIdentML and read file with `mzID` library in R.

```bash
tpp2mzid interact.ptm.pep.xml
tpp2mzid interact.prot.xml
```

# Extra. Sample code for R parsing

```r
library(mzID)

mzid <- mzID("interact.ptm.pep.mzid")

psm <- flatResults(mzid)
```