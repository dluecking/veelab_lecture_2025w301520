# Block 2

## Alignment
The plan is to align the translated amino acid sequences of the HA and NA proteins, then align them, then back-translate them to nucleotide sequences and then finally align these nucleotide sequences.

Why the back-and-forth translating step?
<details>
  <summary>
    Solution
  </summary>
There are 2 main reasons for this:
  
a) AA sequences are more conserved. Due to the degeneracy of the genetic code (multiple codons can code for the same amino acid), the nucleotide sequence of a gene evolves much faster than its corresponding amino acid sequence. The third position in a codon (the "wobble base") can often change without affecting the protein at all. Therefore, IN SOME CASES, aligning the nucleotide sequence can give a more detailed picture of the true evolutionary history. However...

b) Since the fundamental unit of a protein is the **codon** (a triplet of nucleotides), keeping the frame is essential for aligning. Hence, if we would align 2 nucleotide sequences right away, the aligner might introduce gaps and therefore shift one of the sequences, completely removing the codon information.

By going back and forth like the way we do this, we avoid b) while having the nice advantages of a).
  
</details>

For these steps, we move to `tree/`:

`$ cd ../tree`

**Step 1: AA Alignment**
We will align the sequences with `muscle` (https://www.drive5.com/muscle/ or wikipedia). Its a solid and widely used aligner, which can handle our ~800 sequences. 

```bash
muscle -super5 ../processed_HA_NA/HA_genes_newHead_corrFrame.faa -output HA_genes_aligned.aln;
muscle -super5 ../processed_HA_NA/NA_genes_newHead_corrFrame.faa -output NA_genes_aligned.aln;

```
