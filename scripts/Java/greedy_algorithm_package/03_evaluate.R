#!/usr/bin/env Rscript

library(ggplot2)
#set.seed(0)

sam = as.matrix(read.table('01_data1.sam'))
ran = as.matrix(read.table('02_solutions.txt.rand', skip=1))
sol = as.matrix(read.table('02_solutions.txt', skip=1))

## PER individual
accu.ran = c()
accu.sol = c()
for (i in 1:1000) {
    accu.ran = c(accu.ran, mean(ran[i,] == sam))
    accu.sol = c(accu.sol, mean(sol[i,] == sam))
}
cat(mean(accu.ran), '\n')
cat(mean(accu.sol), '\n')

names = c(rep("Random", 1000), rep("Greedy", 1000))
value = c(accu.ran, accu.sol)
data = data.frame(names, value)
png("3_evaluate.png", width=4, height=4.5, pointsize=10, units="in", res=200)
boxplot(data$value ~ data$names, col=terrain.colors(4), ylab="Per-individual accuracy")
mylevels=levels(data$names)
levelProportions=summary(data$names)/nrow(data)
for(i in 1:length(mylevels)) {
    thislevel=mylevels[i]
    thisvalues=data[data$names==thislevel, "value"]
    myjitter=jitter(rep(i, length(thisvalues)), amount=levelProportions[i]/2)
    points(myjitter, thisvalues, pch=20, col=rgb(0,0,0,.2))
}
dev.off()
t.test(accu.ran, accu.sol)

## PER SNP
accu.ran = c()
accu.sol = c()
for (i in 1:1000) {
    accu.ran = c(accu.ran, mean(ran[,i] == sam[i]))
    accu.sol = c(accu.sol, mean(sol[,i] == sam[i]))
}
cat(mean(accu.ran), '\n')
cat(mean(accu.sol), '\n')

names = c(rep("Random", 1000), rep("Greedy", 1000))
value = c(accu.ran, accu.sol)
data = data.frame(names, value)
png("3_evaluate_perSNP.png", width=4, height=4.5, pointsize=10, units="in", res=200)
boxplot(data$value ~ data$names, col=terrain.colors(4), ylab="Per-SNP accuracy")
mylevels=levels(data$names)
levelProportions=summary(data$names)/nrow(data)
for(i in 1:length(mylevels)) {
    thislevel=mylevels[i]
    thisvalues=data[data$names==thislevel, "value"]
    myjitter=jitter(rep(i, length(thisvalues)), amount=levelProportions[i]/2)
    points(myjitter, thisvalues, pch=20, col=rgb(0,0,0,.2))
}
dev.off()
t.test(accu.ran, accu.sol)

## Risk score 
err.ran = c()
err.sol = c()
weight = runif(1000)
weight = weight / sum(weight)
truerisk = sam %*% weight
err.ran = (ran %*% weight) 
err.sol = (sol %*% weight) 
names = c(rep("Random", length(err.ran)), rep("Greedy", length(err.sol)))
value = c(err.ran, err.sol)
data = data.frame(names, value)
png("3_evaluate_riskscore.png", width=4, height=4.5, pointsize=10, units="in", res=200)
boxplot(data$value ~ data$names, col=terrain.colors(4), ylab="Risk score")
mylevels=levels(data$names)
levelProportions=summary(data$names)/nrow(data)
for(i in 1:length(mylevels)) {
    thislevel=mylevels[i]
    thisvalues=data[data$names==thislevel, "value"]
    myjitter=jitter(rep(i, length(thisvalues)), amount=levelProportions[i]/2)
    points(myjitter, thisvalues, pch=20, col=rgb(0,0,0,.2))
}
abline(h=truerisk, col="blue", lty=2, lwd=1)
dev.off()
t.test(err.ran, err.sol)
