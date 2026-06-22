# Rimona Zhang's Notes
## 6/9/2026

Searching for cultural institutions, i.e. locations that reflect something about a community's history, culture, or values,

Potential Areas of Focus:
- Monuments
- Museums
- Statues
- Businesses
- Satellite


Interests:
- Monuments
  - The Historical Marker Database: https://www.hmdb.org/
  - National Register of Historic Places: https://www.nps.gov/subjects/nationalregister/database-research.htm

- Theatres 
  - performing arts centers, opera houses, historical theatres
  - Historic Theatre Inventory: https://www.lhat.org/program-services/theatre-inventory
  - League of Resident Theatres: https://lort.org/theatres

- Colleges 
  - could narrow, e.g. LACs and HBCUs
    - https://www.usnews.com/best-colleges/rankings/national-liberal-arts-colleges?_sort=rank&_sortDirection=asc
    - https://www.thehundred-seven.org/hbculist.html

Helpful Data Sources:
- Open Street Map:
  - https://www.openstreetmap.org/#map=5/39.16/-95.27
- Geonames (geographical database):
  - https://www.geonames.org/

## 6/10

Topics of Focus:
- Historical theatres (e.g. performing arts centers, opera houses, etc.)
- Colleges (LACs, HBCUs)
- Automotive assembly plants

### Theatres
League of Resident Theatres:
- https://www.lhat.org/program-services/theatre-inventory
  - Allows for web scraping, but could not find their terms of service
  - Able to download a PDF list of all Member Theatres
    - Only accounts for theatres in the US that are members of this org
   
- https://en.wikipedia.org/wiki/Category:Theatres_on_the_National_Register_of_Historic_Places_by_state  
  - Has subcategories (links) of theatres by state
    - Could be difficult to read data from every link 

### Colleges
LACs
- https://www.usnews.com/best-colleges/rankings/national-liberal-arts-colleges?_sort=rank&_sortDirection=asc
  - Permits scraping
  - Unsure about terms of service

HBCUs
- https://www.thehundred-seven.org/hbculist.html
  - Terms of Use allows for the use any information on The Hundred-Seven’s services, provided certain conditions
  - https://www.thehundred-seven.org/terms.pdf

### Automotive Assembly Plants
- https://en.wikipedia.org/wiki/List_of_automotive_assembly_plants_in_the_United_States
  - Wikipedia has public API and allows for scraping
- Had challenges with finding data from more official websites
  - Maybe try looking at oil refineries instead if there is more available dataz
 
## 6/11
### Theatres
League of Resident Theatres: https://www.lhat.org/program-services/theatre-inventory
- Allows for web scraping, but could not find their terms of service
- Able to download a PDF list of all Member Theatres
    - Only accounts for theatres in the US that are members of this org

National Register of Historic Places (NRHP):
- Spreadsheet available of all NRHP listed properties
  - 100,867 rows, 24 columns -- super large dataset

Wikipedia: https://en.wikipedia.org/wiki/Category:Theatres_on_the_National_Register_of_Historic_Places_by_state  
  - Has subcategories (links) of theatres by state
    - Could be difficult to read data from every link 

### Colleges
Coordinates of all colleges: https://catalog.data.gov/dataset/postsecondary-school-locations-2023-24
- Publicly available data -- Terms of Use: https://data.gov/user-guide/

LACs
- US News: https://www.usnews.com/best-colleges/rankings/national-liberal-arts-colleges?_sort=rank&_sortDirection=asc
  - HTML is not really clear
  - Seems challenging to scrape information from website
- CSV of LAC Rankings from US News: https://www.andyreiter.com/datasets/
  - Same information needed from US News site, but in cleaner format
  - Can join with the coordinate dataset

HBCUs
Accredited HBCU List: https://sites.ed.gov/whhbcu/one-hundred-and-five-historically-black-colleges-and-universities/
- From website: the Higher Education Act of 1965, as amended, defines an HBCU as: “…any historically black college or university that was established prior to 1964, whose principal mission was, and is, the education of black Americans, and that is accredited by a nationally recognized accrediting agency or association determined by the Secretary [of Education] to be a reliable authority as to the quality of training offered or is, according to such an agency or association, making reasonable progress toward accreditation.”
- Data from Institute of Education Sciences
- Terms of Use: https://nces.ed.gov/about/public-access-research

### Automotive Assembly Plants
All assembly plants: https://en.wikipedia.org/wiki/List_of_automotive_assembly_plants_in_the_United_States
- Able to be scraped
- Wikipedia has public API and allows for scraping

EV Manufacturing Facilities and Investment Overview: https://evjobs.bgafoundation.org/
- Data accessible as CSV file; 891 rows, 18 columns
- Terms of use: https://www.bluegreenalliance.org/terms/
  - Seems that data available to be downloaded does not have restricted use
 
### Oil Refineries
Active Fuel Refineries: https://www.irs.gov/businesses/small-businesses-self-employed/refinery-control-number-rcn-refinery-location-directory
- On IRS site: "A refinery is a facility used to produce taxable fuel from crude oil, unfinished oils, natural gas liquids, or other hydrocarbons and from which taxable fuel may be removed by pipeline, by vessel, or at a rack"
- Data is accessible as CSV file; 229 rows, 6 columns
- Does not seem to have any restrictions and is available to public

## 6/12
To do:
- [X] Email Andrew G. Reiter for permission to use LACs dataset
- [ ] Start cleaning data

### Automotive Assembly Plants
All assembly plants: https://en.wikipedia.org/wiki/List_of_automotive_assembly_plants_in_the_United_States
- Able to be scraped
- Wikipedia has public API and allows for scraping

EV Manufacturing Facilities and Investment Overview: https://evjobs.bgafoundation.org/
- Data accessible as CSV file; 891 rows, 18 columns
- Terms of use: https://www.bluegreenalliance.org/terms/
  - Seems that data available to be downloaded does not have restricted use

Could be interesting to compare EV Locations with the rest of automotive facilities, or just look at locations of EV manufacturers

### Meeting with Ian and Zoe
Topics of Discussion 
- Ideas on how to pair satellite data with work of other groups
- Methods for joining long and lat coordinates with addresses in datasets
- Splitting up work: I will focus on automotive manufacturers (wikipedia, EV, and oil refineries datasets)

## 6/15
- Update: Professor Reiter responded, his datasets are publicly available and asks to just cite when using them (citation details should be at the top in the excels).

### Plan: 
Finish collecting datasets:

### Theatres
- begin scraping websites (League of Resident Theatres, wikipedia)
- start filtering NRHP csv for theatres, opera houses, performing arts centers
- find a source to join/use to access long and lat info for each location

### Colleges
- scrape HBCU data from website
- join LACs csv with dataset of long and lat for all schools
- also find data from census(?) to possibly look into demographics 

### Why interested?
- colleges contribute largely to the communities near them, supporting and offering cultural resources while also preserving the history of the community (NF as example compared to other rural MN towns nearby).

## 6/16
- continue with scraping, cleaning, joining datasets!

Plans for EDA:
- Data summary tables
- Basic charts

## 6/17
- account for long/lat coordinates for locations across datasets
- citation for Reiter dataset: Andrew G. Reiter, “U.S. News & World Report Historical Liberal Arts College and University Rankings,” available at: http://andyreiter.com/datasets/

## 6/18
- [X] scraped schools from HBCU website
- [ ] join long and lat coordinates for both college datasets
- [ ] finish filtering through NRHP csv

## 6/20
- [X] scraped schools from HBCU website
- [X] join long and lat coordinates for both college datasets
- [X] finish filtering through NRHP csv for various theaters

- [ ] add long and lat coordinates to NRHP dataset
- [ ] gather data from Opera America website
- [ ] explore visualizations using datasets
- [ ] conduct basic EDA across the data

## 6/21
- [X] add long and lat coordinates to NRHP dataset
  - used tidygeocoder package to find lat and long coordinates
- [X] gather data from Opera America website
- [ ] explore visualizations using datasets
- [ ] conduct basic EDA across the data

## 6/22
Went a bit off track from the goals I wrote yesterday and instead cleaned the automotive datasets, which included scraping the Wikipedia website and geocoding coordinates for both datasets.

Thus,
- [ ] explore visualizations using datasets
- [ ] conduct basic EDA across the data
are still goals to complete by Wednesday.

Also, creating questions to guide what the data should show. For example, do regions that have more historic locations (e.g., theaters), differ from regions that have industrial institutions (e.g., automotive manufacturing facilities)? 

