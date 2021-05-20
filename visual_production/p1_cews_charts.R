library(tidyverse)
library(here)
library(ggtext)
library(extrafont)
library(showtext)

# theme
theme_rr_min <-
  function(base_size = 18,
           family = "Libre Franklin",
           legend = 'none') {
    theme_minimal() %+replace%
      theme(
        text = element_text(size = base_size, family = family),
        axis.text = element_text(size = base_size - 1.5),
        plot.title = element_markdown(
          size = base_size + 4,
          hjust = 0,
          family = 'montserrat',
          face = 'bold',
          margin = margin(b = 8)
        ),
        plot.subtitle = element_markdown(
          size = base_size,
          hjust = 0,
          family = 'montserrat',
          margin = margin(b = 10)
        ),
        plot.title.position = 'plot',
        plot.caption = element_text(family = 'Libre Franklin',
                                    size = base_size - 8, 
                                    face = 'italic', 
                                    hjust = 1, 
                                    margin = margin(t = 10)),
        panel.grid.minor = element_blank(),
        legend.position = legend,
      )
  }

palette_a <- c("#b7a4d6","#8f1f3f","#c73200","#de860b","#d4ae0b")

extrafont::loadfonts(device="win", quiet = TRUE)
font_add(family = "Libre Franklin", 
         regular = "C:/Users/Ryan/Documents/Fonts/Libre_Franklin/static/LibreFranklin-Regular.ttf",
         bold = "C:/Users/Ryan/Documents/Fonts/Libre_Franklin/static/LibreFranklin-SemiBold.ttf")
font_add(family = "Montserrat", regular = "C:/Users/Ryan/Documents/Fonts/Montserrat-Regular.ttf")
showtext.auto()

# Data import
covid_profits <- read_rds(here('static', 'data', 'p1_cews', 'covid_profits.rds')) %>% 
  filter(
    !naics_final %in%
      c(
        'Transportation/warehousing',
        'Finance/insurance',
        'Utilities',
        'Agriculture/forestry/fishery/hunting')
  ) %>% 
  arrange(-net_profits) %>% 
  mutate(naics_final = factor(naics_final), naics_final = fct_inorder(naics_final)) %>% 
  select(-avg_employees) %>% 
  pivot_longer(cols = 2:3) %>% 
  mutate(value = value * 10^-6) %>% 
  mutate(width = rep(c(.9,.5), 9))

covid_profits2 <- read_csv(here('static', 'data', 'p1_cews', 'covid_profits2.csv')) %>% 
  arrange(-value) %>% 
  mutate(value = value * 10^-6)

corp_cews <- read_csv(here('static', 'data', 'p1_cews', 'lobby_corp_div2020.csv')) %>% 
  mutate(
    subsidy = round(subsidy, digits = .01)) %>% 
  filter(subsidy > 9) %>% 
  slice_head(n = 15)

# Covid subsidy versus profits bullet chart - sector level
covid_profit_bars <- covid_profits %>% 
  ggplot(aes(x = fct_rev(naics_final), y = value, fill = name)) +
  geom_col(width = covid_profits$width) +
  geom_text(
    data = covid_profits %>% filter(name == 'subsidy'), 
    aes(label = scales::percent(pct_profits, accuracy = 1L)),
    hjust = -0.25, fontface = 'bold', color = palette_a[2], family = 'Libre Franklin', size = 5) +
  scale_fill_manual(values = c(palette_a[5], palette_a[2])) +
  scale_x_discrete() +
  scale_y_continuous(labels = 
                       scales::unit_format(unit = "B", prefix = "$", scale = 10^-3)) +
  coord_flip() +
  theme_rr_min() +
  theme(panel.grid.major.y = element_blank(),
        legend.position = 'none') +
  labs(y = NULL, x = NULL, caption = 'Data: StatCan') +
  ggtitle(label = "Government subsidies keeping corporate profits on life-support",
          subtitle =
            "<span style='color:#8f1f3f;'>**Canada Emergency Wage Subsidy**</span> versus <span style='color:#d4ae0b;'>**After-tax corporate profits**</span>")

covid_profit_bars

ggsave('./static/img/p1_cews/covid_profit_bar.svg', plot = covid_profit_bars, height = 6.5, width = 10.5, device = 'svg')

# Covid subsidy versus total non-fin profits 
covid_profit_bars_total <- covid_profits2 %>% 
  ggplot(aes(x = fct_rev(industry), y = value, fill = name)) +
  geom_col(width = covid_profits2$width) +
  scale_fill_manual(values = palette_a[c(5,2)]) +
  scale_x_discrete() +
  scale_y_continuous(labels = 
                       scales::unit_format(unit = "B", prefix = "$", scale = 10^-3)) +
  coord_flip() +
  theme_rr_min() +
  theme(panel.grid.major.y = element_blank(),
        legend.position = 'none',
        strip.text.x = element_text(size = 14)) +
  labs(y = NULL, x = NULL)

covid_profit_bars2

ggsave('./static/img/p1_cews/covid_profit_total_bar.svg', plot = covid_profit_bars_total, height = 1.25, width = 10.5, device = 'svg')

# Corporate CEWS recipients cross referenced to natnl lobby registry
corp_cews_text <- corp_cews %>% 
  slice_head(n = 15) %>% 
  ggplot(aes(fct_reorder(corp, subsidy), subsidy)) +
  geom_text(aes(label = scales::dollar(subsidy)), 
                size = 5, fontface = 'bold', color = palette_a[2]) +
  coord_flip() +
  expand_limits(y = c(10^6, 650*10^6)) +
  theme_rr_min() +
  labs(x = NULL, y = NULL, caption = "Data: Office of the Comissioner of Lobbying of Canada") +
  theme(axis.text.x = element_blank(),
        panel.grid.major = element_blank()) +
  ggtitle(label = "Canada's corporate elite feast at the disaster capitalism buffet",
          subtitle = "<span style = 'color:#8f1f3f;'> **Total wage subsidy received in 2020**</span>")

corp_cews_text

sum(corp_cews$subsidy)

ggsave('./static/img/p1_cews/covid_profit_textbar.svg', plot = corp_cews_text, height = 6, width = 10.5, device = 'svg')
