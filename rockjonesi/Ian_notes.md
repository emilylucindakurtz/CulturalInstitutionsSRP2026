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

- [x] Find consensus data to supplement library data
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
      
user guide documentation/code book for each years data:

    2023
   https://www.imls.gov/sites/default/files/2025-08/PLS-FY-2023-Data-Documentation-508.pdf 
   
    2022
   https://www.imls.gov/sites/default/files/2024-06/2022_pls_data_file_documentation.pdf
   
    2021
   https://www.imls.gov/sites/default/files/2023-06/2021_pls_data_file_documentation.pdf
   
    2020
   https://www.imls.gov/sites/default/files/2022-07/2020_pls_data_file_documentation.pdf
   
    2019
   https://www.imls.gov/sites/default/files/2021-05/2019_pls_data_file_documentation.pdf
   
    2018
   https://www.imls.gov/sites/default/files/2018_pls_data_file_documentation.pdf
   
    2017
   https://www.imls.gov/sites/default/files/fy2017_pls_data_file_documentation.pdf
   
    2016
   https://www.imls.gov/sites/default/files/fy2016_pls_data_file_documentation.pdf
   
    2015
   https://www.imls.gov/sites/default/files/fy2015_pls_data_file_documentation.pdf
   
    2014
   https://www.imls.gov/sites/default/files/fy2014_pls_data_file_documentation.pdf
   
    2013
   https://www.imls.gov/sites/default/files/fy2013_pls_data_file_documentation.pdf

   All of them have consistency across the countypop, LOCALE, and lat/long varibles that we care about

- [x] meet with all of groups
  - for industrial group --> going to end up not using auto supply data, will focus on wiki car manufacturing plants, and EV plants.
    - Rimona will be focusing on these two while I do powerplants, and fortune 500 companies.
    
- [x] email marshall breeding


## June 15

meeting notes:
**Local View** data/wesbite. Related to industrial institutions, contains city council meeting data--can be used to examine how certain industries are being challenged. 

add mines to industries data. perhaps data mining centers too if you can find that information

Today, I largely worked on processing and cleaning up the Sports Venues data. This entailed conducting text-analysis on "stadiums.pdf"-which contained the list of stadiums and their capacity sizes (and is contained in the data --> Sports Venues)-and then joining this with the Sportsvenue.csv data to include location information. However, this became a lot more involved than I was expecting, there were a ton of naming-inconsistencies (largely created from typos, small punctuation issues, or some variation of abbrivation issue) that had to be fixed for the datasets to merge as properly as it could. Additionally, each dataset conatined many duplicate venue names, which could be uniquely identified within each dataset based on capacity, or long/lat depedning on which dataset one was looking at. There were no shared unique identifiers, meaning that these duplicates during the initial joining led to errors in the data. To fix this, I spent a large amount of time cross referencing locations and capacities to accuratley connect stadium capacities to the correct stadium name duplicate with the locations. This part was done mostly maunally, as I could not come up with another automated method that took less time. 

These challenges slowed my progress more than I hoped, and I did not get all that I wanted done today. Tomorrow, I am hoping to start visualizing some of this venue data as well as the industrial data. In the future, I will also start to clean and visulize the across-time library datasets.


## June 16

Thinking and contextualizing my data processing steps and choices:

I gave a little info based on my work on the 15th, but here I will go into more depth.

#### Foremost, industrial institutions:

initial steps --> restrict long/lat coordinated to only include the bounnds of the 50 states. 
 - powerplant data conatined plants in puerto rico, so those were the ones that were removed mainly.
plotting a simple map of the powerplant locations after filtering:

<img width="605" height="425" alt="image" src="https://github.com/user-attachments/assets/7abcf04d-2f37-486c-b2fe-610187593f79" />

There appear to be larger concetrations of powerplants along the east/west coasts, as well as a large cluster in the MN area.

Moving onto fortune500 data, I similarly restrained the location of interest and plotted a simple map:

<img width="400" height="236" alt="image" src="https://github.com/user-attachments/assets/f1d9a218-20df-4c1d-9c1c-9d70b255a085" />

I went further and made a simaple map containing information on both powerplants and fortune 500 companies:

<img width="400" height="236" alt="image" src="https://github.com/user-attachments/assets/31fc3c96-1963-487a-bf62-514ac72a80ff" />


I then used leaflet to create an interactive plot with both powerplants and fortune 500 companies in the USA. Marked locations are clustered to 
allow the map to render more smoothly. Red circles represent fortune 500 companies, while blue dots represent powerplants. A viewer can click on blue dots to see what the powerplant's primary energy source is, or click on a red dot to see what company it is representing.

<img width="1122" height="783" alt="image" src="https://github.com/user-attachments/assets/e29b0b3a-92d7-4dc9-93c8-393c09f6a55e" />

Above is just a screenshot of the western washington area.


#### sports venues

I continued to try and problem solve my issues with data merging for a large part of the day, but am still unsuccessful.
Here is where I am at: I have two datasets I am trying to merge information from:

head(venues)
                      Name Latitude  Longitude 
1         1st Summit Arena 40.32291  -78.92283 
2     3M Arena at Mariucci 44.97805  -93.22810 
3        Abbotsford Centre 49.03072 -122.28711 
4           Acrisure Arena 33.77845 -116.33906 
5 Addition Financial Arena 28.60739  -81.19742 
6   Adirondack Bank Center 43.10490  -75.23341 


head(name_capacity)
  Name                 capacity
  <chr>                <chr>   
1 Abbotsford Centre    7,073   
2 Ripken Stadium       5,800   
3 Wachs Arena          8,000   
4 Wildcat Stadium      12,000  
5 Crutcher Scott Field 4,000   
6 Moody Coliseum       3,600


name_capacity was extracted via text analysis from the pdf "stadiums.pdf" located in the
Sports Venues data folder. 

I have been trying to collapse naming inconsistencies, as well as manually assigning locations to the select duplicate stadiums.
However I am still ending up with my data like

<img width="358" height="141" alt="image" src="https://github.com/user-attachments/assets/0c709ba1-3bac-4a6e-a3ba-bb3b75a24ac4" />


even after attempting case_when manual fixes:

fixed_venue <- full_venue %>%
  mutate(capacity = case_when(
    Name == "Convocation Center" & round(Latitude, 2) == 33.57 ~ "3,600",
    Name == "Convocation Center" & round(Latitude, 2) == 39.32 ~ "13,080",
    Name == "Convocation Center" & round(Latitude, 2) == 29.58 ~ "4,080",
    Name == "Convocation Center" & round(Latitude, 2) == 37.02 ~ "7,200",
    ....

This still doesn't change the data at all. I tried various different fixed but am still unsuccessful. Am planning on checking in with Emily tomorrow.

Also checked in with other Emily about library data visions and ideas about processing and EDA.

Check list for tomorrow
- [ ] continue fixing the sports venue data
- [ ] create visual map with indicators of capacity for each venue
- [ ] start library data explorations


## June 17

Was able to fix sport venue data issues. Reasons for difficulty ended up being do to rounding and class discrepencies. 
I now have one dataset `fixed_venue` that contains locations for 1,333 different sport venues, and capacity data for around 1,200 of those venues. 

The exploratory plot I made marked sports venue locations in the united states, with markers corresponding to venue capacity. However, since there were so many overlapping points, it was still difficult to see where larger venues were. To deal with this, any venue with capacity over 20,000 was marked as blue. 

<img width="600" height="400" alt="image" src="https://github.com/user-attachments/assets/0d4a476c-a7a4-45b1-9774-2190863ae222" />

Larger capacity venues tend to be around areas with higher population density, which makes sense. My thoughts have now moved to what sort of impactful information could we pull from what communities surround these venues. What supplementary data would be relevant and interesting? 
Potential things to explore adding:
 - maybe county political affiliation
 - regional average income
 - some other sort of demographic relationship?


Moving on, I am continuing to try and finalize the powerplant and corporate datasets, by only including relevant columns. Also having some of the same thoughts about what might be helpful supplemental data so that people can actually learn about data trends.
(maybe what stats have the highest counts of certain types of powerplants.)

For the fotune 500 companies, there is already some city/state information, but it's formatting is very inconsistent across different corporations. So I am going to convert lat/long info into more consistent city/state info using tidygeocoder. `fortune500` now contains only the data of Company, city, state, count, lat, and long. Other supplemental data could look like trying to add sector type for each company (tech, commerce, banking, etc.). Based on my motivations for exploraing corporations in the first place, it would be cool if I could find some sort of information regarding employment numbers.


`powerplants` is be changed to contain only information on powerplant name, company name, state, city, type of energy (solar, hydroelectric, etc.), lat, long.

For next time:
- [ ] get to library exploration.
- [ ] upload new csvs to data file






    

