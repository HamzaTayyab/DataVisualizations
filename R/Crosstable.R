Crosstable=CrossTablePlot=function(Data,xbins = seq(0, 100, 5),ybins= xbins,NormalizationFactor=1,PlotIt=TRUE,main='Cross Table',PlotText=TRUE,TextDigits=0,TextProbs=c(0.05,0.95)){
  #Cathing simple errors of DAU
  if(!is.matrix(Data)){
    warning('Data is expected to be a matrix, trying to transform..')
    Data=as.matrix(Data)
  }
  if(is.null(colnames(Data)))
    colnames(Data)=c('X','Y')
  if(length(xbins)!=length(ybins)){
    stop('Length of xbins has to be equal to length of ybins.')
  }
   #interval is left closed and right opend
  aint = findInterval(Data[, 1],
                      ybins,
                      left.open = FALSE,
                      rightmost.closed = FALSE)
  bint = findInterval(Data[, 2],
                      ybins,
                      left.open = FALSE,
                      rightmost.closed = FALSE)
  #Crrection if a bin missing
  u = unique(aint)
  leera = setdiff(1:length(xbins), u)
  u = unique(bint)
  leerb = setdiff(1:length(xbins), u)
  #Fill up also mising bins and create a wide table of frequencies 
  CrossTable = table(c(aint, leera, rep(1, length(leerb))), c(bint, rep(1, length(leera)), leerb))
  #Transform to matrix
  frequency <-  as.matrix(as.data.frame(CrossTable)) #shortcut for transforming into a long table
  mode(frequency)='numeric'
  
  #Correction: set missing bins to zero
  for (i in 1:length(leera)) {
    frequency[frequency[, 1] == leera[i], 3] = 0
  }
  for (i in 1:length(leerb)) {
    frequency[frequency[, 2] == leerb[i], 3] = 0
  }
  #FillUp
  frequency2D = diag(length(xbins)) * 0
  frequency2D[cbind(frequency[, 1], frequency[, 2])] = frequency[, 3] / NormalizationFactor
  
  if (PlotIt) {
    hx <- hist(Data[,1], breaks=xbins, plot=F)
    hy <- hist(Data[,2], breaks=ybins, plot=F)
    top <- max(hx$counts, hy$counts)
    cols = DataVisualizations::HeatmapColors
    widthx = abs(xbins[2] - xbins[1])
    widthy = abs(ybins[2] - ybins[1])
    
    oldpar <- par()
    par(mar=c(4,4,1,1))
 
    layout(matrix(c(2,0,1,3),2,2,byrow=T),c(3,1), c(1,3))
    image(
      xbins,
      ybins,
      frequency2D,
      xlab = colnames(Data)[1],
      ylab = colnames(Data)[2],
      col = cols
    )
    
    if(PlotText){
      freqxy=round(frequency[, 3] / NormalizationFactor, digits = TextDigits)
      qq=quantile(freqxy,probs = TextProbs)
      ind1=which(freqxy<=qq[1])
      ind2=which(freqxy>qq[1]&freqxy<=qq[2])
      ind3=which(freqxy>qq[2])
      text(
        frequency[ind1, 1] * widthx - widthx ,
        frequency[ind1, 2] * widthy - widthy ,
        labels = freqxy[ind1],
        col ='white' 
      )
      if(length(ind2)>0)
        text(
          frequency[ind2, 1] * widthx - widthx ,
          frequency[ind2, 2] * widthy - widthy ,
          labels = freqxy[ind2],
          col ='grey' 
        )
      text(
        frequency[ind3, 1] * widthx - widthx ,
        frequency[ind3, 2] * widthy - widthy ,
        labels = freqxy[ind3],
        col ='black' 
      )
    }
    par(mar=c(0,3,1,0))
    barplot(hx$counts, axes=F, ylim=c(0, top), space=0, col='blue')
    par(mar=c(3,0,0.5,1))
    barplot(hy$counts, axes=F, xlim=c(0, top), space=0, col='blue', horiz=T)
    title(main,outer = T,line = -2)
  }
  rownames(CrossTable)=xbins
  colnames(CrossTable)=ybins
  CrossTable=t(CrossTable)#defined as in plot
  return(invisible(CrossTable / NormalizationFactor))
}