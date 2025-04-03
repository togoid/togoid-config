# TogoID ver. 2.0
Datasets last updated: 2025-04-03

## About
- [TogoID](https://togoid.dbcls.jp/) is an ID conversion service implementing unique features with an intuitive web interface and an API for programmatic access. TogoID supports datasets from various biological categories such as gene, protein, chemical compound, pathway, disease, etc. TogoID users can perform exploratory multistep conversions to find a path among IDs. To guide the interpretation of biological meanings in the conversions, we crafted an [ontology](https://togoid.dbcls.jp/ontology) that defines the semantics of the dataset relations.
- The TogoID service is freely available on the [TogoID](https://togoid.dbcls.jp/) website, and the [API](https://togoid.dbcls.jp/apidoc/) is also provided to allow programmatic access.
- To encourage developers to add new dataset pairs, the source code for extracting ID relations is publicly available at [GitHub](https://github.com/dbcls/togoid-config). TogoID performs weekly updates using the programs.
- See the "DATASETS" tab for a list of supported datasets.

## Video tutorial
- [How to use TogoID ver 2.0: an exploratory ID converter to bridge biological datasets](https://youtu.be/ORW1GGIaJsY)

## Statistics (as of 2025-04-03)
- Number of target datasets 
    - 105 (from 73 databases)
- For details on the target DBs and ID examples, please refer to the "DATASETS" tab. 

Some databases include records in multiple categories of concepts. In TogoID, such databases are subdivided into "datasets" to avoid ambiguity in what an ID mean. For example, the Ensembl database is subdivided into three datasets: Ensembl gene, Ensembl transcript, and Ensembl protein.

## Web user interface

### EXPLORE
In the EXPLORE mode, you can perform exploratory multi-step ID conversion, where you can convert your ID list to the IDs of another dataset and subsequently to another dataset.
![Fig-1A](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig1A.jpg)
1. The input IDs. You can directly paste your ID list to the window or upload your text file. Newline/Comma/Space-separated lists are allowed.

2. The candidate datasets of the input IDs. The numbers on the right side indicate how many of the input IDs match the regular expression pattern of the ID notation of the dataset.

3. The datasets directly linked to the input dataset. The numbers on the left side indicate how many of the input IDs can be converted to at least one ID of the dataset. Meanwhile, the numbers on the right side indicate how many unique IDs of the dataset are included in the conversion result.

4. The relationships between datasets. These are defined in the [TogoID ontology](https://togoid.dbcls.jp/ontology).

5. The datasets linked to the dataset selected as the first conversion target.

6. Menu that appears when you hover the cursor over a dataset. Clicking the table icon on the left opens the Results window (see below). The download icon in the middle is a shortcut to directly download the converted ID list. The information icon (i) on the right shows the details about the dataset.


### NAVIGATE
In the NAVIGATE mode, you can find paths that link your input dataset to a destination dataset and perform the ID conversion through the selected path.

![Fig-1B](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig1B.jpg)
![Fig-1C](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig1C.jpg)

7. The candidate datasets of the input IDs.

8. The drop-down list to select a destination dataset. You can enter characters to filter the datasets.

9. The paths to link the input dataset to the destination. Up to 2 datasets can be passed through.

### Results modal window
In the modal window displayed when the table icon is clicked in the EXPLORE or NAVIGATE mode, you can preview the conversion result table with up to 100 lines. After you select a table format, you can download the entire results or copy them to the clipboard.
![Fig-1D](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig1D.jpg)
You can configure the table with the radio buttons.  
You can download the table or copy it to your clipboard. The format of the downloaded or copied table is the same as the previewed table.

10. Report  
- All converted IDs: Shows the converted IDs, with IDs of the datasets passed through.
- Source and target IDs: Shows only the source and target IDs.
- Target IDs: Shows only the target IDs.
- All including unconverted IDs: When input IDs are not converted to any target ID, they are included in the table and the corresponding cells show blank.

11. Format  
- Expanded: The default mode, which displays the normalized table.
- Compact: When multiple IDs are linked to an ID of the previous step, the converted IDs are displayed on one line in comma-separated manner.

12. Action  
You can download the entire result in the format shown in Preview or copy it to the clipboard.  
Copy API URL: Copies the API URL for downloading the conversion result in the currently displayed format to the clipboard.  
Copy CURL: Copies the `curl` command to use the API with the POST method to download the conversion result in the currently displayed format to the clipboard.

13. Show labels
Sliding the switch shows the labels for the IDs. Labels are not available for some datasets, for technical reasons or due to the term of use of original databases.

14. If there are multiple patterns for the ID notation, you can specify the pattern in this drop-down list. For example, for Gene Ontology IDs, you can choose the prefix "GO:" or "GO_". You can also display the URL for each entry in the original database.

![Fig-1E](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig1E.jpg)

15. If you just want to get the labels for the input IDs without converting the IDs, hover over the dataset and click the table icon.

16. In the modal window, click Show labels to display the labels.

### LABEL2ID
The LABEL2ID tab allows you to convert labels to IDs, e.g. gene symbols to NCBI Gene IDs or disease names to MONDO IDs.
#### Gene symbols to NCBI Gene IDs
![Fig-2A](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig2A.jpg)
1. The Input labels. Only a newline is allowed as a label delimiter because labels may contain spaces.

2. Drop-down list for selecting a dataset.

3. Drop-down list for selecting a species. Since the database may use the same gene symbol for multiple species, it is necessary to specify the species to identify the ID to be mapped. Only major species are included in the drop-down list. If you cannot find the one you are looking for, enter the Taxonomy ID directly in the input window on the right.

4. Selection of the type of label to target. You can select whether to include synonyms.

5. After selecting the conditions, click the EXECUTE button.

![Fig-2B](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig2B.jpg)

6. The Table of conversion results.

- Input: The input IDs.
- Match type: What type of label was matched.
- Symbol: The main symbols of the corresponding IDs.
- ID: The IDs obtained as a result of conversion.

7. Click "Convert IDs" to convert the IDs obtained as a result of conversion in the EXPLORE mode.

#### Disease names to MONDO IDs
For conversions of disease names etc., fuzzy matching is allowed.

![Fig-2C](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig2C.jpg)

8. The ambiguity score threshold to tolerate in label matches. Threshold can be set to a value between 0.5 and 1. When this is set to 1, only exact matched labels are allowed, while lower values allow for less strict matches.

![Fig-2D](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig2D.jpg)
9. The matching score is shown on the result table.

### DATASETS
The DATASETS tab shows the details of the datasets TogoID covers.
![Fig-3A](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig3A.jpg)
1. Filters by dataset categories.
2. The datasets linked to this dataset. The number indicates how many of ID pairs exist between these datasets. By clicking a dataset name you can jump to the dataset on this page.
3. Example IDs. This also shows ID patterns that can be entered. For HP phenotype, patterns with the prefixes "HP:" and "HP_" are available. Clicking this will enter the IDs into the ID input field and you can try converting them.

## API
TogoID is also available as an API, which allows other applications to use it for ID conversion.  
For details, see [API Documentation (Swagger)](https://togoid.dbcls.jp/apidoc/).  
Below are examples to obtain the result of the conversion from NCBI Gene IDs to PDB IDs via UniProt IDs.
1. [Obtain as JSON with unconverted IDs](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,uniprot,pdb&format=json&report=full)
2. [Obtain only source and target IDs as tsv](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,uniprot,pdb&format=tsv&report=pair)

For LABEL2ID, TogoID uses [PubDictionaries](https://pubdictionaries.org/). [The dictionaries used in TogoID](https://pubdictionaries.org/users/togoid) is publicly available, and you can access it through the PubDictionaries API.  
e.g. [Retrieve human gene symbols including synonyms and convert them to NCBI Gene IDs](https://pubdictionaries.org/find_ids.json?labels=ACE2%7CHIF2A&dictionaries=togoid_ncbigene_symbol,togoid_ncbigene_synonym&tags=9606&threshold=1&verbose=true)

## Publication
- Shuya Ikeda, Kiyoko F Aoki-Kinoshita, Hirokazu Chiba, Susumu Goto, Masae Hosoda, Shuichi Kawashima, Jin-Dong Kim, Yuki Moriya, Tazro Ohta, Hiromasa Ono, Terue Takatsuki, Yasunori Yamamoto, Toshiaki Katayama, Expanding the concept of ID conversion in TogoID by introducing multi-semantic and label features, J Biomed Semantics. 2025 Jan 8;16(1):1. [doi:10.1186/s13326-024-00322-1](https://doi.org/10.1186/s13326-024-00322-1).

- Shuya Ikeda, Hiromasa Ono, Tazro Ohta, Hirokazu Chiba, Yuki Naito, Yuki Moriya, Shuichi Kawashima, Yasunori Yamamoto, Shinobu Okamoto, Susumu Goto, Toshiaki Katayama, TogoID: an exploratory ID converter to bridge biological datasets, _Bioinformatics_, 2022;, btac491, [https://doi.org/10.1093/bioinformatics/btac491](https://doi.org/10.1093/bioinformatics/btac491)
