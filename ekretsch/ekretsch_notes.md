# Emily Kretschmer's Notes

## June 17
- [ ] check readme
- libraries
  - [ ] respond to ian
- historic districts
  - [ ] map
- murals
  - [ ] continue text analysis

## June 16
- [ ] check back in w/ Emily about osmdata package -- wait won't need this for murals but yes for newspapers potentially?
- [ ] merge to add long and lat data for historic districts
  - [ ] message rimona abt this
- [ ] map journalism data
- [x] import mural data
- [ ] message rimona about geocoder thing?
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
