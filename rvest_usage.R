# Getting Tiger beetle data off of the USGS site.
library(rvest)
# Making a county master list
cty_list<-matrix(rep(0),1,2,dimnames=list(c(1),c("State","County"))) # matrix (numbers,NumRows,NumCols)
cty_list<-cty_list[-1,]

# County lists for each state
i=1
for (i in 1:length(states[,1])) {
  cty <- html(paste0("http://www.npwrc.usgs.gov/resource/distr/insects/tigb/chklist/states/",tolower(states[i,]),".htm")) %>%
    html_nodes("nobr") %>%
    html_text()
  cty1 <- cbind(rep(as.character(states[i,]),length(cty)),cty)
  cty_list<-rbind(cty_list,cty1)
  print(cty_list)
  i=i+1
}
cty_list<-rbind(cty_list,as.matrix(ky)) # For some reason, Kentucky won't compile (they made it with a slightly different coding)
rownames(cty_list)<-c(1:3159)
cty_list<-as.data.frame(cty_list) # To deal with the annoying fact that Kentucky won't compile


# cty_list is a list of counties with their respective states present
# Every species of tiger beetle for which there is some data (made the names have parentheses around them)
cic<-html("http://www.npwrc.usgs.gov/resource/distr/insects/tigb/usa/cicindel.htm") %>%
  html_nodes("i") %>%
  html_text()

a<-matrix(0,1,97,dimnames=list(c(1),cic[,1])) # a species matrix, currently empty
a<-a[-1,]
a<-as.data.frame(a)
# Scraping the data from each county checklist
i=1
j=1
t=1
for (i in 1:length(states[,1])) {
  for (j in 1:(sum(cty_list[,1]==states[i,1]))) {
    
    spp1<- html_session(paste0("http://www.npwrc.usgs.gov/resource/distr/insects/tigb/chklist/states/",tolower(states[i,]),".htm")) %>%
      follow_link(as.character(cty_list[t,2])) %>%
      html_nodes("i") %>%
      html_text()
    spp2<-as.numeric(cic[,1] %in% spp1)
    a <- rbind(a,spp2)
    t = t+1
    j = j+1
  }
j = 1
i = i+1
} # This for loop takes 40 minutes to complete, so grab a snack and bunker down.
colnames(a)<-cic[,1] # The matrix lost it's header, for some reason
spp<-cbind(cty_list,a) # Shiny new abundance table

