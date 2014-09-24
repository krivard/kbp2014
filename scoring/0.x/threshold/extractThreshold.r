data = read.table("kbp_train.t_0.0.rdata",col.names=c("qid","score","eid","g"),as.is=TRUE);
N = length(data$score);
data = data[order(data$score),];
data = data.frame(data,pos=data$eid==data$g,p=0.0,i=1:N);

for (i in 1:(N-1)) {
    correct = sum(data$g[1:i]=="nil") + sum(data$pos[(i+1):N]);
    data$p[i] = correct / N;
}
print(data[data$p == max(data$p),]);