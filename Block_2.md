<img width="969" height="584" alt="image" src="https://github.com/user-attachments/assets/ff854115-1deb-4a03-bd7a-8a73374a31e8" /># Block 2: Processing of sequence dataset

## Visualise file

```bash
less sequences_IA_HA_NA.fasta;
```
Click <kbd>↑</kbd> and <kbd>↓</kbd> to navigate through the file visualisation.

Click <kbd>Q</kbd> to exit the viewing.

<details>

<summary>See output</summary>

![](./images/sequences_IA_HA_NA_less.png)

</details>
<br/>

---
## Count sequences
```bash
grep -c ">" sequences_IA_HA_NA.fasta;
```
<br/>

---
## Look at headers: too long and too much information 🤮
```bash
grep ">" sequences_IA_HA_NA.fasta | less;
```
`| less` is used to pass the output of `grep ">" sequences_IA_HA_NA.fasta`. This allows us to scroll through the ouput in a similar fashion as before.

<details>

<summary>See output</summary>

![](./images/sequences_IA_HA_NA_less_headers.png)

</details>
<br/>

---
## Get sequences only for those where both the Hemagglutinin (HA) and Neuraminidase (NA) gene sequences are available
```bash
grep "^>" sequences_IA_HA_NA.fasta | grep -v "KC95119[68]" | sed 's/.\+virus (//' | sed 's/)) [a-z]\+ .\+/)/' | uniq -c | grep -P "^\s+2" | sed 's/^\s\+2 //' > HA_NA_genes.lst;
```

- Command breakdown

```bash
grep "^>" sequences_IA_HA_NA.fasta \ # grab only the header (lines starting with ">").
| grep -v "KC95119[68]" \            # remove accessions KC951196 and KC951198
| sed 's/.\+virus (//' \             # remove all text preceding the virus name*.
| sed 's/)) [a-z]\+ .\+/)/' \        # remove all text following the virus name*.
| uniq -c \                          # get a unique list of the identifiers and count the number of occurrences
| grep -P "^\s+2" \                  # select only those lines where exactly two sequences are found per unique identifier
| sed 's/^\s\+2 //' \                # remove the count preceding the identifier
> HA_NA_genes.lst;                   # output result to file containing the list
```

<details>

<summary>* internationally accepted naming convention for influenza viruses</summary>

![](./images/influenza_naming_diagram_CDC.jpg)

Source: Modified from http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2395936/pdf/bullwho00427-0070.pdf

</details>

<details>

<summary>See output</summary>

```bash
grep "^>" sequences_IA_HA_NA.fasta | grep -v "KC95119[68]" | less;
```

![](./images/HA_NA_genes_01.png)

```bash
grep "^>" sequences_IA_HA_NA.fasta | grep -v "KC95119[68]" | sed 's/.\+virus (//' | less;
```

![](./images/HA_NA_genes_02.png)

```bash
grep "^>" sequences_IA_HA_NA.fasta | grep -v "KC95119[68]" | sed 's/.\+virus (//'  | sed 's/)) [a-z]\+ .\+/)/' | less;
```

![](./images/HA_NA_genes_03.png)

```bash
grep "^>" sequences_IA_HA_NA.fasta | grep -v "KC95119[68]" | sed 's/.\+virus (//'  | sed 's/)) [a-z]\+ .\+/)/' | uniq -c | less;
```

![](./images/HA_NA_genes_04.png)

```bash
grep "^>" sequences_IA_HA_NA.fasta | grep -v "KC95119[68]" | sed 's/.\+virus (//'  | sed 's/)) [a-z]\+ .\+/)/' | uniq -c | grep -P "^\s+2" | less;
```

![](./images/HA_NA_genes_05.png)

```bash
grep "^>" sequences_IA_HA_NA.fasta | grep -v "KC95119[68]" | sed 's/.\+virus (//'  | sed 's/)) [a-z]\+ .\+/)/' | uniq -c | grep -P "^\s+2" | sed 's/^\s\+2 //' | less;
```

![](./images/HA_NA_genes_06.png)

</details>
<br/>

---
### Let's count how many unique identifiers (i.e. unique viruses) occurr **only** twice
```bash
wc -l HA_NA_genes.lst;
```
<br/>

---
### Now, let's filter out those unique viruses for which either HA or NA genes are missing 
```bash
perl filter_and_separate.pl HA_NA_genes.lst sequences_IA_HA_NA.fasta;
```
See [filter_and_separate.pl](./scripts/filter_and_separate.pl)

We get two files created
   - HA_genes.ffn
   - NA_genes.ffn

Important: From now one we are working on two file streams: the hemagglutinin ("HA") and the Neuraminidase ("NA").

<br/>

---
### Now, let's filter out those unique viruses for which either HA or NA genes are missing 
```bash
sed 's/>\(\S\+\) \S\+ .\+|\(H[0-9]\+N[0-9]\+\)|[^|]\+|[0-9]\+|\(\S\+\)/>\1|\2|\3/' HA_genes.ffn | sed 's/\s\+/_/g' > HA_genes_newHead.ffn;
sed 's/>\(\S\+\) \S\+ .\+|\(H[0-9]\+N[0-9]\+\)|[^|]\+|[0-9]\+|\(\S\+\)/>\1|\2|\3/' NA_genes.ffn | sed 's/\s\+/_/g' > NA_genes_newHead.ffn;
```

- Command breakdown

Given the following example header

\>NC_026433.1 |Influenza A virus (A/California/07/2009(H1N1)) segment 4 hemagglutinin (HA) gene, complete cds|Alphainfluenzavirus influenzae|H1N1|4|1701|USA|Homo sapiens|2009-04-09

```regex
>\(\S\+\)
```

"NC_026433.1". "\\\(text\\\)" saves to \\1, \\2, \\3, ...


```regex
 \S\+ .\+|
```

" |Influenza A virus (A/California/07/2009(H1N1)) segment 4 hemagglutinin (HA) gene, complete cds|Alphainfluenzavirus influenzae|".

```regex
\(H[0-9]\+N[0-9]\+\)
```
"H1N1". Saved to \\2.

```regex
|[^|]\+|[0-9]\+|'
```
"|4|1701|"

```regex
\(\S\+\)'
```
"USA|Homo sapiens|2009-04-09". Saved to \\3

```regex
>\1|\2|\3/
```
Substitute whole header string with ">NC_026433.1|H1N1|USA|Homo_sapiens|2009-04-09".
- \\1: "NC_026433.1".
- \\2: "H1N1".
- \\3: "USA|Homo_sapiens|2009-04-09".

```bash
sed 's/\s\+/_/g'
```
Substitute all continuous white spaces with a single "_".


<details>

<summary>See output</summary>

```bash
grep ">" HA_genes_newHead.ffn | less;
```

![](./images/HA_genes_newHead.png)

</details>
<br/>

---
