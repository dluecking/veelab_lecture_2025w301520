## Block 4

### Project 2: Recombination events in Hepatitis D virus

## Preparation of sequences

We have already downloaded the complete dataset cds fasta file from the HDVdb (contains Genbank S-HDAg and L-HDAg nucleotide sequences,https://hdvdb.bio.wzw.tum.de/hdvdb/home/download) and cleaned it up for this exercise. You can find it in data/hdv_clean.fasta

**Step 1: First, check the number of sequences and their lengths, what do you observe?**

```bash
    awk '
  /^>/{if(seqlen){print seqlen}; seqlen=0; next}
  {seqlen+=length($0)}
  END{print seqlen}
' hdv_clean.fasta > lengths.txt
sort -n lengths.txt | uniq -c
```
**Step 2: Align all your sequences and view in aliview**
As in the previous exercise, we will align using `mafft`.

```bash
module load mafft
mafft --thread 4 --maxiterate 1000 --auto hdv_clean.fasta > hdv_clean_aligned.fasta
```
**Can you explain what you observe in the alignment?**
<details>
  <summary>
    Solution
  </summary>
Most sequences are around 580-588bp or 642-645 bp long, corresponding to the two isoforms of HDAg, short and long. The alignment shows nicely, that the sequences differ in their last amino acids, that are a result of the RNA editing.
</details>

Since the L-HDAg tail evolves separately, we will focus on the core ORF and trim to the small HDAg sequence for recombination analysis.
**Step 3: Translation, trimming and back-translation**
Let's translate our sequences, to prevent frameshifts when trimming (normally we would check all 3 frames, but sequences in our dataset are expected in frame 1, so we can stick with it)

```bash
seqkit translate --allow-unknown-codon --frame 1 --transl-table 1 --seq-type dna --threads 2 hdv_clean.fasta > hdv_protein.fasta
```
You should now see the stop codon within the sequence in some sequences, we will now trim those.
The first stop codon (*) in the translated protein is usually the S-HDAg stop codon. Any later stop codons are part of L-HDAg or extended ORFs, so you can ignore them for trimming S-HDAg.

```bash
seqkit seq -w 0 hdv_protein.fasta \
| awk -v min=194 -v max=196 '
  /^>/ {header=$0; next} 
  {
    seq=$0;
    split(seq, a, "*");           # trim at first stop codon
    trimmed=a[1];
    if(length(trimmed)>=min && length(trimmed)<=max)
        print header "\n" trimmed
  }
' > S_HDAg_only.fasta
```
To be able to back-translate with pal2nal we will need the nucleotide sequences for recombination analysis, let's prepare that file. We will use the header until the first **|** sign (only the accession ID) and omit the remaining part of the header.
```bash
conda activate seqkit
seqkit seq -n S_HDAg_only.fasta | cut -d'|' -f1 > S_HDAg_core_IDs.txt
seqkit grep -r -f S_HDAg_core_IDs.txt hdv_clean.fasta -o hdv_nucleotide_S_HDAg.fasta
```
Let's check if they match:
```bash
seqkit fx2tab S_HDAg_only.fasta | cut -f1 > protein_ids.txt
seqkit fx2tab hdv_nucleotide_S_HDAg.fasta | cut -f1 > nucleotide_ids.txt
diff protein_ids.txt nucleotide_ids.txt
```
If **diff** outputs nothing → the protein and nucleotide FASTAs have exactly matching IDs, you're ready for pal2nal!

Next align your trimmed protein sequences and run pal2nal (attention: headers must match exactly and be in the same order for pal2nal)
```bash
mafft --thread 4 --maxiterate 1000 --auto  S_HDAg_only.fasta >  S_HDAg_aligned.fasta
perl ../scripts/pal2nal.pl S_HDAg_aligned.fasta hdv_nucleotide_S_HDAg.fasta -output fasta -codontable 1 > S_HDAg_na.fasta
```

**Step 4: Running VirusRecom**
Now we're ready to run our recombination detection tool on our newly sequenced HepD sample, which is saved as seq1.fasta in your `data` directory.
VirusRecom requires both, the reference sequences and your query sequence to be in your fasta file, so we need to add the 8 reference genotype sequences and your query sequence to our S_HDAg_na.fasta.
Let's first check how many sequences we have in total:
`grep -c ">" S_HDAg_na.fasta`
Now, let's add the other sequences and align them

```bash
cat S_HDAg_na.fasta seq1.fasta hdv_refs.fasta > hdv_all.fasta
mafft --thread 4 --maxiterate 1000 --auto  hdv_all.fasta >  hdv_all_aligned.fasta
```
You can check the number of sequences again to verify.
Lastly, VirusRecom requires a **reference_gt_name.txt** that contains the exact headers of our reference genotype sequences as a list, this file has been prepared already and is also in /data. VirusRecom will match against these.









