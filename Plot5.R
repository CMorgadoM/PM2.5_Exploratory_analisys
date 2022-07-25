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

# Plot 5 - Emissions from coal mothor vehicle sources in Baltimore City ####
### wrangle data
grep("[Vv]ehicle|[Ee]ngine|Aircraft|Marine Vessels", SCC$SCC.Level.Two)
#all vehicles, engines, airplanes and vessels are considered as motor vehicles

SCC1 <- filter(SCC, grepl("[Vv]ehicle|[Ee]ngine|Aircraft|Marine Vessels", SCC.Level.Two))
SCCvec <- as.character(SCC1$SCC)

vehicle_data <- data.frame(fips=NA, SCC=NA, Pollutant=NA, Emissions=NA, type=NA, year=NA) #this na values will be removed later


balt_data <- filter(pm2.5data, fips == "24510")



for(i in 1:length(SCCvec)){
    vehicle_data <- rbind(vehicle_data, filter(balt_data, SCC==SCCvec[i])) 
}

vehicle_data <- vehicle_data[2:1428,] #remove the na value in the first row

v_data <- vehicle_data %>% 
    group_by(year) %>% 
    summarise(emissions = sum(Emissions)/100)
#Ploting the results
png("Plot5.png")
ggplot(v_data, aes(year, emissions))+
    geom_line(color="red", lwd=1)+
    geom_point(color="red",size=2)+
    geom_smooth(method = "lm", color="blue", lwd=1.5, se=F)+
    geom_text(label=round(v_data$emissions, 2), nudge_y = 1, size=3)+
    labs(x="Years", y="Tons of PM2.5 emissions(/100)", 
         title = "CHANGE OF PM2.5 EMISSIONS FROM MOTOR VEHICLE SOURCES IN BALTIMORE CITY",
         subtitle = "Even with a large reduction between 1999 and 2002, we can observe an increase of the emissions on 2008")
dev.off()
