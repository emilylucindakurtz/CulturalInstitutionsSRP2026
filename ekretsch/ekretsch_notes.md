# Emily Kretschmer's Notes

## June 10
### Sources
#### Questions
- for news outlets -- what would/wouldn't we include? newspapers? radio? tv? local news? national newspapers?
- not really sure how to decide what to choose...
- ordered below by likely ease (1 and 2 pretty straightforward, 3 and 4 less so)

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
