# Emily's Notes for Street Art Dataset + Analysis

# Personal notes/things to do:
06/29
Update on cosine similarity:
<img width="379" height="193" alt="image" src="https://github.com/user-attachments/assets/066dc8a5-3d1b-4d0f-a63c-b4e481da9d76" />

DTM vs DFM???
<img width="681" height="517" alt="image" src="https://github.com/user-attachments/assets/7c13f037-8370-4028-8605-fba6739e8d9c" />

Most pop words
<img width="729" height="482" alt="image" src="https://github.com/user-attachments/assets/5503a5cf-b490-4bde-9b84-720642e08f68" />


Notes from 06/27 -- 
- I'm thinking it might be better to do image analysis than text analysis...
- google cloud vision api first 1,000 free?

Notes from 06/25 -- working on doing text analysis and grouping by regions, and I have noticed one thing in particular:

There are a lot of local street art institutions -- kotis street art (greensboro, nc), el muralcho/lefchek (houston, tx AKA bayou city). These are often mentioned in the descriptions. Although I am struggling with getting info from the text analysis about the sentiments, I definitely have noticed that there are groups/individuals that care very deeply about collecting/documenting/sharing information about local murals. It seems to be a very local thing that some people are very passionate about.

<img width="874" height="263" alt="image" src="https://github.com/user-attachments/assets/a654d114-27e1-4004-87af-df1113bbf8a7" />
<img width="874" height="263" alt="image" src="https://github.com/user-attachments/assets/cce5b2f6-9b16-4a7e-81b6-f5a01cc08feb" />
<img width="874" height="263" alt="image" src="https://github.com/user-attachments/assets/99e993a5-6415-4b78-b677-e87b0effab20" />
<img width="874" height="263" alt="image" src="https://github.com/user-attachments/assets/0f07e978-b2ce-47e5-af0e-d219feba356a" />


remove the photo created + date situation? unsure... -'photo taken' or 'curated by' -  (more html tags too?) -project -mural -NA -art - the place... - numbers

- [ ] do the text analysis recommended by Emily Kurtz
- [ ] make robot help with custom stop words, see what it looks like.
- [ ] consider larger unit of analysis.
- [ ] third consideration - break down by some categerocial variable (be it politics, region, etc.) and do text analysis that identifies the polarized words - Emily to send literature/tutorial

- [ ] could potentially make it even more narrow: https://www2.census.gov/geo/pdfs/maps-data/maps/reference/us_regdiv.pdf

readings:
- [ ] https://cran.r-project.org/web/packages/conversim/vignettes/Analyzing_Similarities_between_Two_Long_Speeches.html
- [x] https://medium.com/@celine.vdr/natural-language-processing-word-embeddings-e0b2edc773d2
- [x] https://www.google.com/amp/s/www.r-bloggers.com/2015/10/text-mining-analysis-some-theory-and-practice-in-r/amp/
  - [ ] couldn't access the article within here that had the info on how to do it


cosine similarity

tf-idf
`TF-IDF (Term Frequency-Inverse Document Frequency) is a numerical statistic used in text analysis to reflect how important a word is to a document in a collection or corpus. It highlights words that are frequent in a specific document but rare across all documents, making them highly characteristic`
