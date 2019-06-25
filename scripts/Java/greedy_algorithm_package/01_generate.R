#!/usr/bin/env Rscript

minMAF=0.3
nsnp=1000
nref=30

args = commandArgs(trailingOnly=TRUE)
pref = args[1]

ref=matrix(NA, nrow=nref, ncol=nsnp)
sam=matrix(NA, 1, nsnp)
af=runif(nsnp, min=minMAF, max=1-minMAF)
for (j in 1:nsnp) {
    ref[,j]=rbinom(nref,2,af[j])
    sam[,j]=rbinom(1,2,af[j])
}

dv=sapply(1:nref, function(x) sum((ref[x,]-sam)^2))

# write to file
write.table(sam, file=paste(pref,'.sam',sep=""), row.names=F, col.names=F)
write.table(ref, file=paste(pref,'.ref',sep=''), row.names=F, col.names=F)
write.table(af, file=paste(pref,'.af',sep=''), row.names=F, col.names=F)
write.table(dv, file=paste(pref,'.dv',sep=''), row.names=F, col.names=F)

