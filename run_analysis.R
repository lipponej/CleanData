
runAnalysis <- function() {
    analysisColumnNames = read.csv(header=FALSE, file="UCI HAR Dataset//features.txt", sep="")
    combinedResults = combineResults(analysisColumnNames=analysisColumnNames)
    combinedResults = setActivityLabels(dataset = combinedResults)
    filteredResults = filterColumns(dataset=combinedResults, analysisColumnNames=analysisColumnNames)
    meanResults = columnMeansForActivityAndSubject(dataset=filteredResults)
    result = t(meanResults)
    write.table(result, row.names=FALSE, file="tidyData.txt")
    return(result)
}

columnMeansForActivityAndSubject <- function(dataset) {
    activitiesAndSubjects = unique(subset(dataset, select=c("activityLabels", "subject")))
    columnMeans = mapply(function(x,y) {
        columnMeans = colMeans(dataset[dataset$activityLabels == x & dataset$subject == y, 1:(length(colnames(dataset))-2)])
        columnMeans = c(columnMeans, "activityLabel"=x)
        columnMeans = c(columnMeans, "subject"=y)
        return(columnMeans)
    },
    activitiesAndSubjects$activityLabels,
    activitiesAndSubjects$subject
    )
    return(columnMeans)
}

filterColumns <- function(dataset, analysisColumnNames) {
    filteredColumnNames = analysisColumnNames[grep("*mean\\(\\)*|*std\\(\\)*",analysisColumnNames$V2),2]
    return(subset(dataset, select=c(as.character(filteredColumnNames),"activityLabels","subject")))
}

setActivityLabels <- function(dataset) {
    activityLabels = read.csv(header=FALSE, file="UCI HAR Dataset//activity_labels.txt", sep="")
    colnames(activityLabels) = c("activity", "activityLabels")
    return(merge(dataset,activityLabels,by.x="activity"))
}

combineResults <- function(analysisColumnNames) {
    test_set = loadAndCombineFiles(analysisFile = "UCI HAR Dataset//test//X_test.txt", activityFile = "UCI HAR Dataset//test//y_test.txt",
                                   subjectFile = "UCI HAR Dataset//test//subject_test.txt",
                                   analysisColumnNames = analysisColumnNames)
    train_set = loadAndCombineFiles(analysisFile = "UCI HAR Dataset//train//X_train.txt", activityFile = "UCI HAR Dataset//train//y_train.txt",
                                    subjectFile = "UCI HAR Dataset//train//subject_train.txt",
                                    analysisColumnNames = analysisColumnNames)
    nextRowNameId = nrow(test_set)+1
    row.names(train_set) = nextRowNameId:(nrow(train_set)+nextRowNameId-1)
    return(rbind(test_set, train_set))
}

loadAndCombineFiles <- function(analysisFile, activityFile, subjectFile, analysisColumnNames) {
    analysis = read.csv(file = analysisFile, header = FALSE, sep="")
    analysis = addColumnNames(addColumns=analysis, newColumnsNames = c(as.character(analysisColumnNames$V2)))
    activity = read.csv(file = activityFile, header = FALSE, sep="")
    activity = addColumnNames(activity, c("activity"))
    subjectFile = read.csv(file = subjectFile, header = FALSE, sep="")
    subjectFile = addColumnNames(subjectFile, c("subject"))
    return(cbind(analysis,activity,subjectFile))
}

addColumnNames <- function(addColumns, newColumnsNames) {
    colnames(addColumns) = newColumnsNames
    return(addColumns)
}

runAnalysis()

