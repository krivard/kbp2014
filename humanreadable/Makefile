TRAINTEST=kbp_train kbp_test
PREPOST=${TRAINTEST} $(addsuffix .trained,${TRAINTEST})
SOLUTIONS=$(addsuffix .solutions.txt,${PREPOST})
HR=$(addsuffix .solutions.hr.txt,${PREPOST})

vpath %.cfacts ../${DATASET}/kbp.cfacts/
vpath %.solutions.txt ../ ../${DATASET}/

all: ${HR}

%.solutions.hr.txt: %.solutions.txt queryName_qid_name.cfacts entityName_name_eid.cfacts
	./humanreadable.pl $(word 2,$^) $(word 3,$^) $(basename $*).gold_solutions.txt $< > $@