include Makefile.in
NILCLUSTERING:=../nilclustering
#SCORING:=../scoring
#PR:=/remote/curtis/bbd/KBP_2014/alignKBs
#PRSUFFIX:=.docid_wp14_t_score_beg_end_np.txt.TAC_id_name_type.genericType.WPtoFBType.v2.all.txt

PROPPRSET:=../kbp.dataset.2014-eval
#../kbp.dataset.2014-e54.eval

VPATH=output/ ${PROPPRSET}/nilclustering-output
vpath %.scoredResults.txt ${PROPPRSET}/proppr-output
TAB=$(shell echo "\t")

# CMU_
QIDKEY=5
QUERYSET=didlist_e87
#didlist_e54_v11
#eval

OUTPUTFILES=$(addsuffix .xml,${SUBMISSIONS}) $(addsuffix .tab,${SUBMISSIONS})


all: output ${OUTPUTFILES}
	LOCAL="$(filter-out output output%,$?)"; \
	if [ -n "$$LOCAL" ]; then mv $$LOCAL output/; fi

TEAM=DharpaBums
package: ${OUTPUTFILES}
	rm -rf package
	mkdir package
	K=1;\
	for f in $(SUBMISSIONS); \
	do \
	mv output/$$f.tab $(TEAM)$${K}_links.tab ;\
	mv output/$$f.xml $(TEAM)$${K}_queries.xml ;\
	tar -cf $(TEAM)$${K}.tar $(TEAM)$${K}* ;\
	mv $(TEAM)$${K}.tar package ;\
	mv $(TEAM)$${K}_links.tab output/$$f.tab ;\
	mv $(TEAM)$${K}_queries.xml output/$$f.xml ;\
	K=$$((K+1)) ;\
	done

output:
	mkdir output

pagereactor.xml:pagereactor0.data
	awk 'BEGIN{FS="\t";\
	print "<?xml version=\"1.0\" encoding=\"utf-8\"?>"; \
	print "<kbpentlink>"\
	}{qid=toupper($$2);dname=$$3;beg=$$6;end=$$7;np=$$8;\
	print "<query id=\"EL14_ENG_" qid "\">\n",\
	"<name>" np "</name>\n",\
	"<docid>" dname "</docid>\n",\
	"<beg>" beg "</beg>\n",\
	"<end>" end-1 "</end>\n</query>"}\
	END{print "</kbpentlink>"}' $< |\
	sed 's/&/&amp;/' > $@

pagereactor.tab:pagereactor0.txt
	awk 'BEGIN{FS=OFS="\t"}{qid=$$1;eid=$$5;score=$$6;t=$$7;\
	print "EL14_ENG_" toupper(qid),eid,t,sprintf("%0.10f",score)\
	}' $< >$@


#limited.%.tab: limited.%.txt ${PROPPRSET}.limited/proppr-output/${QUERYSET}.scoredResults.txt
limited.%.tab: limited.%.txt limited.${QUERYSET}.scoredResults.txt
	sort -k 1b,1 $< | \
	join -it "${TAB}" - $(word 2,$^) | \
	awk 'BEGIN{OFS=FS="\t"}{\
	qid=toupper($$1);eid=toupper($$2);eid2=$$4;type=toupper($$5);score=$$3;\
	print "EL14_ENG_" qid,eid,type,sprintf("%0.10f",score)}'|\
	sort -k 1.${QIDKEY}n,1 |\
	sed 's/UKN/NA/' > $@

%.tab: %.txt ${QUERYSET}.scoredResults.txt
	sort -k 1b,1 $< | \
	join -it "${TAB}" - $(word 2,$^) | \
	awk 'BEGIN{OFS=FS="\t"}{\
	qid=toupper($$1);eid=toupper($$2);eid2=$$4;type=toupper($$5);score=$$3;\
	print "EL14_ENG_" qid,eid,type,sprintf("%0.10f",score)}'|\
	sort -k 1.${QIDKEY}n,1 |\
	sed 's/UKN/NA/' > $@

#%.queries_qid_dname_beg_end_np.txt:: %.queries_qid_did_sid_beg_end_np_ner.txt documentIdName_dname_did.cfacts
#	sort -k 2b,2 $(word 1,$^) -o $(word 1,$^)
#	sort -k 3b,3 $(word 2,$^) -o $(word 2,$^)
#	join -t "${TAB}" -1 2 -2 3 $^ | \
#	awk 'BEGIN{FS=OFS="\t"}\
#	{did=$$1;qid=$$2;sid=$$3;beg=$$4;end=$$5;np=$$6;ner=$$7;label=$$8;dname=$$9;\
#	print qid,dname,beg,end,np}' | \
#	sort -k 1b,1 > $@

%.xml: %.txt ${QUERYSET}.queries_qid_dname_sid_beg_end_np_ner.txt
	cut -f 1 $< | \
	sort -k 1b,1 | \
	join -it "${TAB}" - $(word 2,$^) | \
	awk 'BEGIN{FS="\t"; \
	print "<?xml version=\"1.0\" encoding=\"utf-8\"?>"; \
	print "<kbpentlink>"\
	}{\
	qid=toupper($$1);dname=$$2;beg=$$4;end=$$5;np=$$6;\
	print "<query id=\"EL14_ENG_" qid "\">\n",\
	"<name>" np "</name>\n",\
	"<docid>" dname "</docid>\n",\
	"<beg>" beg "</beg>\n",\
	"<end>" end-1 "</end>\n</query>"}\
	END{print "</kbpentlink>"}' |\
	sed 's/&/&amp;/' > $@
