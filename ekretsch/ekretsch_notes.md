# Emily Kretschmer's Notes

## June 10
### Personal notes
#### Historic districts

#### Public libraries
1) 

#### News outlets

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
- news outlets -- ben toff umn
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
