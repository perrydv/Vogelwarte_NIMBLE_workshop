drawGraph <- function(model, colorBy = "none", colors = c('salmon','cyan','plum')) {
    if(!require(igraph)) stop("igraph library is not installed.")
    graph <- model$getGraph()
    numNodes <- length(model$getNodeNames())
    vertex.color <- rep('grey', numNodes)
    if(length(colorBy) == 1 &
       colorBy[1] %in% c("none", "stochDetermData", "topLatentEnd")) {
        if(identical(colorBy, "none")) {}
        else if(colorBy == "stochDetermData") {
            stochIDs <- model$getNodeNames(stochOnly = TRUE, returnType = "ids")
            determIDs <- model$getNodeNames(determOnly = TRUE, returnType = "ids")
            dataIDs <- model$getNodeNames(dataOnly = TRUE, returnType = "ids")
            vertex.color[stochIDs] <- colors[1]
            vertex.color[determIDs] <- colors[2]
            vertex.color[dataIDs] <- colors[3]
        } else if(colorBy == "topLatentEnd") {
            topIDs <- model$getNodeNames(topOnly=TRUE, returnType = "ids")
            latentIDs <- model$getNodeNames(latentOnly=TRUE, returnType = "ids")
            endIDs <- model$getNodeNames(endOnly=TRUE, returnType = "ids")
            vertex.color[topIDs] <- colors[1]
            vertex.color[latentIDs] <- colors[2]
            vertex.color[endIDs] <- colors[3]
        }
    } else if(length(colorBy) > 0) {
        if(is.character(colorBy))
            colorBy <- model$expandNodeNames(colorBy, returnType = "ids")
        vertex.color[colorBy] <- colors[1]
    }
    ## if(identical(colorBy, "none")) {}
    ## else if(length(colorBy) > 1) {
    ##     if(is.character(colorBy))
    ##         colorBy <- model$expandNodeNames(colorBy, returnType = "ids")
    ##     vertex.color[colorBy] <- colors[1]
    ## } else if(colorBy == "stochDetermData") {
    ##     stochIDs <- model$getNodeNames(stochOnly = TRUE, returnType = "ids")
    ##     determIDs <- model$getNodeNames(determOnly = TRUE, returnType = "ids")
    ##     dataIDs <- model$getNodeNames(dataOnly = TRUE, returnType = "ids")
    ##     vertex.color[stochIDs] <- colors[1]
    ##     vertex.color[determIDs] <- colors[2]
    ##     vertex.color[dataIDs] <- colors[3]
    ## } else if(colorBy == "topLatentEnd") {
    ##     topIDs <- model$getNodeNames(topOnly=TRUE, returnType = "ids")
    ##     latentIDs <- model$getNodeNames(latentOnly=TRUE, returnType = "ids")
    ##     endIDs <- model$getNodeNames(endOnly=TRUE, returnType = "ids")
    ##     vertex.color[topIDs] <- colors[1]
    ##     vertex.color[latentIDs] <- colors[2]
    ##     vertex.color[endIDs] <- colors[3]
    ## }
    plot(graph, layout = layout_(graph, with_kk()),
         vertex.color = vertex.color ) ## uses plot.igraph
}
