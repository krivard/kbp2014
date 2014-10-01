### SETUP ###
## use this classpath if you have a copy of the proPPR jar and its dependencies all in the same directory
#CP:=.:/home/krivard/lib/proPPR.jar
## use this classpath if you're working from source
PROPPR:=/home/krivard/ProPPR
CP:=.:${PROPPR}/bin:${PROPPR}/lib/*
ifeq (,${DATASET})
DATASET=kbp.dataset.2014-0.7
endif
TRAIN=kbp_train
TEST=kbp_test
PROGRAM=${DATASET}/kbp.crules:${DATASET}/kbp.sparse
#:${DATASET}/kbp.cfacts/entityGivenAnchor_eid_name_p.cfacts:${DATASET}/kbp.cfacts/anchorGivenEntity_eid_name_p.cfacts
JOPTS=-Xmx35G

### PARAMETERS ###
PROVER=dpr:1e-5
THREADS=7
MAXT=13

### TARGETS ###
#VPATH = ${DATASET}

vpath %.cfacts ${DATASET}/kbp.cfacts/
vpath %.queries ${DATASET}
vpath %.txt ${DATASET}


all: test

train:params.wts

%.uinference: %.solutions.txt

%.inference: %.trained.solutions.txt

score: ${TEST}.trained.solutions.ann.tsv ${TEST}.solutions.ann.tsv ${TRAIN}.trained.solutions.ann.tsv 

prescore: ${TEST}.unnorm.solutions.txt ${TRAIN}.unnorm.solutions.txt

examples: ${TRAIN}.examples ${TEST}.examples

#${TRAIN}.examples ${TEST}.examples

%.examples: %.solutions.txt %.answerQuery_did_qid_eid.queries
	./solutions2train.pl ${DATASET}/$*.answerQuery_did_qid_eid.queries $< $*.unreachable $@
#mv $@ ${DATASET}/

%.cooked: %.examples
	java ${JOPTS} -cp ${CP} edu.cmu.ml.praprolog.ExampleCooker --programFiles ${PROGRAM} \
	--data $< --output $@ --graphKey $@.key --prover ${PROVER}

%.unnorm.solutions.txt: %.answerQuery_did_qid_eid.queries
	java ${JOPTS} -cp ${CP} edu.cmu.ml.praprolog.QueryAnswerer --programFiles ${PROGRAM} \
	--queries $< --output $@ --prover ${PROVER} --unnormalized --maxT ${MAXT}

%.solutions.txt: %.answerQuery_did_qid_eid.queries
	java ${JOPTS} -cp ${CP} edu.cmu.ml.praprolog.QueryAnswerer --programFiles ${PROGRAM} \
	--queries $< --output $@ \
	--prover ${PROVER} --maxT ${MAXT}

%.humanreadable.txt: %.humanreadable.queries
	java ${JOPTS} -cp ${CP} edu.cmu.ml.praprolog.QueryAnswerer --programFiles ${PROGRAM} \
	--queries $< --output $@ --prover ${PROVER} --maxT ${MAXT}

%.trained.solutions.txt: %.answerQuery_did_qid_eid.queries params.wts
	java ${JOPTS} -cp ${CP} edu.cmu.ml.praprolog.QueryAnswerer --programFiles ${PROGRAM} \
	--queries $< --output $@ \
	--prover ${PROVER} --maxT ${MAXT} \
	--params params.wts --reranked --trainer mrr --force 

params.wts: ${TRAIN}.examples
ifeq (,$(wildcard ${DATASET}/${TRAIN}.examples.cooked))
	touch dummy
	java ${JOPTS} -cp ${CP} edu.cmu.ml.praprolog.Experiment --programFiles ${PROGRAM} \
	--prover ${PROVER} --train $< --test dummy --output ${DATASET}/${TRAIN}.examples.cooked --params $@ --threads ${THREADS} --maxT ${MAXT}
else
	java ${JOPTS} -cp ${CP} edu.cmu.ml.praprolog.Trainer \
	--prover ${PROVER} --train ${DATASET}/${TRAIN}.examples.cooked --params $@ --threads ${THREADS} --maxT ${MAXT}
endif

pre: ${TRAIN}.examples
	java ${JOPTS} -cp ${CP} edu.cmu.ml.praprolog.Tester --tester rt --programFiles ${PROGRAM} \
	--prover ${PROVER} --test $< --threads ${THREADS}

pretest: ${TEST}.examples
	java ${JOPTS} -cp ${CP} edu.cmu.ml.praprolog.Tester --tester rt --programFiles ${PROGRAM} \
	--prover ${PROVER} --test $< --threads ${THREADS}

post:  ${TRAIN}.examples params.wts
	java ${JOPTS} -cp ${CP} edu.cmu.ml.praprolog.Tester --tester rt --programFiles ${PROGRAM} \
	--prover ${PROVER} --test $< --params params.wts --threads ${THREADS}

test: ${TEST}.examples params.wts
	java ${JOPTS} -cp ${CP} edu.cmu.ml.praprolog.Tester --tester rt --programFiles ${PROGRAM} \
	--prover ${PROVER} --test $<--params params.wts --threads ${THREADS} --force


####### results processing:

TAB:=$(shell echo "\t")


#yields: qid did rank score eid
%.solutions.tsv: %.solutions.txt
	sed 's/-1=c[[]//;s/]//;s/,-1[)]//;s/answerQuery[(]//;s/,/\t/' $< | \
	awk '/#/ {q = $$5 "\t" $$4;} /^[0-9]/ {print q "\t" $$0}' > $@

#yields: qid did rank score eid xtype ntype
%.solutions.ann.tsv: %.solutions.tsv extractedType_qid_t.cfacts entityType_eid_t.cfacts 
	sort -k 1b,1 $(word 1,$^) | \
	join -a 1 -2 2 -t "$(TAB)" - $(word 2,$^) | \
	sort -k 5b,5 | \
	join -a 1 -1 5 -2 2 -t "$(TAB)" - $(word 3,$^) | \
	awk 'BEGIN{FS=OFS="\t"}{nt=$$9; if(nt=="") {nt="na"} print $$2,$$3,$$4,$$5,$$1,$$7,nt}' | \
	sort -k 1b,1 -k 3n,3 > $@
# eid qid did rank score "extractedType" xtype "entityType" ntype

.PRECIOUS: %.solutions.txt %.examples params.wts