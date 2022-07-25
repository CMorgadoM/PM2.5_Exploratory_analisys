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

# Plot 2 - Total emisions per year in the baltimore city ####
### wrangle data
library(dplyr)
balt_data <- pm2.5data %>% 
    filter(fips=="24510") %>% 
    group_by(year) %>% 
    summarise(emision_balt = sum(Emissions))

# ploting the results
png("Plot2.png")
with(balt_data, plot(year, emision_balt, col="red", type="l", lwd=3, ylim=c(1000, 3600),
                     xlab="Years", ylab="Tons of PM2.5 emited",
                     main="TONS OF PM2.5 EMITED PER YEAR IN BALTIMORE CITY", 
                     sub = "We observe a negative trend, but with a high pick in 2005"))
with(balt_data, abline(lm(emision_balt~year), lwd=3, lty=9, col="blue"))
with(balt_data, text(year, emision_balt, labels=round(balt_data$emision_balt), pos=1))
legend("topright", pch = 16, col=c("blue", "red"), legend=c("Trend", "Tons of PM2.5"))
dev.off()
