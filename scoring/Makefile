HEAD=kbp
TEST=${HEAD}_test
TRAIN=${HEAD}_train
PAIR=${TEST} ${TRAIN}
SET:=$(addsuffix .trained,${PAIR}) ${PAIR}
DIST=$(addsuffix .results,${PAIR})
ifeq (,$(EXTRACTIONS))
EXTRACTIONS=e54_v11.queries_qid_dname_beg_end_np.txt
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


VPATH = ../ ${DIST} threshold/ $(VERSION)/

all:
	@echo "specify _.run"

threshold:  $(addsuffix .t_$(THRESHOLD).scoredResults.txt,${SET})
	mkdir -p threshold
	mv ${TEST}*.scoredResults.txt threshold
	mv ${TRAIN}*.scoredResults.txt threshold
	touch $@

results: $(addsuffix .t_$(THRESHOLD).results.txt,${SET})
	mkdir -p ${DIST}
	mv ${TEST}*.results.txt ${TEST}.results
	mv ${TRAIN}*.results.txt ${TRAIN}.results
	touch $@

%.t_$(THRESHOLD).results.txt: %.solutions.txt
	grep "^[12#]\s" $< | \
	./solutions2results.pl $(THRESHOLD) | \
	sort -k 1b,1> $@
#	mv $@ $*.t_$(THRESHOLD).results.txt

%.t_$(THRESHOLD).scoredResults.txt: %.solutions.txt
	grep "^[12#]\s" $< | \
	./solutions2scoredresults.pl $(THRESHOLD) | \
	sort -k 1b,1> $@
#	mv $@ $*.t_$(THRESHOLD).scoredResults.txt

neleval: $(addsuffix .t_$(THRESHOLD).combined.tab,${SET})
	touch $@

ifeq (e54_v11.queries_qid_dname_beg_end_np.txt,${EXTRACTIONS})
%.t_$(THRESHOLD).combined.tab: %.t_$(THRESHOLD).scoredResults.txt
	join -it "$(T)" ${EXTRACTIONS} $< | \
	join -ia 1 -t "$(T)" - queryNer_qid_ner.cfacts | \
	awk 'BEGIN{FS=OFS="\t";N=1}{sub("e","E",$$7); \
	type=$$8; if (type=="") { type="NA"; } \
	if ($$7=="nil") { $$7="NIL" sprintf("%04d",N); N=N+1; } \
	print $$2,$$3,$$4${OFFSETBUG},$$7,$$6,type}' | \
	sort -k 1b,1 > $@
else
%.t_$(THRESHOLD).combined.tab: %.t_$(THRESHOLD).scoredResults.txt
	join -ia 2 -t "$(T)" ${EXTRACTIONS} $< | \
	awk 'BEGIN{FS=OFS="\t";N=1}{sub("e","E",$$9); \
	type=$$7; if (type=="") { type="NA"; } \
	if ($$9=="nil") { $$9="NIL" sprintf("%04d",N); N=N+1; } \
	print $$2,$$4,$$5${OFFSETBUG},$$9,$$8,type}' | \
	sort -k 1b,1 > $@
endif


#evaluation: $(addsuffix .evaluation,${SET})

#evaluation: $(addsuffix .evaluation,$(basename $(basename $(wildcard 0.4/*.combined.tab)))))

evaluation: $(addsuffix .evaluation,$(basename $(basename $(wildcard $(VERSION)/*.combined.tab))))
	touch evaluation

MEASURES:=tac -m sets-micro:is_linked:span+type+kbid
%.evaluation: %.combined.tab
	cd ../neleval; \
	./nel evaluate -m $(MEASURES) -f tab \
	-g ../scoring/gold/$(notdir $(basename $(basename $(basename $*)))).combined.tab \
	../scoring/$< > ../scoring/$@
