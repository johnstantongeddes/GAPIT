`GAPIT.Manhattan` <-
function(GI.MP = NULL, name.of.trait = "Trait", 
                   plot.type = "Genomewise",DPP=50000,cutOff=0.01,band=5){
#Object: Make a Manhattan Plot
#Options for plot.type = "Separate_Graph_for_Each_Chromosome" and "Same_Graph_for_Each_Chromosome" 
#Output: A pdf of the Manhattan Plot
#Authors: Alex Lipka, Zhiwu Zhang, and Meng Li 
# Last update: May 10, 2011 
##############################################################################################

print("Manhattan ploting...")

#do nothing if null input
if(is.null(GI.MP)) return

GI.MP=matrix(as.numeric(as.matrix(GI.MP) ) ,nrow(GI.MP),ncol(GI.MP))

#Remove all SNPs that do not have a choromosome and bp position
GI.MP <- GI.MP[!is.na(GI.MP[,1]),]
GI.MP <- GI.MP[!is.na(GI.MP[,2]),]

#Remove all SNPs that have P values above 0 (not na etc)
GI.MP <- GI.MP[GI.MP[,3]>0,]
numMarker=nrow(GI.MP)
bonferroniCutOff=-log10(cutOff/numMarker)
	
#Replace P the -log10 of the P-values
GI.MP[,3] <-  -log10(GI.MP[,3])
y.lim <- ceiling(max(GI.MP[,3]))
chm.to.analyze <- unique(GI.MP[,1]) 
chm.to.analyze=chm.to.analyze[order(chm.to.analyze)]
numCHR= length(chm.to.analyze)

#Chromosomewise plot
if(plot.type == "Chromosomewise")
{
print("Manhattan ploting Chromosomewise")

  pdf(paste("GAPIT.", name.of.trait,".Manhattan-Plot.Chromosomewise.pdf" ,sep = ""), width = 10)
  par(mar = c(5,5,4,3), lab = c(8,5,7))
  for(i in 1:numCHR)
  {
    #Extract SBP on this chromosome
    subset=GI.MP[GI.MP[,1]==chm.to.analyze[i],]
  	#print(paste("CHR: ",i, " #SNPs: ",length(subset),sep=""))
  	#print(dim(subset))
  	#print((subset))
  	y.lim <- ceiling(max(subset[,3]))  #set upper for each chr
  	
  	if(length(subset)>3){
      x <- as.numeric(subset[,2])/10^(6)
      y <- as.numeric(subset[,3])
    }else{
      x <- as.numeric(subset[2])/10^(6)
      y <- as.numeric(subset[3])
    }
 	  #print(paste("befor prune: chr: ",i, "length: ",length(x),"max p",max(y), "min p",min(y), "max x",max(x), "Min x",min(x)))


        
  	#Prune most non important SNPs off the plots
    order=order(y,decreasing = TRUE)
    y=y[order]
    x=x[order]
    
    index=GAPIT.Pruning(y,DPP=round(DPP/numCHR))
      	
  	x=x[index]
  	y=y[index]

  	
 	  #print(paste("after prune: chr: ",i, "length: ",length(x),"max p",max(y), "min p",min(y), "max x",max(x), "Min x",min(x)))
 	  
    #color.vector <- subset(temp.par.data[,7], temp.par.data[,4] == i)
    plot(y~x,type="p", ylim=c(0,y.lim), xlim = c(min(x), max(x)), col = "navy", xlab = expression(Base~Pairs~(x10^-6)), ylab = "-Log Base 10 p-value", main = paste("Chromosome",chm.to.analyze[i],sep=" "))

abline(h=bonferroniCutOff,col="forestgreen")
  	#print("manhattan plot (chr) finished")    
  }
  dev.off()
  print("manhattan plot on chromosome finished")
} #Chromosomewise plot


#Genomewise plot
if(plot.type == "Genomewise")
{
print("Manhattan ploting Genomewise")

#Set corlos for chromosomes
nchr=max(chm.to.analyze)
ncycle=ceiling(nchr/band)
ncolor=band*ncycle
palette(rainbow(ncolor+1))
cycle1=seq(1,nchr,by= ncycle)
thecolor=cycle1
for(i in 2:ncycle){thecolor=c(thecolor,cycle1+(i-1))}

  
  GI.MP <- GI.MP[order(GI.MP[,2]),]
  GI.MP <- GI.MP[order(GI.MP[,1]),]
  color.vector <- rep(c("orangered","navyblue"),numCHR)
  ticks=NULL
  lastbase=0

#print("Manhattan data sorted")
#print(chm.to.analyze) 

  #change base position to accumulatives
  for (i in chm.to.analyze)
  {
    index=(GI.MP[,1]==i)
    ticks <- c(ticks, lastbase+mean(GI.MP[index,2])) 
    GI.MP[index,2]=GI.MP[index,2]+lastbase
    lastbase=max(GI.MP[index,2])
  }

  #print("Manhattan chr processed")

    x0 <- as.numeric(GI.MP[,2])
    y0 <- as.numeric(GI.MP[,3])
    z0 <- as.numeric(GI.MP[,1])
	position=order(y0,decreasing = TRUE)
    index0=GAPIT.Pruning(y0[position],DPP=DPP)
	index=position[index0]
	x=x0[index]
	y=y0[index]
	z=z0[index]

#Draw circles with same size and different thikness
size=1
ratio=5
base=1
themax=max(y)
themin=min(y)
wd=((y-themin+base)/(themax-themin+base))*size*ratio
s=size-wd/ratio/2

#print("Manhattan XY created")

  pdf(paste("GAPIT.", name.of.trait,".Manhattan-Plot.Genomewise.pdf" ,sep = ""), width = 11,height=5)
  par(mar = c(5,6,5,1))

#plot(y~x,xlab=expression(Chromosome),ylab=expression(-log[10](italic(p))) ,
#       cex.lab=2,col=ifelse(z%%2==0,"orangered","navy"),axes=FALSE,type = "p",pch=20,main = paste(name.of.trait,sep=" "))
#plot(y~x,xlab=expression(Chromosome),ylab=expression(-log[10](italic(p))) ,
#       cex.lab=2,col=thecolor[z],axes=FALSE,type = "p",pch=20,main = paste(name.of.trait,sep=" "))
plot(y~x,xlab=expression(Chromosome),ylab=expression(-log[10](italic(p))) ,
     cex.lab=2,col=thecolor[z],axes=FALSE,type = "p",pch=1,lwd=wd,cex=s,main = paste(name.of.trait,sep=" "))


abline(h=bonferroniCutOff,col="forestgreen")
 
 axis(1, at=ticks,cex.axis=1.5,labels=chm.to.analyze,tick=F)
  axis(2, at=1:y.lim,cex.axis=1.5,labels=1:y.lim,tick=F)
  box()  
  dev.off()
print("Manhattan done Genomewise")
  
} #Genomewise plot

  print("GAPIT.Manhattan accomplished successfully!")
} #end of GAPIT.Manhattan

