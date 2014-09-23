TRAINTEST=kbp_train kbp_test
PREPOST=${TRAINTEST} $(addsuffix .trained,${TRAINTEST})
SOLUTIONS=$(addsuffix .solutions.txt,${PREPOST})
HR=$(addsuffix .solutions.hr.txt,${PREPOST})

all: ${HR}

%.solutions.hr.txt: %.solutions.txt
	./humanreadable.pl queryName_qid_name.cfacts entityName_name_eid.cfacts $(basename $*).gold_solutions.txt $< > $@