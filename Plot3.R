# Download and charge data ####
urlzip <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
destino <- paste(getwd(), "/data.zip", sep = "")
download.file(urlzip, destino)
unzip(destino)
list.files()

pm2.5data <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

str(pm2.5data) 
summary(pm2.5data)
sum(is.na(pm2.5data$Emissions)) # no missing data

# Plot 3 - Total emisions per year and type in the baltimore city ####
### wrangle data
library(dplyr)
library(ggplot2)
balt_data2 <- pm2.5data %>% 
    filter(fips=="24510") %>% 
    group_by(year, type) %>% 
    summarise(Total_tipe = sum(Emissions))
### Ploting the results
png("Plot3.png")
ggplot(balt_data2, aes(year, Total_tipe))+
    geom_col(aes(fill=type))+
    geom_text(label=balt_data2$year, nudge_y = 100, size=3)+
    facet_grid(.~type)+
    geom_smooth(method = "lm", se=F)+
    labs(x="Years", y="PM2.5 emissions (Tons)", title = "PM2.5 EMISSIONS PER YEAR AND TYPE OF SOURCE", 
         subtitle = "Non-road, nonpoint and on-road are deminishing trough the years, while point is increasing its emissions")
dev.off()
     
    