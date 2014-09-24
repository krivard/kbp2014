HEAD=kbp
TEST=${HEAD}_test
TRAIN=${HEAD}_train
PAIR=${TEST} ${TRAIN}
SET:=$(addsuffix .trained,${PAIR}) ${PAIR}
DIST=$(addsuffix .results,${PAIR})
ifeq (,$(EXTRACTIONS))
EXTRACTIONS=didlist_e54_v11.queries_qid_dname_sid_beg_end_np_ner.txt
#e54_v11.queries_qid_dname_beg_end_np.txt
endif
T:=$(shell echo "\t")

ifeq (,$(THRESHOLD))
THRESHOLD=0.028
endif

ifeq (,$(VERSION))
VERSION=0.4
endif

ifeq (,$(OFFSETBUG))
OFFSETBUG=
endif


VPATH = ../ $(VERSION)/

all:
	@echo "specify _.run"

threshold:  $(addsuffix .t_$(THRESHOLD).scoredResults.txt,${SET})
	mkdir -p threshold
	mv ${TEST}*.scoredResults.txt threshold
	mv ${TRAIN}*.scoredResults.txt threshold
	touch $@

#results: $(addsuffix .t_$(THRESHOLD).results.txt,${SET})
#	mkdir -p ${DIST}
#	mv ${TEST}*.results.txt ${TEST}.results
#	mv ${TRAIN}*.results.txt ${TRAIN}.results
#	touch $@

%.t_$(THRESHOLD).scoredResults.txt: %.solutions.ann.tsv
	./ann2matching.pl $< | \
	awk -v thresh=${THRESHOLD} 'BEGIN{FS=OFS="\t"}{eid=$$5; t=$$7; if ($$NF == "FALLBACK" || $$4 < thresh) { eid="nil"; t=$$6; } print $$1,$$4,eid,t }'  | \
	sort -k 1b,1> $@

%.t_$(THRESHOLD).results.txt: %.t_$(THRESHOLD).scoredResults.txt
	cut -f 1,3 $< > $@

neleval: $(addsuffix .t_$(THRESHOLD).combined.tab,${SET})
	touch $@

%.t_$(THRESHOLD).combined.tab: %.t_$(THRESHOLD).scoredResults.txt
	join -ia 2 -t "$(T)" ${EXTRACTIONS} $< | \
	awk 'BEGIN{FS=OFS="\t";N=1}{sub("e","E",$$9); \
	type=$$NF; \
	if ($$9=="nil") { $$9="NIL" sprintf("%04d",N); N=N+1; } \
	print $$2,$$4,$$5${OFFSETBUG},$$9,$$8,toupper(type)}' | \
	sort -k 1b,1 > $@

#evaluation: $(addsuffix .evaluation,${SET})

#evaluation: $(addsuffix .evaluation,$(basename $(basename $(wildcard 0.4/*.combined.tab)))))

evaluation: $(addsuffix .evaluation,$(basename $(basename $(wildcard $(VERSION)/*$(THRESHOLD)*.combined.tab))))
	touch evaluation

MEASURES:=tac -m sets-micro:is_linked:span+type+kbid
%.evaluation: %.combined.tab
	cd ../neleval; \
	./nel evaluate -m $(MEASURES) -f tab \
	-g ../scoring/gold/$(notdir $(basename $(basename $(basename $*)))).combined.tab \
	../scoring/$< > ../scoring/$@

print: evaluation
	for f in `ls $(VERSION)/*$(THRESHOLD)*.evaluation`; do echo $$f; tail -n 9 $$f | cut -f 7,8; done

