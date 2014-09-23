
TAB:=$(shell echo "\t")

all: kbp_train.1.bigrams

STATIC: kbp_train.edges kbp_train.1.edges


# query__bid abfeature aid alab
%.ab: %.edges
	cut -f 1,2,3,4,5 $^ | \
	awk 'BEGIN{FS=OFS="\t"}{print $$1 "__" $$4, $$2,$$3,$$5}' | \
	sort -k 1b,1 -T sort > $@

# query__bid bcfeature cid blab clab
%.bc: %.edges
	awk 'BEGIN{FS=OFS="\t"}{print $$1 "__" $$3, $$2,$$4,$$5,$$6}' $< | \
	sort -k 1b,1 -T sort > $@

%.bigrams: %.ab %.bc
	join -t "$(TAB)" $^ | \
	sed 's/__/\t/' | \
	awk 'BEGIN{FS=OFS="\t"} \
	{b=$$2; query=$$1; ab=$$3; a=$$4; alab=$$5; bc=$$6; c=$$7; blab=$$8; clab=$$9; \
	print query,ab,bc,a,b,c,alab,blab,clab}' > $@

# query feature srcid dstid src dst
#%.edges: %.examples.cooked %.examples.graphKey
#	./listEdges.pl $^ > $@

