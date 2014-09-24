
all: threshold.txt

threshold.txt: kbp_train.t_0.0.rdata
	R --vanilla --silent -f extractThreshold.r | tee $@

kbp_train.t_0.0.rdata: ../kbp_train.t_0.0.scoredResults.txt cmu.gold_solutions.txt
	join $^ > $@