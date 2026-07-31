# Emily Kretschmer's Notes

## July 31

- [x] download the USDA datasets that Emily sent me
- [x] Wrangle unemployment dataset (widen)
- [ ] wrangle education dataset
- [ ] get libraries data into it as well
- [x] add legend for the choropleth map
- [ ] add choropleth map into shiny app somehow...
- [x] try out color quantile for choropleth map
- [x] fix the quantile legend
- [ ] add another graph for side-by-side with the choropleth of unemployment rates?
  - [ ] I was really inspired by this graphic: https://r-graph-gallery.com/web-map-choropleth-quantile.html but I don't think that this is really possible in leaflet. So maybe a side-by-side histogram or boxplot or something will have to suffice.
- [ ] also somehow throw in the national average?


Notes/notices
MD, VT, NH have very low comparative unemployment rates
<img width="838" height="528" alt="image" src="https://github.com/user-attachments/assets/2a6f3a80-3b5a-43ed-a799-71656c2859bd" />



I think quantile is the best bet

added some borders... not sure how i feel about it
<img width="838" height="528" alt="image" src="https://github.com/user-attachments/assets/b39ce472-c926-4f52-9957-dee4d2ccec9e" />


I tried out color quantile on the usda unemployment rate leaflet map...
I am #confused
Oh Ifigured it out
<img width="838" height="528" alt="image" src="https://github.com/user-attachments/assets/365c21b9-4c8f-4b75-bec4-7c9ee6eb5595" />

Color Bin with 10 (reversed color pallete):
<img width="838" height="528" alt="image" src="https://github.com/user-attachments/assets/871d9b75-1385-498b-bb8b-ce13752ac2f9" />

Vs Color Quantile with 10 (reversed color pallete):
<img width="838" height="528" alt="image" src="https://github.com/user-attachments/assets/16ed7b66-e84f-4cf2-a0ed-ee1f35547800" />

I like these color palette but I wish the order was flipped -->
<img width="838" height="528" alt="image" src="https://github.com/user-attachments/assets/9a46eeaf-7580-4d2e-803f-8f32fd6fb995" />


Mapps
https://www.axismaps.com/guide

Regex
- https://regex101.com/

USDA Data
- https://www.ers.usda.gov/data-products/county-level-data-sets/county-level-data-sets-download-data
- PCTPOVALL_2023 = estimated percent of the total population in poverty for the year 2023

Education/schools
- https://nces.ed.gov/ccd/files.asp
- https://educationdata.urban.org/data-explorer/explorer
- https://educationdata.urban.org/documentation/schools.html
- https://nces.ed.gov/datalab/
- https://nces.ed.gov/programs/edge/Geographic/SchoolLocations
- https://catalog.data.gov/dataset/public-school-locations-2022-23
- <mark>https://cran.rstudio.com/web/packages/BLSloadR/BLSloadR.pdf</mark>

Dates of states
- https://www.britannica.com/place/list-of-US-states-by-date-of-admission-to-the-Union-2130026
- https://www.britannica.com/quiz/us-states-dates-of-admission-to-the-union-quiz

Taxes by state
- https://taxfoundation.org/datamaps/state-maps/
- https://taxfoundation.org/data/all/state/2026-sales-tax-rates-midyear/
- https://taxfoundation.org/blog/minnesota-wealth-tax/
- https://taxfoundation.org/data/all/state/state-income-tax-rates-2026/
- https://taxfoundation.org/data/all/state/tax-burden-by-state-2022/

Page + layout/look
- https://github.com/eparker12/nCoV_tracker/blob/master/app.R
- https://shiny.posit.co/r/articles/
- https://bootswatch.com/
- https://bootswatch.com/lux/
- https://bootswatch.com/help/
- https://shiny.posit.co/py/api/core/ui.navbar_options.html
- https://shiny.posit.co/r/layouts/panels-cards/
- https://shiny.posit.co/r/layouts/
- <mark>https://www.nceas.ucsb.edu/sites/default/files/2020-04/colorPaletteCheatsheet.pdf</mark>

Walkability
- https://americawalks.org/resources/walkable-land-use/
- Inspo: https://www.ers.usda.gov/amber-waves/2025/august/us-obesity-rate-changes-differ-for-rural-and-urban-areas-as-well-as-across-regions
- 

## July 30
- [x] get the bar graph to show up on main page
- [x] get bar graph to change when JUST the state is changed (not categories etc)
- [x] also get bar graph to change to USA when all is selected!
- [x] maybe change from count to percent
- [ ] maybe reactivity to selecting a row on the table or when hovering over a bar on the bar chart
- [ ] maybe # of schools bt county -- and layer on top of number of hist dist
- [x] do BLS employment data
  - [x] get a V2 api key
- [ ] schooling data?

- [ ] BLS data/help
  - [ ] https://www.bls.gov/developers/termsOfService.htm
  - [ ] https://www.bls.gov/developers/
  - [ ] https://www.bls.gov/developers/api_r.htm
  - [ ] https://github.com/mikeasilva/blsAPI
  - [ ] https://cran.rstudio.com/web/packages/BLSloadR/BLSloadR.pdf
  - [ ] https://www.bls.gov/charts/state-employment-and-unemployment/industry-employment-by-state.htm#
  - [ ] ^ industry by state!!
     
Sticking points:
- blsapi vs blsloadr package...
- blsapi
  - i just want the unemployment rate locally for one year... not really a time series
- adjusted vs unadjusted unemployment rate -- _"The adjusted unemployment rate is a statistical calculation that removes predictable, calendar-driven shifts, while the unadjusted rate shows the raw, actual percentage of jobless people actively looking for work"_

did some county unemployment rate stuff (still need to add key and labels etc) this is just prelim map
<img width="1436" height="849" alt="image" src="https://github.com/user-attachments/assets/e9fecaa7-8de8-496c-9f40-671be3ea7404" />


before...
<img width="1436" height="849" alt="image" src="https://github.com/user-attachments/assets/0429db4e-1502-43be-85d6-7838ec2268b5" />

after...
<img width="1436" height="849" alt="image" src="https://github.com/user-attachments/assets/4c454d50-5776-4902-943a-63dc7626b3d0" />

---
<img width="1436" height="849" alt="image" src="https://github.com/user-attachments/assets/ae4503db-8062-410a-8ec4-16945143ca1d" />
<img width="1436" height="849" alt="image" src="https://github.com/user-attachments/assets/b3815ff4-c49d-447b-8c6a-4b267eb49349" />

Research
- https://www.bls.gov/charts/state-employment-and-unemployment/industry-employment-by-state.htm#


## July 29


does an area having a historic district benefit it? (--> pride)
^ poverty rate
^ crime rate
^ housing prices
^ schools (maybe wanting to have kids/stay there?)
choropleth + graduated symbols
^ businesses

**notes**
- Getting back into the swing of things
  - partly trying to figure out where I left off...
  - updating packages and rerunning things
 
  - almost all historic districts seem to be architecture
  - on the about or main page of historic districts should prob explain what i'm actually meaning with historic districts
  - code book?

** research **
- https://taxfoundation.org/data/all/state/2026-state-tax-data/
  - taxes per capita
  - maybe not the besstt way to measure it since income but
  - Continuing using this site has helped me find this:
    - https://taxfoundation.org/data/all/state/2026-state-tax-data/, the pdf led me to another site to this:
      - https://taxfoundation.org/data/all/state/tax-burden-by-state-2022/
      - ^ the first table basically shows what percent of their income residents end up paying on taxes
      - could scrape this ~
      - <img width="352" height="81" alt="image" src="https://github.com/user-attachments/assets/71e06ec7-d0b9-4eaf-b301-e9aee9323b26" />


** things to do **

Historic districts 
- Finder explanation of page
- Fixing the issue where there are some dots in the wrong spots -- ex gainesville alabama is mapped to NC...
  - maybe offer an option for submitting a "complaint"?
  - maybe also should explain this issue in the finder explanation
- Extend analysis paragraph
- Maybe for analysis page -- offer an option for the user to see what the OG states were and/or what year each state was "established"
- maybe taxes by state
**- maybe add county lines.**
- maybe offer it all on one page so that the user can select which layers to view
- maybe add back the number of historic districts by state graph
- [ ] FIX DESELECTING ISSUE on site!
- [x] try to do some clustering (but did not like it)
- [ ] saipe datasets from census with an api
- [ ] probably should change all of the names of variables to be better (like map2... not great name especially since it's the first map lol)

Street art
- Not sure...
- I remember feeling like I had hit a roadblock with the text analysis
  - I'm not sure if I should try to keep going with it or just let it be and move on to trying something else (or just let street art be altogether)
  - I wish I knew how to do image analysis for the photos from the web
  - What about dates...
 
Libraries
- could be an indicator of xyz
- looked at ian's exploration R file -- wowow very cool

Other 
Need to check in with her about the following ~
- Blog post
- Personal bio

## July 02!
Historic districts

- [x] get better theme
- [x] For the ggplot -- make it just the top 5 or 10 or something
- [x] make into plotly
- [x] fix the ggplot -- it's too small and doesn't look so nice. figure out how to match to shiny theme
- [x] fix the tabs
- [x] fix switch to cards
- [x] fix the state selector overlapping thing
- [x] add filter for state
- [x] add the table
- [x] add an option to check all for categories
- [x] maybe make a function
- [x] for states, just outline the one selected.
- [x] fix how the table looks
- [ ] maybe change the circle markers to the number things
- [ ] start working on blog post thing
  - [ ] mention that historic districts can fall into multiple categories
- [x] maybe change standardization to % of acres that are historic districts?
- [x] switch ggplot to ggplotly
- [x] fix tooltip on ggplotly
- [x] fix scrolling issue
- [ ] **investigate cali and colorado!**


personal notes
- [ ] look into other data
- [ ] look into animations!
- [ ] racial demographics?
- [ ] taxes/resources
- [ ] undercounting/bias/resouces? -- qualitative
- [ ] per capita


## June 29
#### Historic districts
- [ ] check for consistency in territory names (N. Mariana Islands)
- [ ] add filter for state + type of industry (drop down)
- [ ] display dataset with those filters ^

### Street art
- [ ] add more stop words
  - [ ] maybe clean the city id column so that there's no hyphens and then tokenize that and remove those words
- [ ] get new, cleaner version of street art qmd
- [ ] go back to other resources/readings for text analysis for street art
- [x] get cosine similarity working
- [ ] figure out polarized words situation
- [ ] bigrams???

#### News outlets
- [ ] import data into R

#### Libraries
- [ ] get api into r

<img width="1470" height="888" alt="image" src="https://github.com/user-attachments/assets/2c43fca0-8860-4605-98fe-de8fd5858a81" />


## June 25

#### Street art
- [x] read emily's notes
- [x] make robot help with custom stop words, see what it looks like. consider larger unit of analysis.
- [x] third consideration - break down by some categerocial variable (be it politics, region, etc.) and do text analysis
  - [ ] that identifies the polarized words
- [x] read emily's readings
- [x] get point geometry for each mural
- [x] get region for each mural




## June 24
#### Historic districts
- [x] start shiny app
  - [x] do reverse text stuff
  - [x] make a zoom thing on the state selected
  - [x] eliminate the ones from the bar graph that have counts = 0
- [x] start the mapping of standardization

#### Libraries
- [x] investigate careeronestop
- [x] email request api key

## June 23
#### Historic districts
- [X] get the land area via census scraping (make sure to document!)
- [x] widen the categorical variable
- [x] remove dupes
- [x] work on fixing documentation of cleaning


Notes:
- `addProviderTiles("Stadia.StamenWatercolor")` love this

## June 22
- think about questions
- libraries
- tf idf thing

#### Historic districts
- [x] fix washington etc addresses
- [x] make a choropleth!
- [x] double check that historic districts is actually correct (right number of rows, etc.)
- [x] double check washington addresses... def wrong for some (ex seattle chinatown?)
  -  fml **it's county, state, but it should really be city, state -- basically need to redo all the geocoding frick**
    -  align with team???
    -  try my dad's computer?
    -  row 11740 (39 in Rstudio I think), Seattle Chinatown, has the wrong coordinates. It's geocoded as being in DC when it's not.
- [x] check `Warning in validateCoords(lng, lat, funcName): Data contains 100 rows with either missing or invalid lat/lon values and will be ignored`
  - I must have somehow accidentally changed the first 100 rows so something went wrong. Need to fix it now yikes.
  - `write_csv(historic_districts_updated, "historic_districts_clean2.csv")`
<img width="794" height="498" alt="image" src="https://github.com/user-attachments/assets/de4ed13a-671b-4533-b0ed-ece1b6fe7304" />

- Deleted (because it was almost exactly the same as another thing):
```
  for(r in 101:nrow(historic_districts)){
  temp_row <- historic_districts[r,] %>% 
    geocode(address, method = 'arcgis', lat = latitude , long = longitude)
  
  historic_districts_CLEAN_2 <- rbind(historic_districts_CLEAN_2, temp_row)
  
  if(r %% 75 == 0){
    Sys.sleep(2)  # pause 2 seconds between batches
    cat("Batch", r, "done\n")  # progress tracking
    #Save progress to disk so you can resume if it crashes partway through:
    write_csv(historic_districts_CLEAN_2, "geocoded_progress_2.csv")
  }
  
}
```

## June 19
Goals:
- [ ] get historic_districts dataset FULLY cleaned
  - [x] get long and lat (!)
    - [x] check that it is actually correct (right number of rows, etc.)
  - [ ] widen area_of_significance
- [ ] import news outlet data into R
  - [ ] investigate whether or not long/lat is needed
- [ ] further analyze text analysis of murals
  - [ ] come up with potential questions/extensions
Methods for getting long and lat: 
- `arcgis`: times out. takes forever. handles messy addresses well, though. (no API key)
  - <img width="794" height="417" alt="image" src="https://github.com/user-attachments/assets/5ac3fc9a-5696-4c8a-bb06-128fe680118f" />
- `osm`: takes even longer (100 seconds for 100) and not accurate (doesn't handle the messy addresses well.) (no API key)
- `census`: does not handle messy addresses well (at least for this) -- all NAs. but fast --1.3 secs(no API key)
- `here`: requires API key
  - Sign up for account: https://developer.here.com/
  - IT MAKES ME PUT MY CREDIT CARD IN kill me now
 
2nd round: 3226
3rd round: 6076
4th round: 8326
5th round: 12376 (but it didn't throw an error???) (stopped at Cheyenne Veterans Administration Hospital Historic District)
why is it stopping???
oh it was because it didn't write the final one -- I just did `write_csv(historic_districts_CLEAN_2[1:12419,], "long_lat_YAY.csv")` to check (since I think I accidentally added 2 rows when I was testing things out)
just re-ran this code until I got all the rows (took a whole day):
<img width="794" height="417" alt="image" src="https://github.com/user-attachments/assets/6d9ef695-cc78-4855-9726-8103135b18dd" />


  

## June 18
- [ ] further clean datasets so that they are presentable
- historic districts
  - [ ] get the long and lat data updated 
- [x] chat with Ian about libraries
  - Ideas: Change over time (which ones closed? -- shut down or new ones), internet speed
     
- #3029 rows
#12419 total.. it can only do 100 at a time..

## June 17
## todo
- [ ] check readme
- libraries
  - [ ] respond to ian
  - [ ] make a qmd
- historic districts
  - [x] map
  - [x] message rimona about geocoder thing
  - [x] uploaded the correct data -- thank you rimona for letting me know of the issues!
    -  `csv_RAW_national-register-listed_20260522.csv`
    -  **having issues getting long and lat now b/c there is so much more data :(**
  - [ ] maybe lengthen area_of_significance
    - [ ] this would be an interesting thing to investigate
  - [x] convert all cols to titlecase - `str_to_title()`
  - [ ] find something to investigate...
    - ideas:
      - 1) urban density of county?
        2) median age (bc historical...)
        3) something about school -- test scores? # of universities?
        4) diversity
        5) maybe do a chloropleth by # of sqr feet of districts by state or something
        6) text analysis of most common names?!
- murals
  - [ ] continue text analysis
- news outlets!
  - [x] got Northwestern News outlet data (State of Local News Report) from Srishti Bose !!
  - [ ] import data to R
    - [ ] figure out how to import .xlsx

### notes
- https://r-graph-gallery.com/182-add-circles-rectangles-on-leaflet-map.html
- `#| eval: false` to reduce the slowness since csv is now saved
- not really sure what to do with text analysis for murals... feeling kind of stuck. wordcloud? eh
- `mutate(across(where(is.character), function))`
- fixed districts data


## June 16
- [x] check back in w/ Emily about osmdata package -- wait won't need this for murals but yes for newspapers potentially?
- [x] merge to add long and lat data for historic districts
  - [ ] message rimona abt this
- [ ] map journalism data
- [x] import mural data
- murals:
  - [x] run `problems(murals)`
  - [x] remove cols where it is 100% NA **having issues? (below in qs)**
  - [x] fix description text so the tags aren't there anymore
  - [x] remove cols that are high in NAs
  - [x] text analysis


### questions
a's from chatting w/ emily:
- yes, lengthen str_split or smth -- use ai chat and make binary for each col
- but the NA thing is prob rounding TBH so just remove those cols as well
- it's ok to take out info not usefull as long as you keep the raw dataset

q's
-  should I lengthen? - separate_wider_delim(x, delim = ",")
  -  ex: Figurative,Realism,Surrealism for artwork style
-  the NA thing ????? update: ok these are not actually 100% NA cols R is tripping me out this viz is wrng??? there are things in those cols
  - so not an issue i guess but here's the pic anyways
  -  <img width="949" height="854" alt="image" src="https://github.com/user-attachments/assets/8805fba5-936d-41a8-900b-043174a6c922" />
- don't want to lose info... but unsure
  - 'photo taken XYZ' and links
- why is it showing "NA" as common word??? it's not a word :(
 
### notes
- murals_clean[[i]] vs murals_clean[,i]
- `murals_clean %>% select(where(function(x) all(is.na(x)))) %>% glimpse()`
- i think switching to streetart generally, rather than murals (since it's not in the dataset)
- htmltools tags?
- maybe add state col?
- powow
- maybe you can like select a word and then see where it is most common?
  - maybe also on teh flipside u could select a place
- "woman" seems to be pretty common lol

## June 15
### Todo
- [x] chat about OSM data...
  - [ ] check to see if it's also mapping NA's

Completed
- [x] email emily about styleguide/naming conventions
murals ---
- [x] imported murals data from streetartcities and did NA for unknown and untitled

### Notes

#### Personal
_Murals_
- lots of them don't have a title or even a description
  - some have title empty, or as `Unknown` or `Untitled` -- going to change this when in R
  - `dttm` type is date time
  - Got these **problems**: <img width="846" height="281" alt="image" src="https://github.com/user-attachments/assets/188467d7-65b0-42d2-b7b2-0c30cd334f0a" />
    - i think a lot of this is because only some rows have values in each of these columns, and
    - a lot of the values are surrounded by [""]
    - For this: `["Nature","Water","Fish","Birds"]` R turned it to `[\"Nature\",\"Water\",\"Fish\",\"Birds\"]` ???
    - some column names have commas -- using gsub (global substitution) to fix this
    - description wrapped in tags <>
    - why are there still 100% NA cols 😭 -- 47 cols in murals_clean and 52 in murals whatttt but still some fully na
      - <img width="241" height="281" alt="image" src="https://github.com/user-attachments/assets/d9d1594c-b5a5-4ad9-9f23-ce6d15e3bb33" />



_Historic districts_
- historic districts vs historic sites in the historic landmarks dataset -- right now I am just using text analysis to dig into the name of the property and see if `historic district` is in it, but there's actually a `category of property` variable --
  - district for most, but site for some...
  - also it is all caps sometimes and not some other times
    - so we would have to at the very least lowercase it and then factorize it
  - all `<chr>`
- updates on requested data: still nothing from northwestern :( or the murals place :( -- that is why I've been exploring osm and UNC
- ideas for exploring **historic districts** dataset:
  - `area of significance` variable -- maybe do some text analysis to see what is most common with these~
    - i wonder if this could widen the df -- like it's a list of factors... idk
      - ex: `COMMERCE; EXPLORATION/SETTLEMENT; ARCHITECTURE; RELIGION`

#### Methods available in tidygeocoder::geocode() (via claude):
> osm (Nominatim) — Free, no API key. Rate-limited (~1 req/sec). Decent global coverage, less accurate for messy/partial addresses. Good for small batches.
> 
> census — Free, no API key, US addresses only. Fast, supports batch geocoding natively (very efficient for large US datasets). Good accuracy for US.
> 
> arcgis — Free tier without key (with usage limits), better with an API key. Good global coverage and decent accuracy, handles messy addresses reasonably well.
> 
> google — Requires API key (billing enabled). Best accuracy and address parsing, especially for ambiguous/international addresses. Costs money beyond free monthly credit.
> 
> here — Requires API key (free tier available). Good accuracy, decent global coverage.
> 
> tomtom, mapbox, bing, opencage, geocodio — All require API keys; vary in pricing and regional strengths (geocodio is US/Canada only but very accurate for those).
> 
> Quick recommendations: 1) US addresses, large dataset → census 2) No API key, quick test → osm 3) Best accuracy, willing to pay → google 4) International, free tier → arcgis or here

## Links
- https://streetart.community/
- https://andrewpwheeler.com/2016/03/17/some-gis-data-scraping-adventures-banksy-graffiti-and-gang-locations-in-nyc/

## Meeting
- think of why you're interested!
- CHECK README!!
- check bridges to see if it's mapping stuff and NAs osmdata
- FRED
- LocalView

- Questions:
  - is there a stylebook (for the code) -- like are we supposed to have dataframes labelled a certain way, columns/variables, etc.?
  - How to convert from a street and number (address) to long and lat?
    - for historic landmarks data!
    - Personal research answers:
      - `tidygeocoder` package!!! (https://jessecambon.github.io/tidygeocoder/)
      - nominatim OSM api -- might be kinda slow, though, since it is only 1 per sec
      - other option: ggmap (google map) api

## June 12
Categories: Libraries, Historic Districts, News Outlets, Murals

### Todo
- [ ] come up with goals/questions fo rinstitutions

### Completed
- [x] emailed germuska for news outlets data
- [x] submitted form to https://usnewsdeserts.cislm.org/request-access
  - GOT THE DATA!
  - [x] check unc journalism terms of service - Yes, I think it does!
- [x] uploaded all of the library csvs from 2012-2023
- [x] came up with potential question w/ ian for libraries: how has the landscape changed over the past years?
- [x] fix the pull request thing
- [x] email germuska about northwestern data
- [x] made osmdata and osmextract maps -- differences... **want to talk about this at next meeting**
- [x] explored osm
- [x] filter/do regex for the historic places
- [x] met with groups - sort of (chatted)


### Personal notes
- state libraries agencies survey versus public libraries survey?
  - https://www.imls.gov/research-evaluation/surveys/public-libraries-survey-pls
  - 2019 and earlier there is a third file, a state csv... i did not upload this but maybe look into it?
- .ds_store mac issue killing me brah
- **historic landmarks does NOT have long and lat!!!**
  - need to add this somehow...
  - contacted rimona about this
- https://www.census.gov/programs-surveys/geography/guidance/geo-areas/urban-rural.html
- for libraries can try to connect it to census or https://usa.ipums.org/usa/

_journalism_
- for UNC: need to _acknowledge the UNC Hussman School of Journalism and Media in any works using this dataset._
- I think it does fulfill the requriements https://creativecommons.org/licenses/by-nc-sa/3.0/
- years: 2004, 2014, 2016, 2018, 2020 https://usnewsdeserts.cislm.org/

_osm_
osmdata vs osmextract via claude
- osmdata
  - Queries the live Overpass API on demand
  - Good for specific features in a specific area (e.g. all murals in Minnesota)
  - Returns results immediately, no local files
  - Struggles with large areas — times out easily
  - Data is always up to date
- osmextract
  - Downloads pre-built extracts from Geofabrik or other providers
  - Good for bulk data over large areas (whole countries, states)
  - Downloads a large .pbf file locally first, then reads from it
  - Much faster and more reliable for big queries
  - Data is slightly out of date (extracts update daily/weekly)
- osmdata:
  - lots of stuff is NA...even for many the artwork_type (which should be mural??? but is 56% NA???)
    - <img width="1292" height="736" alt="image" src="https://github.com/user-attachments/assets/9a5434e6-7487-4c0e-8a03-e5f25252b331" />
    - <img width="854" height="490" alt="image" src="https://github.com/user-attachments/assets/5d0bee2a-0029-450c-8cd8-0b26b5beda3e" />
    - but it IS making the map (though I'm not sure how to check that it's correct)
- osmextract:
  - much faster than osmdata but didn't plot as many points???
  - but also far far fewer NAs...
  - I tried pulling not just the points layer but also the lines and polygons layer, as well as doing a different sql query, and none of that really worked -- the most I could get was 600 with the extra lines and polygons layers
  - <img width="523" height="324" alt="image" src="https://github.com/user-attachments/assets/e6e7ceb1-bf0b-4d9a-8aef-0ad74a433ebe" />



### Meeting notes
- delete pull stuff
- ipsum usa - https://usa.ipums.org/usa/
- can ask her for a more powerful computer
- urban/rural census info

## June 11
### Todo
- [x] email northwestern
- [x] email streetartcities
- [x] get pls 2022
- [ ] understand how to get osm data???
- [x] get national register of historic places data

https://www.geonames.org/

### Categories
#### OpenStreetMap info
- overpass api -- readonly (this is what i would want)
  - https://wiki.openstreetmap.org/wiki/Overpass_API
  - _An excellent place to explore overpass queries specifically and OSM data in general is the online interactive query builder at overpass-turbo, which includes a helpful corrector function for incorrectly formatted queries._
  - https://cran.r-project.org/web/packages/osmdata/vignettes/osmdata.html#1_Introduction
  - 
- https://learnosm.org/en/osm-data/getting-data/
- OR: as an osm.pbf file (?) https://download.geofabrik.de/north-america.html
- 

#### Historic districts
- added to folder!!! as spreadsheet from https://www.nps.gov/subjects/nationalregister/data-downloads.htm

#### Libraries
- FY 2022 PLS data: https://catalog.data.gov/dataset/public-library-survey-pls-2022?from_hint=eyJxIjoiUHVibGljIExpYnJhcnkgU3VydmV5IChQTFMpIn0%3D
  - In data > libraries folder as csvs! (i think? -- was having some weird troubles with the branch thing)
  - Documentation and User Guide in the link above (this includes what the variables are)
  - _"The Public Libraries Survey (PLS) is a voluntary census of public libraries conducted annually by the Institute of Museum and Library Services (IMLS)."_
  - Includes longitude and latitude!
  - There are actually 2 csvs: 1) the System Data File (Administrative Entity) -- one record is one library system, 2) the Outlet Data File -- one record is one specific service point. Both have long and lat but I think we would probably want to go with 2.
- Can request data fron the career site via https://www.careeronestop.org/Developers/WebAPI/registration.aspx
  - not so sure about the terms of service aligning with this project, though -- _"No Modification of Data. COS data will not be modified or altered in any manner;"_
  
#### News outlets
- https://localnewsinitiative.northwestern.edu/projects/state-of-local-news/2025/
  - they have a pdf of the 2025 report which includes their methodology -- descriptions of each of the types of outlets
  - _"Our research is concerned with identifying local newspapers that provide public-service journalism."_
  - **Joe Germuska** -- email him later this week if still no response on data
    - https://github.com/joegermuska/
    - joegermuska@northwestern.edu
    - joe@germuska.com
  - https://northwestern.az1.qualtrics.com/jfe/form/SV_erjjVa4drHs9hnE -- submitted through here
  - Not sure if they'll let us use the data since they're saying it's private data and shouldn't be shared with others i think...
- github csv: https://github.com/sTechLab/local-news-dataset -- no long and lat data
- 

#### Murals
- support@streetartcities.com -- emailed
- sam@streetartmankind.org -- emailed
- 

### Meeting notes
- it's ok if it's not a comprehensive dataset!!!
- just try to get as much of the data

## June 10
### Sources
#### Questions
- for news outlets -- what would/wouldn't we include? newspapers? radio? tv? local news? national newspapers?
- not really sure how to decide what to choose...
- ordered below by likely ease (1 and 2 pretty straightforward, 3 and 4 less so)
- reaching out?

#### Historic districts
1) National Register of Historic Places . Digital Archive on NPGallery
  - _allow use?_ Yes
  - https://www.nps.gov/subjects/nationalregister/data-downloads.htm
    - With some text analysis I think this may have all we need
  - https://www.nps.gov/subjects/nationalregister/database-research.htm
  - https://www.nps.gov/subjects/nationalregister/index.htm
  - Can be downloaded as a spreadsheet but they offer free api: https://www.nps.gov/subjects/developer/api-documentation.htm

Could also look into Historical parks using this data

#### Public libraries
1) CareerOneStop library finder
   - _allow use?_ Y i think so -- api
   - https://www.careeronestop.org/LocalHelp/CommunityServices/find-libraries.aspx
   - it says that _"This information is compiled and maintained by the Institute of Museum and Library Services and CareerOneStop."_ ?
   - web api!
2) IMLS
   - https://www.imls.gov/research-evaluation/data -- not exactly sure how this would work -- github?
   - Public Library Survey (PLS) Published by Institute of Museum and Library Services 
       - **Public Library Survey (PLS) 2022**: https://catalog.data.gov/dataset/public-library-survey-pls-2022?from_hint=eyJxIjoiUHVibGljIExpYnJhcnkgU3VydmV5IChQTFMpIn0%3D
       - CSV!!! ^ 2022 was the most recent one i could find

#### News outlets
1)Northwestern
   - _Allow use?_ unsure - should probably contact: stateoflocalnews@northwestern.edu.
       - no API/csv -- probably would have to scrape https://localnewsinitiative.northwestern.edu/projects/state-of-local-news/explore/#/localnewslandscape
   - _"data on close to 6,000 local newspapers, 1,100 public broadcasting outlets, 1,000 ethnic media outlets and more than 12,000 standalone and network digital sites"_
   - probably the most reputable and current!
2) UNC
  - _Allow use?_ With permission by asking
  - https://usnewsdeserts.cislm.org/
3) Github repo - _Local News Social Media Dataset_
  - https://github.com/sTechLab/local-news-dataset
  - From a 2022 study on news outlets during covid-19: https://ojs.aaai.org/index.php/ICWSM/article/view/19315
  - _"This github contains the largest dataset of local news outlets in the U.S. and their social media handles. This dataset includes a total of 10,257 news outlets. We map 7,859 of them to a location and county, 9,231 to a Facebook account and 5,645 to a Twitter account."_
4) For radio and tv service: gov
  - https://www.fcc.gov/media/media-bureau-public-databases
5) wikipedia
  - https://en.wikipedia.org/wiki/List_of_newspapers_in_the_United_States

#### Murals/street art
1) Street Art Cities
  - _Allow use?_ Y
  - https://streetartcities.com/open-data
  - This site has datasets by country, but it's only the 50 most recent ones so it does not include the US. **Might need to contact them.**
  - Crowdsourced by the public and quite extensive. This might mean that it would require some more cleaning, though, since the content of the variables are not always consistent.
  - Contains longitude and latitude, as well as lots of other variables such as description.
2) OpenStreetMap
  - _Allow use?_ Y
  - Crowdsourced
  - Overpass API
  - Tag: artwork_type=mural
3) Public art archive
  - _Allow use?_ Unsure but i think yes https://explore.publicartarchive.org/terms-of-use/
  - Also crowdsourced
  - May be super usefull
  - Generally about public art but can filter by various categories (ex: murals)
  - Would have to scrape (no api or public dataset)
  - <img width="1265" height="439" alt="image" src="https://github.com/user-attachments/assets/9459108b-97b9-4b42-8635-e91b9e4c11a4" />
4) Street art for mankind
  - _Allow use?_ Unsure
  - Nonprofit that sponsors/maps murals to _"raise awareness on social justice and environmental issues, and to give the public the means to become actors of change"_
  - Can't really find the data on the website, but they have an app >>>
  - Behind the Wall app -- should contain geospatial data
  - sam@streetartmankind.org
  - ^ Probably should email them because I can't find github or api
  - One important con of this: it's specifcally focused on art that it has sponsored/focused on social justice etc.
5) Data.gov
  - https://catalog.data.gov/?sort=relevance&q=&sort=relevance&spatial_filter=&keyword=public+art
  - More limited -- by city and not all cities
6) CodaWorx
  - _Allow use?_ Unsure, probably not
  - https://codaworx.com/
  - More of a for-profit I think since its purpose is to connect artists with people who want art
  - But it does seem to have a databse of artworks?
  - https://knowledge.codaworx.com/codazine/the-power-of-data-proving-that-public-art-can-change-the-world

### Meeting notes
- corporate museums -- would just broadly look at museums
  - openstreetmap
- high school mascots???
- news outlets -- **ben toff umn**
  - informal institution
  - scrape news articles themselves from local newspapers?
- make sure to look at terms of service before scraping!
- csvs ok
- goal for end of week: what we're each doing and where we're collecting from

## June 09
Ideas for cultural institutions to investigate:
- <mark>historic districts</mark>
  - https://www.nps.gov/subjects/nationalregister/database-research.htm
      - api info below in parks
      - But it can also be downloaded as a spreadsheet (?) https://www.nps.gov/subjects/nationalregister/data-downloads.htm
- <mark>public libraries</mark>
  - https://www.careeronestop.org/LocalHelp/CommunityServices/find-libraries.aspx
  - API exists for careeronestop.org ^
  - https://www.imls.gov/research-evaluation/data -- not exactly sure how this would work -- github?
- <mark>parks</mark>
  - https://www.tpl.org/park-data-downloads
  - OpenStreetMap
  - Historical parks
      - https://www.nps.gov/findapark/index.htm
      - ^ They offer free api: https://www.nps.gov/subjects/developer/api-documentation.htm
- <mark>murals/street art</mark>
  - There are lots of local mural registries...
      - https://data.jerseycitynj.gov/explore/dataset/jersey-city-mural-map-list/table/?disjunctive.ward&disjunctive.name&disjunctive.artist
      - https://data.cityofchicago.org/Historic-Preservation/Mural-Registry/we8h-apcf/about_data
  - OpenStreetMap
  - https://streetartcities.com/open-data --> open data as a csv for academic use
  - Street art for man kind: https://streetartmankind.org/
      - there is an app that would probably be the best thing to scrape
      - But there is also this page that scraping may (?) work on? https://streetartmankind.org/murals-and-events/
          - class="col-sm-4 product-list-container article_enable_for_now"
- https://data.gis.ny.gov/datasets/nysparks::national-register-building-listings/about
- YMCAs
- journalism
- religious institutions
- ~satellite data ?~
- ~malls~
- amusement parks
- museums
  - corporate museums -- cool!
  - science museums
  - children's museums

Notes from readings:
- Corporate museums = _"thematic, commercial buildings, owned by a particular firm, where the history of the company brand and products development is presented," "social but branded space"_
  - Ex: Porsche, Mercedes, BMW Welt
  - Expands tourist and cultural potential -- marketing image. Financial gains for corporation.
  - Architecture identifies with brand
  - Usually next to factories for the corporation
  - _"It is suggested that further research should be undertaken within corporate museums to answer the question fo how traditional museums would learn from the corporate kind."_
- National monument audit is good inspo
- open street map -- super duper cool
  - free data - https://wiki.openstreetmap.org/wiki/API
- satllite images: _"This study investigates the effectiveness of state-of-the-art deep learning models trained on high-resolution single-band satellite images in estimating site-level industrial development over time in the People's Republic of China."_
  - industrial sites = factories, power plants, ports
  - _"This approach enables users to identify regions where rapid industrialization (or de-industrialization) may be occurring for more detailed, qualitative analyses."_
  - conclusion... insufficient methods? except for footprint?
  - Please reach out via the LinkedIn profile link in the author section if you would like to experiment with the project code.
