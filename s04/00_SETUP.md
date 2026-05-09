# Copy GitHub repository with code

Open WSL in Ubuntu bash shell mode.

Check if you have `git` installed.

```bash
git --version
```

If not, install. You will need to type in your password.

```bash
sudo apt update
sudo apt install -y git
```

Get local copy of course repository in `projects` folder and enter it.

```bash
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/GenomicsUA/2026Q2-proteomics.git
cd 2026Q2-proteomics
```

# Get data

Download one spectra file from PRIDE Archive. This will take ~5 minutes.

```bash
mkdir data_s04
wget -P data_s04/ https://ftp.pride.ebi.ac.uk/pride/data/archive/2016/02/PXD002057/130327_o2_01_hu_C1_2hr.mgf
#https://ftp.pride.ebi.ac.uk/pride/data/archive/2016/02/PXD002057/130327_o2_01_hu_C1_2hr.raw
```

Download proteins database from UniProt.

```bash
wget -P data_s04/ https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
gunzip data_s04/db/UP000005640_9606.fasta.gz
```

# Install docker for TPP

Run code blocks in WSL Ubuntu shell.

Add Docker’s official GPG key.

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

Add Docker repository.

```bash
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install Docker Engine.

```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Verify Docker is running.

```bash
sudo systemctl status docker
```

Test run.

```bash
sudo docker run hello-world
```

Add yourself to docker group to never run docker with sudo again.

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Get TPP.

```bash
docker pull biocontainers/tpp:v5.2_cv1
```
