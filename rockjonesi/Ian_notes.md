# Ian Rock-Jones Research Journal
## June 9
### Finding Institutions

"Cultural instition" being such a broad term --> countless number of different approaches for choosing 
what types of structures might fall under that category, even if our lens is centered on 
political economy.

Collecting data on industrial businesses (factories/powerplants/corporations) sounds interesting
- potential data sources:
  - https://gis-fema.hub.arcgis.com/datasets/b063316fac7345dba4bae96eaa813b2f/about
  - 

Additionally, I was curious about exploring more about the following types of institutions:
- libraries
  - https://librarytechnology.org/libraries/uspublic/
      - scraping by state for data extraction
- perforance centers (e.g. concert/symphony halls, or sport ML/college sport venues/arenas/stadiums)
  - https://stadiumandarenavisits.com/map/
     -  availible KML of ~1300 US sport venues --> can convert to raw location info

## June 10
### Data search

#### Industrial Insitiutions
**Powerplants**:
  - https://gis-fema.hub.arcgis.com/datasets/b063316fac7345dba4bae96eaa813b2f/about
    - very comprhensive dataset of powerplants in the US. Downloadable in many forms, including as csv.
    - Open source
  
**Corporatations**:
  - https://padlet.com/gallery/a-map-of-fortune-500-headquarters-357ned1s9wig
    - headquarter locations for US Fortune 500 companies
    - downloadable as csv
  - https://docs.overturemaps.org/guides/places/
    - database that NYT article used to map out specific businesses
    - not sure the scope of business mapping we want; every instance of select businesses? I feel like mapping the headquarters
      might capture the relationships we are hoping for --> question for tmr
    - would need to use queries to extract the data, I think would be not too bad to figure out
      

#### Libraries
- https://librarytechnology.org/libraries/uspublic/
  - Super comprehensive website conatining name/addresses of all (~16,000) public libraries in the US
  - Terms of Service could cause useage conflicts --> "Extracting data through automated scripts is prohibited.
    Those interested in access to the underlying data sets can contact Marshall Breeding to discuss available options.
    Library Technology Guides encourages use of the site for personal and academic research."
    - Checked in with Emily about contacting them, so we'll see what happens. --> contacted Marshall Breeding, waiting for response.
      - Sounds willing to have us work with their data --> 
       - "Ian,
        Thanks very much for your interest in the data on Library Technology Guides.
        I’m interested in helping with your project.
        There is a mechanism for projects such as yours to be able to download selected data from the website.  Can you tell me more about the project and how the data will be incorporated?
        Kind regards,
        
        marshall"

        Was reponse 6/11. Emily's PLS data seems like it could be better, so now unsure if we even need this.
      
#### Sport Venues
https://stadiumandarenavisits.com/map/
  - https://mapular.com/tools/google-my-maps-converter 
     - easy KML -> CSV converter for lat/long information
     - just contains locatoion and venue name (What else should we look for? Descriptions for sport type/team history?)
     - contains some canadian venues --> would just have to filter to between a certain long/lat to cut those out, but keep Alaskan venues
  - https://stadiumandarenavisits.com/wp-content/uploads/2026/04/stadiums.pdf
    - List of the venues and their size (capacity) from the same project
      - This is a pdf so data extraction would have to be more text-analysis focused.
  - very comprehensive hobby project; manager asks: "if you use the List or any pictures on the website, please just ask permission. Thank you!"
    - by "the List" he means the information on the PDF. Should I contact?
        

#### concert/symphony halls
- https://en.concerts-metal.com/places_us.html
  - contains data on ~800 music venues in the US. Mainly only those which host Metal/Hardrock/Punk bands.
    Also, venue size ranges from large concert halls to small breweries/ bars that could have more isolated, local, impacts.
    - Looks like it might be challanging to efficiently scrape all helpful information, no api. Address data is all isolated behind links on each venue.
- https://www.operabase.com/organisations/venue/united-states/en?page=1
  - large comprehensive database containing information on concert venues in the US, no genre focus like above
  - has API, also looks like scraping would not be challenging since it's just a multi-page list
  - For location information: only contains city address, nothing more specific. Additionally, no lat/long information. Would likely have to pull
    that info from supplemental location dataset.
- https://commons.wikimedia.org/wiki/Category:Concert_halls_in_the_United_States
  - another potential data source. It is much smaller though and might contain redundant info thats already in operabase
 


  ### My desired areas of focus:
   #### sports venues
   #### libraries
   #### powerplants/corportate businesses



## June 11

#### Continuing the search of industrial/coperate institutions:

Auto industry/car assembly plants in the US:
  - https://en.wikipedia.org/wiki/List_of_automotive_assembly_plants_in_the_United_States

Map data of auto supply chain plants in the US:
  - https://www.bluegreenalliance.org/resources/bluegreen-alliance-unveils-latest-auto-industry-map-for-domestic-manufacturing-advocates/
  - Terms of use allow data downloads from website, but need to grant permission before using for published/public work
    - Would provide csv download if we are given permission
    - will get in contact with them today to ask

This might be getting way into the weeds of industrial institutions, but here is a dataset containing location information on mines in the US:
  - https://mmr.osmre.gov/
  - Also would be a csv download

### Data progress
- Have started to download/upload the accessible csvs into their respective data folders
  - data -> sports -> sportsvenues.csv
  - data -> industrial institutions -> fortune500.csv, powerplants.csv
    - autosupplyplants.csv will also go in here if granted data permissions
  - data -> libraries -> looks like Emily already put PLS, might be all we need.

 - **things that need to be scraped**
   - https://librarytechnology.org/libraries/uspublic/
     - although not sure we need this anymore with Emily's PLS data
     - https://en.wikipedia.org/wiki/List_of_automotive_assembly_plants_in_the_United_States
  - **things that need text analysis**
    - https://stadiumandarenavisits.com/wp-content/uploads/2026/04/stadiums.pdf
      - only if we are interested in stadium size


## June 12

- [ ] Find consensus data to supplement library data
  - population density
  - metropolitan/rural scales
    - usda rural continuity codes
 - if there are museums/other public knowledge resources around? (not sure how we'd go about this)
 - ipums usa is a potential resource https://usa.ipums.org/usa/

    - Emily and I checked in:
      - we realized the pls data already provides county-level population data, as well as information reflecting ubran/metro scale information.
         - would maybe have to text scrape some of the scale information since it's collect on a Likert scale.
      - good! bc less work --> however we want to do more --> we have decided to pivot and do a multi-year study, ranging from 2013-2023.
        - Emily will upload each years csv pls data into data --> libraries folder
        - I will check each years documentation to ensure consitencies in what the data is representing

          - 2022
          - https://www.imls.gov/sites/default/files/2024-06/2022_pls_data_file_documentation.pdf

- [ ] meet with all of groups
- [ ] email marshall breeding
















    

