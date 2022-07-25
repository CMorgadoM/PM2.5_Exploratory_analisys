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

# Plot 4 - Emissions from coal combustion-related sources  ####
### wrangle data

SCCconcat <- paste(SCC$Short.Name, SCC$EI.Sector, SCC$SCC.Level.One, SCC$SCC.Level.Two, SCC$SCC.Level.Three, SCC$SCC.Level.Four)
SCC3 <- data.frame(SCC=SCC$SCC, Names=SCCconcat) #combine all the descriptions where the word "coal" could be
SCC4 <- filter(SCC3, grepl("[Cc]oal", Names)) #extract all coal-related rows
SCC4 <- filter(SCC4, !grepl("[Cc]harcoal", Names)) #remove the "charcoal" related rows (as it isn't coal)
SCC4vec <- as.character(SCC4$SCC)

#finally extract all the coal-related rows from the main data frame
for(i in 1:nrow(SCC4)){
    Coal_data <- rbind(Coal_data, filter(pm2.5data, SCC==SCC4vec[i])) 
}
Coal_data_sum <- Coal_data %>% 
    group_by(year) %>% 
    summarise(emissions=sum(Emissions)/100000)
# Plot results
png("Plot4.png")
ggplot(Coal_data_sum, aes(year, emissions))+
    geom_line(lwd=0.5, color="red")+
    geom_point(color="red", size=2)+
    geom_smooth(method="lm", color="blue", lty=1, se=F)+
    labs(x="years", y="Tons of PM2.5 emissions(/100.000)", 
         title= "EVOLUTION OF TONS OF PM2.5 EMITTED FROM COAL-RELATED SOURCES",
         subtitle = "The emissions remain partially constant till 2005. After 2005 emissions go down")+
    geom_text(label=round(Coal_data_sum$emissions, 2), nudge_y = 0.1, size=3)
dev.off()



