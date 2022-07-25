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


# Plot 1 - Total emisions from all sources per year ####
### wrangle data
library(dplyr)
Total_Emissions <- pm2.5data %>% 
    group_by(year) %>% 
    summarise(total_emissions = sum(Emissions)/1000000)
### ploting the results
png("Plot1.png")
with(Total_Emissions, plot(year, total_emissions, col="red", type="l", lwd=3, 
                           ylim=c(2,8), xlab="Years", ylab="Millions of tons of PM2.5 emited",
                           main="MILLIONS OF TONS OF PM2.5 EMITED PER YEAR IN THE USA",
                           sub="There is a negative trend, indicating less emissions trough the years"))
abline(lm(total_emissions~year, Total_Emissions), lwd=3, lty=9, col="blue")
text(Total_Emissions$year, Total_Emissions$total_emissions, labels=round(Total_Emissions$total_emissions, 2), pos=1)
legend("topright",pch=16, col=c("red" , "blue"), legend=c("Millions of Tons", "Trend"))
dev.off()



