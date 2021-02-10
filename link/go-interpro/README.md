- 元データ（go.owl）（一部、長い記述を略）

```
    <!-- http://purl.obolibrary.org/obo/GO_0008194 -->

    <owl:Class rdf:about="http://purl.obolibrary.org/obo/GO_0008194">
        <rdfs:subClassOf rdf:resource="http://purl.obolibrary.org/obo/GO_0016757"/>
        <obo:IAO_0000115 rdf:datatype="http://www.w3.org/2001/XMLSchema#string">Catalysis of the transfer of a glycosyl group ...</obo:IAO_0000115>
        <oboInOwl:hasDbXref rdf:datatype="http://www.w3.org/2001/XMLSchema#string">Reactome:R-HSA-162730</oboInOwl:hasDbXref>
        <oboInOwl:hasOBONamespace rdf:datatype="http://www.w3.org/2001/XMLSchema#string">molecular_function</oboInOwl:hasOBONamespace>
        <oboInOwl:id rdf:datatype="http://www.w3.org/2001/XMLSchema#string">GO:0008194</oboInOwl:id>
        <rdfs:label rdf:datatype="http://www.w3.org/2001/XMLSchema#string">UDP-glycosyltransferase activity</rdfs:label>
    </owl:Class>
    <owl:Axiom>
        <owl:annotatedSource rdf:resource="http://purl.obolibrary.org/obo/GO_0008194"/>
        <owl:annotatedProperty rdf:resource="http://purl.obolibrary.org/obo/IAO_0000115"/>
        <owl:annotatedTarget rdf:datatype="http://www.w3.org/2001/XMLSchema#string">Catalysis of the transfer of a glycosyl group ...</owl:annotatedTarget>
        <oboInOwl:hasDbXref rdf:datatype="http://www.w3.org/2001/XMLSchema#string">InterPro:IPR004224</oboInOwl:hasDbXref>
        <oboInOwl:hasDbXref rdf:datatype="http://www.w3.org/2001/XMLSchema#string">PMID:11846783</oboInOwl:hasDbXref>
    </owl:Axiom>
    <owl:Axiom>
        <owl:annotatedSource rdf:resource="http://purl.obolibrary.org/obo/GO_0008194"/>
        <owl:annotatedProperty rdf:resource="http://www.geneontology.org/formats/oboInOwl#hasDbXref"/>
        <owl:annotatedTarget rdf:datatype="http://www.w3.org/2001/XMLSchema#string">Reactome:R-HSA-162730</owl:annotatedTarget>
        <rdfs:label rdf:datatype="http://www.w3.org/2001/XMLSchema#string">phosphatidylinositol + UDP-N-acetyl-D-glucosamine -&gt; ...</rdfs:label>
    </owl:Axiom>
```

- 今回はInterProとのペアを取りたいのだが、InterProのリンクは<owl:Axiom>の中（ということで要検討）
- そもそもEndpointに入っているよね。。。

