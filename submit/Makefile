NILCLUSTERING:=../nilclustering
SCORING:=../scoring
PR:=/remote/curtis/bbd/KBP_2014/alignKBs
PRSUFFIX:=.docid_wp14_t_score_beg_end_np.txt.TAC_id_name_type.genericType.WPtoFBType.all.txt

PROPPRSET:=../kbp.dataset.2014-0.5
VPATH=output/ ${NILCLUSTERING}/output/ ${SCORING}/ ${PR}/ ${PROPPRSET}/
TAB=$(shell echo "\t")

# CMU_
QIDKEY=5
QUERYSET=didlist_e87
#eval
SUBMISSIONS=baseline0 baseline1 unsupervised1 semi_supervised1 pageReactor
OUTPUTFILES=$(addsuffix .xml,${SUBMISSIONS}) $(addsuffix .tab,${SUBMISSIONS})


all: output ${OUTPUTFILES}
	mv ${OUTPUTFILES} output/

output:
	mkdir output

pageReactor.xml:${QUERYSET}${PRSUFFIX}
	awk 'BEGIN{FS="\t";\
	print "<?xml version=\"1.0\" encoding=\"utf-8\"?>"; \
	print "<kbpentlink>"\
	}{qid=sprintf("CMUPR%04d",NR);dname=$$1;beg=$$5;end=$$6;np=$$7;\
	print "<query id=\"" qid "\">\n",\
	"<name>" np "</name>\n",\
	"<docid>" dname "</docid>\n",\
	"<beg>" beg "</beg>\n",\
	"<end>" end "</end>\n</query>"}\
	END{print "</kbpentlink>"}' $< |\
	sed 's/&/&amp;/' > $@

pageReactor.tab:${QUERYSET}${PRSUFFIX}
	awk 'BEGIN{FS=OFS="\t"}{qid=sprintf("CMUPR%04d",NR);eid=$$8;t=$$NF;score=$$4;\
	doit=0;\
	if (t=="PERSON") { t="PER"; doit=1; }\
	if (t=="ORGANIZATION") { t="ORG"; doit=1; }\
	if (t=="PLACE") { t="GPE"; doit=1; }\
	if (doit==1) { print qid,eid,t,score}\
	}' $< >$@

%.tab: %.txt ${QUERYSET}.linkid.txt
	sort -k 1b,1 $< | \
	join -it "${TAB}" - $(word 2,$^) | \
	awk 'BEGIN{OFS=FS="\t"}{\
	qid=$$1;eid=toupper($$2);eid2=$$3;type=toupper($$4);score=$$5;\
	print qid,eid,type,score}'|\
	sort -k 1.${QIDKEY}n,1 |\
	sed 's/UKN/NA/' > $@

%.queries_qid_dname_beg_end_np.txt: %.queries_qid_did_sid_beg_end_np_ner.txt documentIdName_dname_did.cfacts
	sort -k 2b,2 $(word 1,$^) -o $(word 1,$^)
	sort -k 3b,3 $(word 2,$^) -o $(word 2,$^)
	join -t "${TAB}" -1 2 -2 3 $^ | \
	awk 'BEGIN{FS=OFS="\t"}\
	{did=$$1;qid=$$2;sid=$$3;beg=$$4;end=$$5;np=$$6;ner=$$7;label=$$8;dname=$$9;\
	print qid,dname,beg,end,np}' | \
	sort -k 1b,1 > $@

%.xml: %.txt ${QUERYSET}.queries_qid_dname_beg_end_np.txt
	cut -f 1 $< | \
	sort -k 1b,1 | \
	join -it "${TAB}" - ${QUERYSET}.queries_qid_dname_beg_end_np.txt | \
	awk 'BEGIN{FS="\t"; \
	print "<?xml version=\"1.0\" encoding=\"utf-8\"?>"; \
	print "<kbpentlink>"\
	}{\
	qid=$$1;dname=$$2;beg=$$3;end=$$4;np=$$5;\
	print "<query id=\"" qid "\">\n",\
	"<name>" np "</name>\n",\
	"<docid>" dname "</docid>\n",\
	"<beg>" beg "</beg>\n",\
	"<end>" end "</end>\n</query>"}\
	END{print "</kbpentlink>"}' |\
	sed 's/&/&amp;/' > $@
