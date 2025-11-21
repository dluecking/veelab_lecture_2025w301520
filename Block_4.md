# Block 4

## Project 2: Recombination events in Hepatitis D virus

### Preparation of sequences

We have already downloaded the complete dataset cds fasta file from the HDVdb (contains Genbank S-HDAg and L-HDAg nucleotide sequences, https://hdvdb.bio.wzw.tum.de/hdvdb/home/download) and cleaned it up for this exercise. You can find it in `data/hdv_clean.fasta`.

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
Most sequences are around 580-588bp or 642-645 bp long, corresponding to the two isoforms of HDAg, short and long. The alignment shows nicely, that the sequences differ in their last amino acids, whih is a result of the RNA editing.
</details>


Since the L-HDAg tail evolves separately, we will focus on the core ORF and trim to the small HDAg sequence for recombination analysis.

**Step 3: Translation, trimming and back-translation**

Let's translate our sequences, to prevent frameshifts when trimming (normally we would check all 3 frames, but sequences in our dataset are expected in frame 1, so we can stick with it)

```bash
module load conda
conda activate seqkit-2.10.1
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

### Recombination Analysis

Now we're ready to run our recombination detection tool (publication: https://doi.org/10.1093/bib/bbac513) on our newly sequenced HepD sample, which is saved in `data/seq1.fasta`.
VirusRecom requires both, the reference sequences and your query sequence to be in your fasta file, so we need to add the 8 reference genotype sequences and your query sequence to our `S_HDAg_na.fasta.

Let's first check how many sequences we have in total:

`grep -c ">" S_HDAg_na.fasta`

Now, let's add the other sequences and align them

```bash
cat S_HDAg_na.fasta seq1.fasta hdv_refs.fasta > hdv_all.fasta
mafft --thread 4 --maxiterate 1000 --auto  hdv_all.fasta >  hdv_all_aligned.fasta
```

You can check the number of sequences again to verify.

**Run VirusRecom**

Lastly, VirusRecom requires a **reference_gt_name.txt** that contains the exact headers of our reference genotype sequences as a list, this file has been prepared already and is also in `/data. VirusRecom will match against these.

```bash
module load VirusRecom
virusrecom -a hdv_all_aligned.fasta -q seq1 -l reference_gt_name.txt -cp 0.9 -g y -m m -w 50 -s 10 -o output_dir
```

Here's what the command flags mean:

`-cp 0.9` (confidence/probability cutoff)

`-g y` (consider gaps)

`-m m` (scanning method, "p" means use polymorphic sites only, "m" all sites)

`-w 50` (window length)

`-s 10` (step)

`-o output_dir` (output directory)


### Analyse output

VirusRecom will run quickly and you should see the process on your terminal.
When it's done, you can navigate to your output directory and look for the two important files `Possible_recombination_event_conciseness.txt` and the `WICs_of_slide_window/seq1_mWIC_from_lineages.pdf`.
The first txt file gives you a short summary of the results. If there was a minor detected with statistical significance, it will be stated here. The figure in the pdf is a combined ancestry + confidence plot.

X-axis = position in the aligned S-HDAg nucleotide sequence

Y-axis = mWIC (mean weighted information content)

Colored lines = each reference genotype’s WIC contribution over windows


<details>
  <summary>
    How to read the plot?
  </summary>
Each individual reference genotype is plotted across the alignment of the S-HDAg sequence. The highest line shows which genotype fits that region the best, while an increase of another genotype would be a predicted recombination switch. If you only observe a dominant top line, it would mean that there is no recombination in that region. The y-axis shows the mWIC. If the WIC is low, it would mean that the sequence in the window fits well to a single genotype and that any divergence is due to within-genotype mutations. If it is high, more than a single genotype could explain that region. Shortly, mWIC is a threshold/measure to decide for mutations vs. recombination.
</details>


**Finally, discuss your results:**

- Does VirusRecom predict any possible parent genotype? Are any significant recombination regions identified? How do you interpret it?
- Could the result be due to sequencing error, PCR recombination, or alignment artifact? How would you test that?
- Repeat the last command but try different window sizes, e.g. 30 and 100. Why would a smaller window size produce false positives? What trade-offs are expected with a larger window size?






