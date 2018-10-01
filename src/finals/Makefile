lslfiles := $(wildcard *.lsl)
linkfiles := $(lslfiles:%.lsl=./links/%.lsl)
tmpfiles := $(wildcard /tmp/*.lsl)
lslint := $(shell command -v lslint 2> /dev/null)
highlighting := while read line; do \
		  echo $$line | grep ERROR > /dev/null \
		  && echo -e "\e[91m$$line\e[0m" \
		  || echo $$line | grep WARN > /dev/null \
		  && echo -e "$$line" \
		  || echo -e "\e[90m$$line\e[0m"; \
		done;

.PHONY: link clean all release check

all : link $(linkfiles)
	@echo -e "\e[92mFinished build...\e[0m";

release : debfilter = | grep -v llOwnerSay\(\"DEBUG
release : link $(linkfiles)
	@echo -e "\e[92mFinished build release...\e[0m";

./links/%.lsl : %.lsl
ifdef lslint
	@echo -e "\e[96mSyntaxcheck with lslint...\n\e[93m$<\e[0m";
	@lslint $< 2>&1 | \
	$(highlighting)
endif
	@echo -e "\e[96mUploading file...\e[0m";
	cat $< $(debfilter) > $@

check :
ifdef lslint
	@echo -e "\e[96mSyntaxcheck with lslint...\e[0m";
	@for script in $(lslfiles); do \
	  echo -e "\e[93m$$script\e[0m"; \
	  lslint $$script 2>&1 | \
	  $(highlighting) \
	done;
else
	@echo -e "\e[96mNeed  lslint for this, check out http://w-hat.com/#lslint...\e[0m";
endif

link :
	@echo -e "\e[96mLinking lsl files from /tmp/...\e[0m";
	@[ -d links ] || mkdir links;
	@for script in $(tmpfiles); do \
	  ln -sf $$script ./links/`grep '//### ' $$script | sed 's/\/\/### //g' | head -1`; \
	done;

clean : 
	rm ./links/*.lsl
