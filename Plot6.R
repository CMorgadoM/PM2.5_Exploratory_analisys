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

# Plot 6 - Emissions from coal mothor vehicle sources, Baltimore City VS Los Angeles City ####
### wrangle data
grep("[Vv]ehicle|[Ee]ngine|Aircraft|Marine Vessels", SCC$SCC.Level.Two)
#all vehicles, engines, airplanes and vessels are considered as motor vehicles

SCC1 <- filter(SCC, grepl("[Vv]ehicle|[Ee]ngine|Aircraft|Marine Vessels", SCC.Level.Two))
SCCvec <- as.character(SCC1$SCC)

vehicle_data <- data.frame(fips=NA, SCC=NA, Pollutant=NA, Emissions=NA, type=NA, year=NA) #this na values will be removed later


balt_data <- filter(pm2.5data, fips == "24510")
LA_data <- filter(pm2.5data, fips == "06037")

for(i in 1:length(SCCvec)){
    vehicle_data <- rbind(vehicle_data, filter(balt_data, SCC==SCCvec[i])) 
}

vehicle_data <- vehicle_data[2:1428,] #remove the na value in the first row

for(i in 1:length(SCCvec)){
    vehicle_data <- rbind(vehicle_data, filter(LA_data, SCC==SCCvec[i])) 
}

v_data <- vehicle_data %>% 
    group_by(year, fips) %>% 
    summarise(emissions = sum(Emissions))

for(i in 1:nrow(v_data)){
    if(v_data[i,2]=="06037"){
        v_data[i,2]<-"Los Angeles"
    } else {v_data[i,2] <- "Baltimore"}
}
#Ploting the results
png("Plot6.png")
ggplot(v_data, aes(year, emissions))+
    geom_line(color="red", lwd=1)+
    geom_point(color="red",size=2)+
    geom_smooth(method = "lm", color="blue", lwd=1.5, se=F)+
    geom_text(label=round(v_data$emissions,0), nudge_y = 1, size=3)+
    facet_grid(.~fips)+
    labs(x="Years", Y="Tons of PM2.5 emissions",
         title = "PM2.5 EMISSIONS COUSED BY VEHICLES OF ALL TYPES IN BALTIMORE AND L.A.",
         subtitle = "L.A. is pollution is higher than Baltimore and shows an upper trend, despite having a low point in 2008. \nWhile Baltimore is less polluted than in 1999, L.A. has had a bigger absolute changes over the years.")
dev.off()
