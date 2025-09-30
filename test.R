require(readxl)
require(tidyverse)
require(tsibble)

df = read_xlsx('Data/Complaints.xlsx', sheet = 1) %>%
  mutate(date = paste(Month, Year),
         date = as.Date(paste0("1 ", date), format = "%d %B %Y"),
         FY_qtr   = yearquarter(date, fiscal_start = 4),             
         FY_year  = year(date) - as.integer(month(date) < 4),
         Month = yearmonth(date),
         FY_label = sprintf("%04d/%02d", FY_year, (FY_year + 1) %% 100))



af_main12 <- c(
  "#12436D","#28A197","#801650","#F46A25","#3D3D3D","#A285D1",
  "#0F8243","#1478A7","#E17E93","#B2D5DC","#E1B782","#BABABA"
)


df %>%
  filter(Domain == "Categories") %>%
  group_by(Month, Topic) %>%
  summarise(count = sum(Count), .groups = "drop") %>%
  ggplot(aes(x = Month, y = count, fill = Topic)) +
  geom_col() +
  geom_text(
    aes(label = ifelse(count == 0, "", count)),  # hide 0’s
    position = position_stack(vjust = 0.5),
    color = "black",
    size = 3,
    show.legend = FALSE
  ) +
  scale_fill_manual(values = af_main12, drop = FALSE) +
  scale_x_yearmonth(
    breaks = unique(df$Month),
    labels = scales::label_date("%b %Y")
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )


df %>%
  filter(Domain == "Categories") %>%
  group_by(FY_qtr, Topic) %>%
  summarise(count = sum(Count), .groups = "drop") %>%
  ggplot(aes(x = FY_qtr, y = count, fill = Topic)) +
  geom_col() +
  geom_text(
    aes(label = ifelse(count == 0, "", count)),  # hide 0’s
    position = position_stack(vjust = 0.5),
    color = "black",
    size = 3,
    show.legend = FALSE
  ) +
  scale_fill_manual(values = af_main12, drop = FALSE) +
  scale_x_yearquarter(
    breaks = unique(df$FY_qtr),
    labels = scales::label_date("%b %Y")
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

df %>%
  filter(Domain == "Categories") %>%
  group_by(FY_year, Topic) %>%
  summarise(count = sum(Count), .groups = "drop") %>%
  ggplot(aes(x = FY_year, y = count, fill = Topic)) +
  geom_col() +
  geom_text(
    aes(label = ifelse(count == 0, "", count)),
    position = position_stack(vjust = 0.5),
    color = "black",
    size = 3,
    show.legend = FALSE
  ) +
  scale_fill_manual(values = af_main12, drop = FALSE) +
  scale_x_continuous(
    breaks = sort(unique(df$FY_year)),
    labels = unique(df$FY_label)
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )



df %>%
  filter(Domain %in% c("Volume", 'SLA')) %>%
  group_by(Month) %>%
  summarise(
    Closed = sum(Count[Topic == "Closed"], na.rm = TRUE),
    SLA    = sum(Count[Topic == "SLA number"],    na.rm = TRUE),
    percent = SLA/Closed * 100,
    .groups = "drop"
  )


unique(df$Domain)
