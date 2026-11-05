library(ggplot2)
library(tidyr)
library(dplyr)
library(stats)
library(paletteer)
library(PMCMRplus)
library(effectsize)

# function for splitting data in the form of mm:ss to seconds
to_sec <- function(x) {
  sapply(strsplit(x, ":"), function(y) {
    as.numeric(y[1]) * 60 + as.numeric(y[2])
  })
}

###################################
# Period 1 - Without Requirements #
###################################

activity_no_req <- read.csv("activity_no_reqs.csv") %>%
  # turn into seconds
  mutate(
    Start_sec = to_sec(Start.Time),
    End_sec = to_sec(End.Time)
  ) %>%
  # adjust for those that didn't start at 0:00
  group_by(Participant) %>%
  mutate(
    min_start = min(Start_sec),
    Start_adj = Start_sec - min_start,
    End_adj   = End_sec - min_start
  ) %>%
  ungroup() %>%
  # group into broader categories
  mutate(Activity_Category = case_when(
    Activity %in% c("Code on GitLab", "Code on VSCode", "Split Screen (Code on GitLab + Code on VSCode)", "Split Screen (Code on VSCode + Code on GitLab)") ~ "Code",
    Activity %in% c("Split Screen (Code on VSCode + Overview)", "Split Screen (Code on VSCode + Testing)", "Split Screen (Overview + Code on VSCode)", "Navigating") ~ "Other",
    Activity == "Overview" ~ "MR Overview",
    Activity == "Issue" ~ "Issue",
    Activity == "Commits" ~ "Commits",
    Activity == "Testing" ~ "Testing",
    Activity == "Writing Review" ~ "Writing Review",
    TRUE ~ "Other"
  ))

# compute durations by for each participant and category
duration_wo_reqs <- activity_no_req %>%
  mutate(
    duration  = End_sec - Start_sec
  ) %>%
  group_by(Participant, Activity_Category) %>%
  summarise(seconds = sum(duration), .groups = "drop")

# plot to make Figure 1a
ggplot(duration_wo_reqs, aes(x=Participant, y=seconds/60,fill=factor(Activity_Category, levels=c("Requirements", "Code", "Commits", "MR Overview", "Issue", "Other", "Writing Review", "Testing")))) + 
  geom_col() +
  scale_fill_manual(values = c(
    "Requirements" = "#DB6D00",
    "Code" = "#004949",
    "Commits" = "#FF6DB6",
    "Issue" = "#006DDB",
    "MR Overview" = "#490092",
    "Testing" = "#B66DFF",
    "Writing Review" = "#920000",
    "Other" = "#B6DBFF"
  )) +
  labs(
    x="Subjects",
    y="Duration (minutes)",
    fill="Artifact"
  ) +
  theme(legend.position = c(0.17, 0.80)) +
  ylim(0, 40)

duration_wo_reqs_tidy <- duration_wo_reqs %>%
  pivot_wider(names_from = Activity_Category, values_from = seconds) %>%
  mutate(across(everything(), ~replace(., is.na(.), 0)))

# percentage of their time each participant spent in each category
percent_wo_reqs <- duration_wo_reqs_tidy %>%
  rowwise() %>%
  mutate(across(-Participant, ~ .x / sum(c_across(-Participant)) * 100)) %>%
  ungroup()

# compute total duration
duration_wo_reqs_tidy <- duration_wo_reqs_tidy %>%
  mutate(Total = rowSums(across(where(is.numeric)), na.rm = TRUE))

# get min, q1, median, q3, and max for each category
quartiles_wo_reqs <- t(sapply(duration_wo_reqs_tidy[sapply(duration_wo_reqs_tidy, is.numeric)],
                              function(x) quantile(x, probs = c(0, .25, .5, .75, 1), na.rm = TRUE)))

#####################
# With Requirements #
#####################

activity_w_req <- read.csv("activity_w_reqs.csv") %>%
  # turn into seconds
  mutate(
    Start_sec = to_sec(Start.Time),
    End_sec = to_sec(End.Time)
  ) %>%
  # adjust for those that didn't start at 0:00
  group_by(Participant) %>%
  mutate(
    min_start = min(Start_sec),
    Start_adj = Start_sec - min_start,
    End_adj   = End_sec - min_start
  ) %>%
  ungroup() %>%
  # group into broader categories
  mutate(Activity_Category = case_when(
    Activity %in% c("Code on GitLab", "Code on VSCode", "Split Screen (Code on GitLab + Code on VSCode)", "Split Screen (Code on VSCode + Code on GitLab)") ~ "Code",
    Activity %in% c("Split Screen (Code on VSCode + Overview)", "Split Screen (Code on VSCode + Testing)", "Split Screen (Overview + Code on VSCode)", "Navigating") ~ "Other",
    Activity == "Requirements" ~ "Requirements",
    Activity == "Overview" ~ "MR Overview",
    Activity == "Issue" ~ "Issue",
    Activity == "Commits" ~ "Commits",
    Activity == "Testing" ~ "Testing",
    Activity == "Writing Review" ~ "Writing Review",
    TRUE ~ "Other"
  ))

# compute durations by for each participant and category
duration_w_reqs <- activity_w_req %>%
  mutate(
    duration  = End_sec - Start_sec
  ) %>%
  group_by(Participant, Activity_Category) %>%
  summarise(seconds = sum(duration), .groups = "drop")

# plot to make Figure 1b
ggplot(duration_w_reqs, aes(x=Participant, y=seconds/60,fill=factor(Activity_Category, levels=c("Requirements", "Code", "Commits", "MR Overview", "Issue", "Other", "Writing Review", "Testing")))) + 
  geom_col() +
  scale_fill_manual(values = c(
    "Requirements" = "#DB6D00",
    "Code" = "#004949",
    "Commits" = "#FF6DB6",
    "Issue" = "#006DDB",
    "MR Overview" = "#490092",
    "Testing" = "#B66DFF",
    "Writing Review" = "#920000",
    "Other" = "#B6DBFF"
  )) +
  labs(
    x="Subjects",
    y="Duration (minutes)",
    fill="Artifact"
  ) +
  theme(legend.position = c(0.17, 0.80)) +
  ylim(0, 40)

duration_w_reqs_tidy <- duration_w_reqs %>%
  pivot_wider(names_from = Activity_Category, values_from = seconds) %>%
  mutate(across(everything(), ~replace(., is.na(.), 0)))

# percentage of their time each participant spent in each category
percent_w_reqs <- duration_w_reqs_tidy %>%
  rowwise() %>%
  mutate(across(-Participant, ~ .x / sum(c_across(-Participant)) * 100)) %>%
  ungroup()

# compute total duration and total duration except on requirements
duration_w_reqs_tidy <- duration_w_reqs_tidy %>%
  mutate(Total = rowSums(across(where(is.numeric)), na.rm = TRUE)) %>%
  mutate(TotalMinusReqs = Total - Requirements)

# get min, q1, median, q3, and max for each category
quartiles_w_reqs <- t(sapply(duration_w_reqs_tidy[sapply(duration_w_reqs_tidy, is.numeric)],
                             function(x) quantile(x, probs = c(0, .25, .5, .75, 1), na.rm = TRUE)))

# get min, q1, median, q3, and max for each category for only participants who understood relevant requirements instructions
duration_w_reqs_tidy_subset <- duration_w_reqs_tidy %>%
  filter(Participant %in% c("B", "C", "D", "E", "H", "J"))
quartiles_w_reqs_subset <- t(sapply(duration_w_reqs_tidy_subset[sapply(duration_w_reqs_tidy_subset, is.numeric)],
                             function(x) quantile(x, probs = c(0, .25, .5, .75, 1), na.rm = TRUE)))

#######################################
# Comparison of Period 1 and Period 2 #
#######################################

# compare total durations with Wilcoxon signed rank
totals <- data.frame(
  duration = c(duration_w_reqs_tidy$Total, duration_wo_reqs_tidy$Total),
  group = c(
    rep("w_reqs", times=length(duration_w_reqs_tidy$Total)),
    rep("wo_reqs", times=length(duration_wo_reqs_tidy$Total))
  ))
wilcox.test(duration_w_reqs_tidy$Total, duration_wo_reqs_tidy$Total, paired = TRUE)
rank_biserial(duration_w_reqs_tidy$Total, duration_wo_reqs_tidy$Total, paired = TRUE)

# compare Period 1 total duration with Period 2 duration excluding reqs with Wilcoxon signed rank
totals_minus_reqs <- data.frame(
  duration = c(duration_w_reqs_tidy$TotalMinusReqs, duration_wo_reqs_tidy$Total),
  group = c(
    rep("w_reqs", times=length(duration_w_reqs_tidy$TotalMinusReqs)),
    rep("wo_reqs", times=length(duration_wo_reqs_tidy$Total))
  ))
wilcox.test(duration_w_reqs_tidy$TotalMinusReqs, duration_wo_reqs_tidy$Total, paired = TRUE)
rank_biserial(duration_w_reqs_tidy$TotalMinusReqs, duration_wo_reqs_tidy$Total, paired = TRUE)


# compare testing durations with Wilcoxon signed rank
testing <- data.frame(
  duration = c(duration_w_reqs_tidy$Testing, duration_wo_reqs_tidy$Testing),
  group = c(
    rep("w_reqs", times=length(duration_w_reqs_tidy$Testing)),
    rep("wo_reqs", times=length(duration_wo_reqs_tidy$Testing))
  ))
wilcox.test(duration_w_reqs_tidy$Testing, duration_wo_reqs_tidy$Testing, paired = TRUE)
rank_biserial(duration_w_reqs_tidy$Testing, duration_wo_reqs_tidy$Testing, paired = TRUE)

############################
# Sequence of Requirements #
############################
# includes order, duration, and eye movement type for each observation
# manual observations are missing eye movement type
requirements <- read.csv("requirements_detail.csv")

# get durations for each requirements
by_req_long <- requirements %>%
  mutate(Duration = (Stop - Start)/1000) %>%
  group_by(Participant, Requirement) %>%
  summarise(Duration = sum(Duration, na.rm = TRUE), .groups = "drop") %>%
  complete(Participant, Requirement, fill = list(Duration = 0))

# include whether the requirement was ultimately selected by the subject
selected <- read.csv("selected_reqs.csv")
by_req_long <- by_req_long %>%
  left_join(
    selected %>% mutate(Selected = 1),
    by = c("Requirement", "Participant")
  ) %>%
  mutate(Selected = ifelse(is.na(Selected), 0, Selected))

# plot for Figure 2
ggplot(by_req_long, aes(x = Requirement, y = Participant, size = Duration, color = factor(Selected, levels = c(0,1), labels = c("False","True")))) +
  geom_point(data = subset(by_req_long, Duration > 0)) +
  geom_point(data = subset(by_req_long, Duration == 0), shape = 4, size = 1, stroke = 1.5) +
  scale_y_discrete(
    labels = c(
      "A" = "A*",
      "B" = "B",
      "C" = "C",
      "D" = "D",
      "E" = "E",
      "F" = "F",
      "G" = "G*",
      "H" = "H",
      "I" = "I",
      "J" = "J"
    )
  ) +
  scale_x_continuous(breaks = 1:31) + 
  scale_color_manual(values = c(
    "True" = "#490092",
    "False" = "#DB6D00"
  )) +
  labs(
    x = "Requirements",
    y = "Subjects",
    color = "Selected",
    size = "Duration\n(seconds)"
  ) +
  theme(text = element_text(size = 20), axis.title.y = element_text(angle = 0, vjust = 0.5))

# Friedman rank sum test comparing duration spent on each requirement 
friedman.test(Duration ~ Requirement | Participant, data = by_req_long)
comparison <- frdAllPairsExactTest(y = by_req_long$Duration, groups = by_req_long$Requirement, blocks = by_req_long$Participant)

by_req_tidy <- by_req_long %>%
  select(Participant, Requirement, Duration) %>%
  pivot_wider(
    names_from = Requirement,
    values_from = Duration
  )

# subset for only participants who understood relevant requirements instructions
by_req_long_subset <- by_req_long %>%
  filter(Participant %in% c("B", "C", "D", "E", "H", "J"))

# get min, q1, median, q3, and max for selected and not selected, for all and for subset
quartiles <- by_req_long %>%
  group_by(Selected) %>%
  summarise(quartiles = list(fivenum(Duration)))
quartiles_subset <- by_req_long_subset %>%
  group_by(Selected) %>%
  summarise(quartiles = list(fivenum(Duration)))

# Wilcoxon rank sum testing difference between selected and not selected, for all and for subset
wilcox.test(Duration ~ Selected, by_req_long_subset)
rank_biserial(Duration ~ Selected, by_req_long_subset)
wilcox.test(Duration ~ Selected, by_req_long)
rank_biserial(Duration ~ Selected, data=by_req_long)
