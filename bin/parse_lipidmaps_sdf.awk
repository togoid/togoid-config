BEGIN {
    OFS = "\t"
    RS = "\n\\$\\$\\$\\$\n"
    FS = "\n\n"
    attrs_str = "LM_ID NAME SYSTEMATIC_NAME CATEGORY MAIN_CLASS SUB_CLASS CLASS_LEVEL4 EXACT_MASS FORMULA INCHI_KEY INCHI SMILES SYNONYMS PUBCHEM_CID CHEBI_ID SWISSLIPIDS_ID HMDB_ID LIPIDBANK_ID"
    n_attrs = split(attrs_str, attrs, " ")
}

{
    for (i=1; i<=NF; i++) {
        n = split($i, lines, "\n")

        ## Some entries do not have a blank line separating the MOL block from the property blocks. This is valid in the SDF definition.
        ## To find a property that follows the MOL block, find the end of the MOL block ("M  END") and recreate the `lines` array as the lines after the MOL block.
        if (i==1 && lines[n]!="M  END") {
            m_end_n = 0
            for (k=1; k<=n; k++) {
                if (lines[k] == "M  END") {
                    m_end_n = k
                    break
                }
            }
            if (m_end_n) {
                for (k=m_end_n+1; k<=n; k++) {
                    temp[k-m_end_n] = lines[k]
                }
                delete lines
                for (k in temp)
                    lines[k] = temp[k]
                delete temp
            }
        }

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
