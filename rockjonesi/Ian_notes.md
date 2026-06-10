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
Powerplants:
  - https://gis-fema.hub.arcgis.com/datasets/b063316fac7345dba4bae96eaa813b2f/about

#### Libraries
- https://librarytechnology.org/libraries/uspublic/
  - Super comprehensive website conatining name/addresses of all (~16,000) public libraries in the US
  - Terms of Service could cause useage conflicts --> "Extracting data through automated scripts is prohibited.
    Those interested in access to the underlying data sets can contact Marshall Breeding to discuss available options.
    Library Technology Guides encourages use of the site for personal and academic research."
    - Checked in with Emily about contacting them, so we'll see what happens.

#### Sport Venues
https://stadiumandarenavisits.com/map/
  - https://mapular.com/tools/google-my-maps-converter 
     - easy KML -> CSV converter for lat/long information
     - just contains locatoion and venue name (What else should we look for? Descriptions for sport type/team history?)
     - contains some canadian venues --> would just have to filter to between a certain long/lat to cut those out, but keep Alaskan venues
  - https://stadiumandarenavisits.com/the-list/
    - List of the venues and their size (capacity) from the same project
      - This is a pdf so data extraction would have to be more text-analysis focused.
  - very comprehensive hobby project; manager asks: "if you use the List or any pictures on the website, please just ask permission. Thank you!"
    - by "the List" he means the information on the PDF. Should I contact?
        

#### concert/symphony halls
- https://en.concerts-metal.com/places_us.html
  - contains data on ~800 music venues in the US. Mainly only those which host Metal/Hardrock/Punk bands.
    Also, venue size ranges from large concert halls to small breweries/ bars that could have more isolated, local, impacts.
    - Looks like it might be challanging to efficiently scrape all helpful information, appears to have api.
- https://www.operabase.com/organisations/venue/united-states/en?page=1
  - large comprehensive database containing information on concert venues in the US, no genre focus like above
  - has API, also looks like scraping would not be challenging since it's just a multi-page list
  - For location information: only contains city address, nothing more specific. Additionally, no lat/long information. Would likely have to pull
    that info from supplemental location dataset.
- https://commons.wikimedia.org/wiki/Category:Concert_halls_in_the_United_States
  - another potential data source. It is much smaller though and might contain redundant info thats already in operabase
 
  - 
      
      










    

