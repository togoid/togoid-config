BEGIN {
    OFS = "\t"
    RS = "\n\\$\\$\\$\\$\n"
    FS = "\n\n"
    attrs_str = "LM_ID NAME SYSTEMATIC_NAME CATEGORY MAIN_CLASS SUB_CLASS CLASS_LEVEL4 EXACT_MASS FORMULA INCHI_KEY INCHI SMILES SYNONYMS PUBCHEM_CID CHEBI_ID SWISSLIPIDS_ID HMDB_ID LIPIDBANK_ID"
    n_attrs = split(attrs_str, attrs, " ")
}

{
    for (i=1; i<=NF; i++) {
        split($i, lines, "\n")
        for (j=1; j<=n_attrs; j++) {
            if (lines[1] == "> <" attrs[j] ">") {
                vals[attrs[j]] = lines[2]
            }
        }
    }
    for (j=1; j<=n_attrs; j++) {
        if (attrs[j] != "LM_ID" && vals[attrs[j]])
            print vals["LM_ID"], attrs[j], vals[attrs[j]]
    }

    delete vals
}
