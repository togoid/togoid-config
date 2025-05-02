# interpro-uniprot
## 20250430
Update:
The input file of this config (`protein2ipr.dat`) is quite large (> 90 GB).
Its contents are like below:
```tsv
A0A000	IPR004839	Aminotransferase, class I/classII, large domain	PF00155	41	381
A0A000	IPR010961	Tetrapyrrole biosynthesis, 5-aminolevulinic acid synthase	TIGR01821	12	391
A0A000	IPR015421	Pyridoxal phosphate-dependent transferase, major domain	G3DSA:3.40.640.10	48	288
A0A000	IPR015422	Pyridoxal phosphate-dependent transferase, small domain	G3DSA:3.90.1150.10	36	378
A0A000	IPR015424	Pyridoxal phosphate-dependent transferase	SSF53383	9	389
A0A000	IPR050087	8-amino-7-oxononanoate synthase class-II	PTHR13693	37	382
A0A001	IPR003439	ABC transporter-like, ATP-binding domain	PF00005	361	503
A0A001	IPR003439	ABC transporter-like, ATP-binding domain	PS50893	344	573
A0A001	IPR003593	AAA+ ATPase domain	SM00382	369	550
A0A001	IPR011527	ABC transporter type 1, transmembrane domain	PF00664	17	276
```
Basically, this config extracts the first and second columns from the input file. However, as seen the example of `A0A001	IPR003439`, some pairs of UniProt ID and InterPro ID can be duplicates, because a single InterPro ID can refer IDs from multiple member databases (column 4). To ensure the output file does not contain duplicates, the method used to sort and uniq. However, the input file recently became too large to sort and thus this config failed.

Since `protein2ipr.dat` has been confirmed to be pre-sorted, this config does not need to sort it. `sort -c` can determine whether a file is sorted in linear time relative to its size. The updated method performs this check in advance to ensure that the process will terminate with an error even if the input file is later modified and becomes unsorted. With this guarantee in place, the subsequent command has been changed to simply execute `uniq`.

If the input file is actually modified in the future to become unsorted, a different solution will be required.
