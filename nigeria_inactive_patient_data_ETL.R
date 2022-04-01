
# -- TITLE: Inactive Patient Tracking Report Transformation
# -- AUTHOR: Femi Akinmade (qlx6@cdc.gov)
# -- DESCRIPTION: 
# --------->> Extraction of partner inactive patient tracking
# --------->> & tranformation into the R2R dashboard dataset
# --------- To be run on only recieved reports from partners
# -- CREATION DATE: 11/23/2021
# ===March 23rd, 2022 Update

# = Libraries ============== #
# ========================== #
options("install.lock"=FALSE)
#install.packages("XLConnect")

library(tidyverse)
library(dplyr)
library(reshape2)
library(plyr)
library(readxl)
library(writexl)
library(openxlsx)
library(excel.link)


rm(list = ls())
#sessionInfo()

date <- Sys.Date()
time <- Sys.time()

ptm <- proc.time()

# - Set directory for IP reports - #
# -------------------------------------------------------- #
#setwd("C:/Users/qlx6/OneDrive - CDC/general dynamics - icpi/GitHub/retention_analytics_nigeria/Nigeria_R2R_Transformation/1_APIN")
setwd("C:/Users/qlx6/OneDrive - CDC/general dynamics - icpi/GitHub/retention_analytics_nigeria/Nigeria_R2R_Transformation/2_CCFN")
#setwd("C:/Users/qlx6/OneDrive - CDC/general dynamics - icpi/GitHub/retention_analytics_nigeria/Nigeria_R2R_Transformation/3_CIHP")
#setwd("C:/Users/qlx6/OneDrive - CDC/general dynamics - icpi/GitHub/retention_analytics_nigeria/Nigeria_R2R_Transformation/4_IHVN")
################################################################################
################################################################################

################################################################################
################################################################################

all.list <- list.files(pattern = '*.xlsx')
all.list

all <- lapply(all.list, function(i){
  x = read_excel(i, sheet = 1)
  x$file = i
  x
})
 

all <- do.call("rbind.data.frame", all)


# ==== Switch vector here ==== #
################################
all$NDR_PID <- na.omit(all$NDR_PID) # remove rows with NA in NDR_PID


# ==== Clean leading and trailing white spaces ==== #
all <- data.frame(lapply(all, trimws))


# ==== xxxxxxxxxxxxxxx ==== #
names <- names(all)
names
# ==== xxxxxxxxxxxxxxx ==== #
SEX_levels <- unique(all$SEX)
FINE_AGE_levels <- unique(all$FINE_AGE)
DATA_PULL_levels <- unique(all$DATA_PULL)
ART_TIME_levels <- unique(all$ART_TIME)
INACTIVE_TIME_levels <- unique(all$INACTIVE_TIME)
LOST_IN_TX_levels <- unique(all$LOST_IN_TX)
TRACK_ATTEMPTED_levels <- unique(all$TRACK_ATTEMPTED)
REACHED_levels <- unique(all$REACHED)
NOT_REACHED_REASON_levels <- unique(all$NOT_REACHED_REASON)
IMPLEMENTING_PARTNER_levels <- unique(all$IMPLEMENTING_PARTNER)
STATE_levels <- unique(all$STATE)
LGA_levels <- unique(all$LGA)
FACILITY_NAME_levels <- unique(all$FACILITY_NAME)
FACILITY_UID_levels <- unique(all$FACILITY_UID)
ART_START_levels <- unique(all$ART_START)
INACTIVE_DATE_levels <- unique(all$INACTIVE_DATE)
INACTIVE_QTR_levels <- unique(all$INACTIVE_QTR)
INACTIVE_MONTH_levels <- unique(all$INACTIVE_MONTH)
RETURN_VALIDATE_levels <- unique(all$RETURN_VALIDATE)
LAST_DRUG_PICKUP_INACTIVE_levels <- unique(all$LAST_DRUG_PICKUP_INACTIVE)
LAST_DRUG_MMD_INACTIVE_levels <- unique(all$LAST_DRUG_MMD_INACTIVE)
MOST_RECENT_DRUG_PICKUP_levels <- unique(all$MOST_RECENT_DRUG_PICKUP)
DIED_NDR_levels <- unique(all$DIED_NDR)
TRANSFERRED_NDR_levels <- unique(all$TRANSFERRED_NDR)
REACHED_REFUSE_RETURN_levels <- unique(all$REACHED_REFUSE_RETURN)
REACHED_RETURN_levels <- unique(all$REACHED_RETURN)
DEAD_levels <- unique(all$DEAD)
TRANSFERRED_OUT_NOREC_levels <- unique(all$TRANSFERRED_OUT_NOREC)

# ==== Check Levels of each column for consistency ==== #
SEX_levels
FINE_AGE_levels
DATA_PULL_levels
ART_TIME_levels
INACTIVE_TIME_levels
LOST_IN_TX_levels
TRACK_ATTEMPTED_levels
REACHED_levels
NOT_REACHED_REASON_levels  

# ==== Create Inactive PID ==== #
library(tidyr)
#all <- all[!(is.na(all$NDR_PID)), ]

all <- all %>%
  mutate(PREFIX = "I_PID")
all <- unite(all, INACTIVE_PID, PREFIX, NDR_PID, SITE_PID, sep = "_")

all <- all %>%
  select(INACTIVE_PID:NARRATIVE)


library(plyr)

all$ART_START[which(is.na(all$ART_START))] <- ""
all$INACTIVE_DATE[which(is.na(all$INACTIVE_DATE))] <- ""
all$LAST_DRUG_PICKUP_INACTIVE[which(is.na(all$LAST_DRUG_PICKUP_INACTIVE))] <- ""


# ==== IP ==== #
all$IMPLEMENTING_PARTNER <- revalue(all$IMPLEMENTING_PARTNER, 
                                    c("0" = "Unknown",
                                      "1" = "Unknown",
                                      "NA" = "Unknown"))

all$IMPLEMENTING_PARTNER[which(is.na(all$IMPLEMENTING_PARTNER))] <- "Unknown"


# ==== STATE ==== #
all$STATE <- revalue(all$STATE, 
                     c("0" = "Unknown",
                       "1" = "Unknown",
                       "NA" = "Unknown"))

all$STATE[which(is.na(all$STATE))] <- "Unknown"


# ==== LGA ==== #
all$LGA <- revalue(all$LGA, c("0" = "Unknown",
                              "1" = "Unknown",
                              "NA" = "Unknown"))

all$LGA[which(is.na(all$LGA))] <- "Unknown"


# ==== LGA ==== #
all$FACILITY_NAME <- revalue(all$FACILITY_NAME, 
                             c("NA" = "Unknown"))

all$FACILITY_NAME[which(is.na(all$FACILITY_NAME))] <- "Unknown"


# ==== Clean Sex ==== #
#all$SEX <- revalue(all$SEX, c("M" = "Male", 
#                              "F" = "Female"))
all$SEX[which(is.na(all$SEX))] <- "Unknown"

# ==== Clean fine age ==== #
all$FINE_AGE <- revalue(all$FINE_AGE, c("43834" = "1-4",
                                        "44200" = "1-4", 
                                        "1-4" = "0-4",
                                        "0 - 4" = "0-4",
                                        "43960" = "5-9",
                                        "44325" = "5-9", 
                                        "44118" = "10-14", 
                                        "44483" = "10-14",
                                        "15 - 19" = "15-19",
                                        "20 - 24" = "20-24",
                                        "25 - 29" = "25-29",
                                        "30 - 34" = "30-34",
                                        "35 - 39" = "35-39",
                                        "40 - 44" = "40-44",
                                        "45 - 49" = "45-49",
                                        "50 - 54" = "50-54", 
                                        "55 - 59" = "55-59",
                                        "60 - 64" = "60-64",
                                        "65 - 69" = "65-69",
                                        "70 - 74" = "70-74",
                                        "75 - 79" = "75-79"))
all$FINE_AGE[which(is.na(all$FINE_AGE))] <- "Unknown"

# ==== Clean Inactive Time ==== #
all$ART_TIME <- revalue(all$ART_TIME, c("2 - 4 weeks" = "2-4 weeks",
                                        "2-4 Weeks" = "2-4 weeks",
                                        "1 - 3 months" = "1-3 Months",
                                        "2 - 4 months" = "2-4 Months",
                                        "4 - 6 months" = "4-6 Months",
                                        #"6" = "> 6 Months",
                                        "0" = "Unknown",
                                        "1" = "Unknown"))
all$ART_TIME[which(is.na(all$ART_TIME))] <- "Unknown"


# ==== Clean Inactive Time ==== #
all$ART_START <- revalue(all$ART_START, c("NA" = "",
                                          "1 - 3 months" = "1-3 Months",
                                          "2 - 4 months" = "2-4 Months",
                                          "4 - 6 months" = "4-6 Months",
                                          #"6" = "> 6 Months",
                                          "0" = "Unknown",
                                          "1" = "Unknown"))
all$ART_TIME[which(is.na(all$ART_TIME))] <- "Unknown"



# ==== Clean Inactive Time ==== #
all$INACTIVE_TIME <- revalue(all$INACTIVE_TIME, c("2 - 4 weeks" = "2-4 weeks",
                                                  "2-4 Weeks" = "2-4 weeks",
                                                  "1 - 3 months" = "1-3 Months",
                                                  "2 - 4 months" = "2-4 Months",
                                                  "4 - 6 months" = "4-6 Months",
                                                  #"6" = "> 6 Months",
                                                  "0" = "Unknown",
                                                  "1" = "Unknown"))
all$INACTIVE_TIME[which(is.na(all$INACTIVE_TIME))] <- "Unknown"


# ==== Clean Lost in HMIS ==== #
all$LOST_IN_TX <- revalue(all$LOST_IN_TX, 
                          c("other" = "Other",
                            "inactive due to duplicate patient records on NDR" = "Inactive due to duplicate patient records on NDR",
                            "inactive due to unsuccessful upload on NDR" = "Inactive due to unsuccessful upload on NDR",
                            "0" = "Unknown"))
all$LOST_IN_TX[which(is.na(all$LOST_IN_TX))] <- ""


# ==== Clean Track Attempted ==== #
all$TRACK_ATTEMPTED <- revalue(all$TRACK_ATTEMPTED, 
                               c("Yes-tracking" = "Yes-tracking attempted",
                                 "yes-tracking attempted" = "Yes-tracking attempted",
                                 "No-tracking not attempted" = "No-tracking not attempted",
                                 "1" = "Unknown",
                                 "Inactive due to unsuccessful upload on NDR" = "Unknown"))
all$TRACK_ATTEMPTED[which(is.na(all$TRACK_ATTEMPTED))] <- ""


# ==== Clean Reached ==== #
all$REACHED <- revalue(all$REACHED, 
                       c("yes-Reached" = "Yes-Reached",
                       "Yes-reached" = "Yes-Reached",
                       "Yes-tracking attempted" = "Yes-Reached",
                       "no-attempted, but did not reach" = "No-attempted, but did not reach",
                       "1" = "No-attempted, but did not reach"))

all$REACHED[which(is.na(all$REACHED))] <- ""


# ==== NOT_REACHED_REASON ==== #
all$NOT_REACHED_REASON <- revalue(all$NOT_REACHED_REASON, 
                                  c("Number Not reachable" = "Inaccurate phone number/address",
                                    "Inaccurate Phone number/address" = "Inaccurate phone number/address",
                                    "TRACKING ONGOING" = "Tracking Ongoing",
                                    "TRacking ongoing" = "Tracking Ongoing",
                                    "tracking ongoing" = "Tracking Ongoing",
                                    "tracking on going" = "Tracking Ongoing",
                                    "Tracking ongoing" = "Tracking Ongoing",
                                    "Tracking ongoing" = "Tracking Ongoing",
                                    "No unique ID (SITE_PID)",
                                    "others" = "Other",
                                    "other" = "Other",
                                    "other" = "Other",
                                    "Others" = "Other",
                                    "TERMINATE CARE" = "",
                                    "TO" = "",
                                    "43566" = ""))
all$NOT_REACHED_REASON[which(is.na(all$NOT_REACHED_REASON))] <- ""



###############################################
# =======  Recoded & Derived Columns ======== #
###############################################

# ===  Recode LOST_IN_TX CATEGORIES === #

#changed the name from LITx to LOST_HMIS
all <- all %>%
  mutate(LOST_HMIS = case_when(
    LOST_IN_TX == "Inactive due to duplicate patient records on NDR" ~ 1,
    LOST_IN_TX == "Inactive due to incomplete data entry to EMR" ~ 1,
    LOST_IN_TX == "Inactive due to unsuccessful upload on NDR" ~ 1,
    LOST_IN_TX == "Other" ~ 1)) %>%
  replace_na(list(LOST_HMIS = 0))


all <- all %>%
  mutate(IIT = if_else(
    LOST_HMIS == 0, 1, 0)) #%>%
#  replace_na(list(LOST_IN_TX = 1))


# ==== LITx_incomplete_emr ==== #
#Name changed to HMIS_INCOMPLETE_EMR
all <- all %>%
  mutate(HMIS_INCOMPLETE_EMR = if_else(
    LOST_IN_TX == "Inactive due to incomplete data entry to EMR", 1, 0)) %>%
  replace_na(list(HMIS_INCOMPLETE_EMR = 0))

# ==== LITx_ndr_unsuccessful_upload ==== #
#Name changed
all <- all %>%
  mutate(HMIS_NDR_UNSUCCSSFUL_UPLOAD = if_else(
    LOST_IN_TX == "Inactive due to unsuccessful upload on NDR", 1, 0)) %>%
  replace_na(list(HMIS_NDR_UNSUCCSSFUL_UPLOAD = 0))

# ==== LITx_ndr_duplicates ==== #
#Name changed
all <- all %>%
  mutate(HMIS_NDR_DUPLICATES = if_else(
    LOST_IN_TX == "Inactive due to duplicate patient records on NDR", 1, 0)) %>%
  replace_na(list(HMIS_NDR_DUPLICATES = 0))

# ==== LITx_Other ==== #
#Name changed
all <- all %>%
  mutate(HMIS_OTHER = if_else(
    LOST_IN_TX == "Other", 1, 0)) %>%
  replace_na(list(HMIS_OTHER = 0))

# ==== LITx_Blank ==== #
#Name changed; Can we use this to define IIT? See metric below (I moved it from above)
all <- all %>%
  mutate(HMIS_BLANK = if_else(
    LOST_IN_TX == "NA", 1, 0)) %>%
  replace_na(list(HMIS_BLANK = 1))


# ==== Interuption In Treatment ==== #
#updated name from name change above
#Check "!"- I wasn't sure what the "!" was for...
#all <- all %>%
#  mutate(IIT = if_else(
#    HMIS_BLANK != 1, 1, 0)) %>%
#  replace_na(list(IIT = 1))


#updated names from name change above
all <- all %>%
  mutate(INACTIVE_SUBSET = case_when(
    HMIS_INCOMPLETE_EMR == 1 ~ "LOST_HMIS",
    HMIS_NDR_UNSUCCSSFUL_UPLOAD == 1 ~ "LOST_HMIS",
    HMIS_NDR_DUPLICATES == 1 ~ "LOST_HMIS",
    HMIS_OTHER == 1 ~ "LOST_HMIS",
    IIT == 1 ~ "IIT"))




# === ART TIME CATEGORIES === #
####################################

all <- all %>%
  mutate(`ART_TIME: < 3 months` = if_else(
    ART_TIME == "< 3 months", 1, 0)) %>%
  replace_na(list(`ART_TIME: < 3 months` = 0))


all <- all %>%
  mutate(`ART_TIME: 3-6 months` = if_else(
    ART_TIME == "3-6 months", 1, 0)) %>%
  replace_na(list(`ART_TIME: 3-6 months` = 0))

all <- all %>%
  mutate(`ART_TIME: 7-11 months` = if_else(
    ART_TIME == "7-11 months", 1, 0)) %>%
  replace_na(list(`ART_TIME: 7-11 months` = 0))

all <- all %>%
  mutate(`ART_TIME: 12+ months` = if_else(
    ART_TIME == "12+ months", 1, 0)) %>%
  replace_na(list(`ART_TIME: 12+ months` = 0))




# === REACHED CATEGORIES === #
##############################

#################################
# ==== REACHED_Y_RETURN ==== #
all <- all %>%
  mutate(REACHED_Y_RETURN = if_else(
    !is.na(REACHED_RETURN), 1, 0)) %>%
  replace_na(list(REACHED_Y_RETURN = 0))

# ==== REACHED_Y_REFUSE ==== #
all <- all %>%
  mutate(REACHED_Y_REFUSE = if_else(
    !is.na(REACHED_REFUSE_RETURN), 1, 0)) %>%
  replace_na(list(REACHED_Y_REFUSE = 0))

# ==== REACHED_Y_DIED ==== #
all <- all %>%
  mutate(REACHED_Y_DIED = if_else(
    !is.na(DEAD), 1, 0)) %>%
  replace_na(list(REACHED_Y_DIED = 0))

# ==== REACHED_Y_TRANSFER ==== #
all <- all %>%
  mutate(REACHED_Y_TRANSFER = if_else(
    !is.na(TRANSFERRED_OUT_NOREC), 1, 0)) %>%
  replace_na(list(REACHED_Y_TRANSFER = 0))

# ==== ADDED - REACHED_Y_NOENTRY ==== #
#all <- all %>%
#  mutate(REACHED_Y_NOENTRY = if_else(
#    is.na(NOT_REACHED_REASON), 1, 0))#%>%
#  replace_na(list(REACHED_Y_NOENTRY = 0))

# ==== ADDED - REACHED_Y_NOENTRY ==== #
all <- all %>%
  mutate(
    REACHED_Y_NOENTRY = if_else(
      REACHED == "" &
        REACHED_Y_RETURN == 0 &
        REACHED_Y_REFUSE == 0 &
        REACHED_Y_DIED == 0 &
        REACHED_Y_TRANSFER == 0, 1, 0)) %>%
  replace_na(list(REACHED_Y_NOENTRY = 0)) 

# ==== REACHED_Y ==== #
#Edited to capture both yes reach response and outcomes in case no reach yes response.
all <- all %>%
  mutate(
    REACHED_Y = if_else(
      REACHED == "Yes-Reached"|
        REACHED_Y_RETURN == 1|
        REACHED_Y_REFUSE == 1|
        REACHED_Y_DIED == 1|
        REACHED_Y_TRANSFER == 1, 1, 0)) %>%
  replace_na(list(REACHED_Y = 0)) 



# ==== REACHED_Y_UNKNOWN

#######################
# ==== REACHED_N ==== #
all <- all %>%
  mutate(
    REACHED_N = if_else(
      REACHED_Y == 0, 1, 0))# %>%

#replace_na(list(REACHED_N = 1))


# Reached_N Reasons

# ==== NOT_REACHED_tracking_ongoing ==== #
all <- all %>%
  mutate(NOT_REACHED_tracking_ongoing = if_else(
    NOT_REACHED_REASON == "Tracking ongoing", 1, 0)) %>%
  replace_na(list(NOT_REACHED_tracking_ongoing = 0))

# ==== NOT_REACHED_no_phone_address ==== #
all <- all %>%
  mutate(NOT_REACHED_no_phone_address = if_else(
    NOT_REACHED_REASON == "No phone number/address", 1, 0)) %>%
  replace_na(list(NOT_REACHED_no_phone_address = 0))

# ==== NOT_REACHED_inaccurate_phone_address ==== #
all <- all %>%
  mutate(NOT_REACHED_inaccurate_phone_address = if_else(
    NOT_REACHED_REASON == "Inaccurate phone number/address", 1, 0)) %>%
  replace_na(list(NOT_REACHED_inaccurate_phone_address = 0))

# ==== NOT_REACHED_no_uid ==== #
all <- all %>%
  mutate(NOT_REACHED_no_uid = if_else(
    NOT_REACHED_REASON == "No unique ID (SITE_PID)", 1, 0)) %>%
  replace_na(list(NOT_REACHED_no_uid = 0))

# ==== NOT_REACHED_other ==== #
all <- all %>%
  mutate(NOT_REACHED_other = if_else(
    NOT_REACHED_REASON == "Other", 1, 0)) %>%
  replace_na(list(NOT_REACHED_other = 0))

# ==== Do we need this??? NOT_REACHED_no_entry ==== #
all <- all %>%
  mutate(NOT_REACHED_NoEntry = if_else(
    is.na(NOT_REACHED_REASON), 1, 0))#%>%
#  replace_na(list(NOT_REACHED_no_entry = 0))



# === TRACK ATTEMPTED CATEGORIES === #
# ==== IIT_TRACKED / REACHED_YES ==== #
all <- all %>%
  mutate(IIT_TRACKED_Y = if_else(
    TRACK_ATTEMPTED == "Yes-tracking attempted" |
      REACHED == "Yes-Reached" |
      REACHED_Y_RETURN == 1 |
      REACHED_Y_REFUSE == 1 |
      REACHED_Y_DIED == 1 |
      REACHED_Y_TRANSFER == 1 |
      NOT_REACHED_tracking_ongoing == 1 |
      NOT_REACHED_no_phone_address == 1 |
      NOT_REACHED_inaccurate_phone_address == 1 |
      NOT_REACHED_no_uid == 1 |
      NOT_REACHED_other == 1,1,0)) %>%
  replace_na(list(IIT_TRACKED_Y = 0))

# ==== EDITED IIT_TRACKED_N ==== #
all <- all %>%
  mutate(IIT_TRACKED_N = if_else(
    IIT_TRACKED_Y != 1,1,0))

# ==== IIT SUBSET ==== #
all <- all %>%
  mutate(IIT_SUBSET = case_when(
    IIT_TRACKED_N == 1 ~ "IIT_TRACKED_N",
    IIT_TRACKED_Y == 1 ~ "IIT_TRACKED_Y"))


#====Validation metric====
all <- all %>%
  mutate(REACHED_Y_N = case_when(
    REACHED_Y == 1 ~ "REACHED_Y",
    REACHED_N == 1 ~ "REACHED_N"))

#=======Check for report dates in dataset=======#
d <- unique(all$DATA_PULL)
d

# ======================================================================== #
# ======= Here is where we incorporate the New_LTFU_LiH to dataset ======= #
# ======================================================================== #

# - A comparison between this new and previous --------------------------- #
# - Change this directory to the directory with the continue_LTFU dataset for the appropriate IP -- #
setwd("C:/Users/qlx6/OneDrive - CDC/Inactive Patient Tracking Dashboard/partner_reports/ccfn/continued")
new_inactive <- read_excel("Continue_LTFU_2022-01-24 - Copy.xlsx")

new_inactive_0 <- new_inactive %>% 
  filter(IMPLEMENTING_PARTNER %in% c("CCFN"))


new_inactive_1 <- new_inactive_0 %>% 
  mutate(PREFIX = "I_PID")

new_inactive_2 <- new_inactive_1 %>% 
  unite(INACTIVE_PID, PREFIX, NDR_PID, SITE_PID, sep = "_")

new_inactive_3 <- new_inactive_2 %>% 
  select(INACTIVE_PID, NEW_INACTIVE, DATA_PULL)

new_inactive_4 <- left_join(all, new_inactive_3, 
                            by = "INACTIVE_PID") %>% 
  dplyr::rename(DATA_PULL = DATA_PULL.x, 
                NEW_INACTIVE = NEW_INACTIVE.x) %>% 
  dplyr::select(INACTIVE_PID:NEW_INACTIVE.y)

new_inactive_5 <- new_inactive_4 %>% 
  mutate(LiH_New = if_else(
    LOST_HMIS == 1 & 
      NEW_INACTIVE == 1, 1, 0))

new_inactive_6 <- new_inactive_5 %>% 
  mutate(IIT_New = if_else(
    IIT == 1 & 
      NEW_INACTIVE == 1, 1, 0))

new_inactive_7 <- new_inactive_6 %>% 
  select(INACTIVE_PID:FINE_AGE, DATA_PULL, IMPLEMENTING_PARTNER:INACTIVE_SUBSET,
         `ART_TIME: < 3 months`, `ART_TIME: 3-6 months`, `ART_TIME: 7-11 months`,
         `ART_TIME: 12+ months`, REACHED_Y_RETURN:REACHED_Y_N, LiH_New, IIT_New, 
         UNRESOLVED_LiH, UNRESOLVED_IIT)
# =================================================== #



# ==================================================== #
# ======= Collapse into Facility-Level dataset ======= #
# ==================================================== #

all <- new_inactive_7 %>%
  select(INACTIVE_PID:FINE_AGE, DATA_PULL, IMPLEMENTING_PARTNER:INACTIVE_SUBSET,
         `ART_TIME: < 3 months`, `ART_TIME: 3-6 months`, `ART_TIME: 7-11 months`,
         `ART_TIME: 12+ months`, REACHED_Y_RETURN:REACHED_Y_N, LiH_New, IIT_New, 
         UNRESOLVED_LiH, UNRESOLVED_IIT)

all$UNRESOLVED_LiH <- as.numeric(all$UNRESOLVED_LiH)
all$UNRESOLVED_IIT <- as.numeric(all$UNRESOLVED_IIT)

all <- all %>% 
  group_by(FACILITY_UID, SEX, FINE_AGE, DATA_PULL, IMPLEMENTING_PARTNER, 
           STATE, LGA, FACILITY_NAME, ART_TIME, INACTIVE_TIME) %>% 
  dplyr::summarise(INACTIVE_PID_N = n(), 
                   LOST_HMIS=sum(LOST_HMIS),
                   IIT=sum(IIT), 
                   HMIS_INCOMPLETE_EMR=sum(HMIS_INCOMPLETE_EMR), 
                   HMIS_NDR_UNSUCCSSFUL_UPLOAD=sum(HMIS_NDR_UNSUCCSSFUL_UPLOAD), 
                   HMIS_NDR_DUPLICATES=sum(HMIS_NDR_DUPLICATES), 
                   HMIS_OTHER=sum(HMIS_OTHER), 
                   HMIS_BLANK=sum(HMIS_BLANK), 
                   `ART_TIME: < 3 months`=sum(`ART_TIME: < 3 months`),
                   `ART_TIME: 3-6 months`=sum(`ART_TIME: 3-6 months`), 
                   `ART_TIME: 7-11 months`=sum(`ART_TIME: 7-11 months`),
                   `ART_TIME: 12+ months`=sum(`ART_TIME: 12+ months`),
                   REACHED_Y_RETURN=sum(REACHED_Y_RETURN), 
                   REACHED_Y_REFUSE=sum(REACHED_Y_REFUSE), 
                   REACHED_Y_DIED=sum(REACHED_Y_DIED),
                   REACHED_Y_TRANSFER=sum(REACHED_Y_TRANSFER), 
                   REACHED_Y_NOENTRY=sum(REACHED_Y_NOENTRY), 
                   REACHED_Y=sum(REACHED_Y), 
                   REACHED_N=sum(REACHED_N), 
                   NOT_REACHED_tracking_ongoing=sum(NOT_REACHED_tracking_ongoing), 
                   NOT_REACHED_no_phone_address=sum(NOT_REACHED_no_phone_address), 
                   NOT_REACHED_inaccurate_phone_address=sum(NOT_REACHED_inaccurate_phone_address), 
                   NOT_REACHED_no_uid=sum(NOT_REACHED_no_uid), 
                   NOT_REACHED_other=sum(NOT_REACHED_other),
                   NOT_REACHED_NoEntry=sum(NOT_REACHED_NoEntry), 
                   IIT_TRACKED_Y=sum(IIT_TRACKED_Y), 
                   IIT_TRACKED_N=sum(IIT_TRACKED_N), 
                   LiH_New=sum(LiH_New, na.rm = TRUE), 
                   IIT_New=sum(IIT_New,  na.rm = TRUE), 
                   UNRESOLVED_LiH=sum(UNRESOLVED_LiH,  na.rm = TRUE), 
                   UNRESOLVED_IIT=sum(UNRESOLVED_IIT,  na.rm = TRUE))

##############################################################################

#setwd("C:/Users/qlx6/OneDrive - CDC/general dynamics - icpi/GitHub/retention_analytics_nigeria/Nigeria_R2R_Transformation/FINAL_R2R_DATASET/apin_r2r")
setwd("C:/Users/qlx6/OneDrive - CDC/general dynamics - icpi/GitHub/retention_analytics_nigeria/Nigeria_R2R_Transformation/FINAL_R2R_DATASET/ccfn_r2r")
#setwd("C:/Users/qlx6/OneDrive - CDC/general dynamics - icpi/GitHub/retention_analytics_nigeria/Nigeria_R2R_Transformation/FINAL_R2R_DATASET/cihp_r2r")
#setwd("C:/Users/qlx6/OneDrive - CDC/general dynamics - icpi/GitHub/retention_analytics_nigeria/Nigeria_R2R_Transformation/FINAL_R2R_DATASET/ihvn_r2r")

write_csv(all, file = "new_r2r.csv") # Drops new dataset with historic datasets in de-commented directory above

proc.time() - ptm

# ------------------------ END ----------------------------------- #
# ---------------------------------------------------------------- #

