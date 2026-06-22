# Emily's Notes for Historic Districts Dataset + Analysis

# Personal notes/things to do/ideas for further analysis:
- `#\| eval: false`
- [ ] shiny app where you can select the state and then a histogram/bar chart pops up for the cateories
- [ ] do the proportional/standardization thing
  - [ ] get data by state for area
- [ ] Data cleaning:
  - [ ] `category of property` variable -- district for most, but site for some... but it is all caps sometimes and not some other times ex: `Fort Union Trading Post National Historic Site Historic District (Boundary Increase)` -- marked as `site` and it's not really a historic district in the way I was thinking...
  - [ ] Deal with the geocoding properly
     
Notes:

- 52 in land_area, 57 in by_state. The below are in the by_state (the NHRP dataset) but not the land_area
  - Federated States of Micronesia are in the dataset but are technically a sovereign nation though in a Compact of Free Association (COFA) with the United States.
  - American Samoa -- US territory
  - Guam -- US territory
  - N. Mariana Islands -- US territory
  - Virgin Islands -- US territory
 
5 US territories: Puerto Rico, American Samoa, Guam, the Commonwealth of the Northern Mariana Islands (CNMI), and the U.S. Virgin Islands.
------------
I got the land area dataset from: https://www.census.gov/geographies/reference-files/time-series/geo/gazetteer-files.html
^ I selected the state file (towards the bottom)
------------
https://www.census.gov/geographies/reference-files/2010/geo/state-area.html
^ from 2010 but better since it has the territories too
scraping (I checked `paths_allowed("https://www.census.gov/")` -- It came back `True` so we can scrape :))
# Dataset source:
National Register of Historic Places

https://www.nps.gov/subjects/nationalregister/data-downloads.htm

Scroll down to `Spreadsheet of NRHP Listed properties (listings up to 5/22/2026)` and download the .xlsx file.


# Cleaning/wrangling:
1. The original spreadsheet is in the folder `folder name` as `file name`
2. I converted the raw spreadsheet to a CSV by opening the .xlsx file, then going to `File` > `Export To` > `CSV...`
  - This is saved as `file name`
3. Import the .csv into R (I completed all steps 2-??? of the cleaning/wrangling in `historic_districts_exploration1.qmd`
4. Create `historic_districts` -- just the rows from the landmarks dataset that are historic districts.
  - I did some cleaning here to ensure the variables were the correct types and removed unnecessary columns. **maybe come back to this later**
  - Also added some columns **cbl**
    - `address` column
5. Get longitude and latitude -- this was the bulk of this and took a very long time and a lot of trial and error.
  - I used the `arcgis` method from the `arcgisgeocode` package as the method for the `geocode()` function from `tidygeocoder` package to convert.
    - I used this method rather than other ones such as `census` or `osm` because the addresses were messy/incomplete and `arcgis` was the only method (that I had access) that could deal with these addresses. `census` and `osm` resulted in lots of NAs.
  - I had to batch this because it kept timing out on me. Even with batching, I had to manually re-run it. The code below is what I had to re-run throughout 1 day:
    - ```
      start <- nrow(historic_districts_CLEAN_2)+1

      for(r in start:nrow(historic_districts)){
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
  - Queries took between .1 and 1 seconds each (for 1 address)

** NEED TO COME BACK AND FIX THE GEOCODING SO IT'S BASED ON CITY, STATE INSTEAD OF COUNTY, STATE (WA) **

# EDA
### Total number of historic districts by state
<img width="794" height="498" alt="image" src="https://github.com/user-attachments/assets/dafd82d3-5dcd-43da-adfe-ccbf24b5579f" />


### Total acreage of historic districts by state
<img width="794" height="498" alt="image" src="https://github.com/user-attachments/assets/612d066a-dda1-40f8-8d02-67f1054f03fb" />
