# CulturalInstitutionsSRP2026
a repo for the SRP project on cultural institutions

# **IMPORTANT COLLABORATION INFORMATION:**

We will use GitHub to make sure everyone is able to access everyone else's work. If you need a general GitHub brush up lesson, let me know!

Before you do anything, clone this repo onto your computer. **Make sure you open the associated R project any time you are doing coding for this project in RStudio, and close out of the project any time you do coding for any other reason!**

If you took 220 with me, we never covered the *proper* way to collaborate with others, but we will do so here. In a word, we want to use **branches**.

Everyday you start work, you should follow this general process

1) Start by pulling any teammates' latest changes onto your computer. On GitHub Desktop, you'll likely see a blue "Pull changes" button. If you don't, for good measure, click "Fetch origin" at the top of GitHub Desktop (make sure you are looking at the right repo - CulturalInstitutionsSRP2026). That very well might update your GitHub Desktop and show you changes you need to pull. If so, click the blue button. If not, proceed to step 2.
2) **Create a branch**: Do NOT write code directly on the main branch (that increases the risk of merge conflicts substantially). Instead, click the "Current branch" dropdown in GitHub Desktop and click "New branch." Make a new branch, and feel free to name it whatever (your initials, a word describing what you are doing, whatever. Don't include spaces.)
3) Do your coding.
4) When you are done for the day, commit your changes. In the bottom left corner of GitHub Desktop (in the small search bar looking thing), you can and should make a comment on what the changes were. If you need extra space, look below in the bigger text box that says "Description" to add extra details. Once you have filled that out, click the blue "Commit" button below. This will take a second, and then you will have a big blue "Push origin" button appear.
5) Push your changes by clicking the blue "Push origin" button. It may also say "Publish Branch."
6) Create a pull request by clicking "Branch" at the top of GitHub Desktop and clicking "Create Pull Request." This will open up GitHub on the browser and be what merges your branch with the main repository. Feel free to add a comment there that discusses what changes are involved with your branch. Click "Create Pull Request" on GitHub. Your changes will either be auto-merged to the main branch or, if there is a conflict, they should come to me to review. Your current branch will be auto-deleted (a good thing, you can remake a new branch tomorrow!)
7) That's it! You started by making sure you had the most recent version of the repository and making your own personal branch, did a bunch of coding, and ended by pushing all of your changes to the main branch. Good work today. Start over at step 1 tomorrow (or enjoy your weekend!)

If you have any questions about the above, this video may help (or again, please don't hesitate to ask!): https://www.youtube.com/watch?v=8x6V5IOuXog


# **Approximate Schedule**

- 6/9 - 6/12: Intro to project, pick types of institutions interested in, find sources of data and make a plan to collect that data before EOW (including assigning folks to data sources to focus on)
- 6/15 - 6/19: Write code to scrape and/or document and execute plan to collect data. Clean individual datasets. Give to Emily. Emily joins datasets.
- 6/22 - 6/26: Extra week for back and forth here
- 6/29 - 7/3: Write up codebook. Build website
- 7/6 - 7/10: Blog posts of findings, Shiny app
- 7/13: Launch!



# **Goals (bolded are included in minimal goal, non-bolded are extras):**

- **Talk as a group about what sorts of data we would like to collect (jobs-related but anything else?)**
- **Identify data sources of institutions that can be scraped or otherwise collected (eye towards terms of service, ethics, make sure there is some sort of location (lat/lon, address, etc.) associated with it)**
- **Scrape or collect data (be very careful with tracking where all data come from for documentation purposes)**
- **Clean and join data (again, make sure all of this is in a reproducible script and documented clearly) - include column on source and/or type of institution (museum, monument, etc. AND another on job related, other cultural thing?)**
- **Write up a small codebook detailing sources of data, columns contained, etc.**
- **Make a website where folks can download the data from**
- Website may also contain Shiny app, blog posts, etc. of people exploring the data
- Everyone can write a blog post of something interesting with a visual
- Shiny app where people can map the data, select and filter, etc.
