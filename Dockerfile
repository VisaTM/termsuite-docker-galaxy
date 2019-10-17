
FROM openjdk:8-jre
LABEL maintainer="Dominique Besagni <dominique.besagni@inist.fr>"

ARG TT_VERSION=3.2.2
ARG TERMSUITE_VERSION=3.0.10
ARG TT_URL=http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data

# Install applications and set rights

COPY TermSuiteWrapper.sh /usr/bin/TermSuiteWrapper.sh
COPY TermSuiteWrapper2.sh /usr/bin/TermSuiteWrapper2.sh
COPY TermSuiteJson2Tsv.pl /usr/bin/TermSuiteJson2Tsv.pl
COPY TermSuiteTsv2DocTerm.pl /usr/bin/TermSuiteTsv2DocTerm.pl
RUN chmod 0755 /usr/bin/TermSuiteWrapper.sh
RUN chmod 0755 /usr/bin/TermSuiteWrapper2.sh
RUN chmod 0755 /usr/bin/TermSuiteJson2Tsv.pl
RUN chmod 0755 /usr/bin/TermSuiteTsv2DocTerm.pl

## Install necessary tools and clean up

RUN apt-get update \
    && apt-get install -y cpanminus --no-install-recommends \
    && cpanm -q open \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get clean \
    && rm -fr /var/cache/apt/* /var/lib/apt/lists/* \
    && rm -fr ./cpanm /root/.cpanm /usr/src/* /tmp/*

WORKDIR /opt/treetagger/
RUN wget ${TT_URL}/tree-tagger-linux-${TT_VERSION}.tar.gz \
    && wget ${TT_URL}/tagger-scripts.tar.gz \
    && wget ${TT_URL}/english.par.gz \
    && wget ${TT_URL}/french.par.gz \
    && wget ${TT_URL}/german.par.gz \
    && wget ${TT_URL}/russian.par.gz \
    && wget ${TT_URL}/italian.par.gz \
    && wget ${TT_URL}/spanish.par.gz \
    && wget ${TT_URL}/install-tagger.sh \
    && /bin/sh /opt/treetagger/install-tagger.sh \
    && mv lib models \
    && chmod a+x /opt/treetagger/models \
    && rm -rf *.gz *.tgz cmd/ doc/

WORKDIR /opt/TermSuite/
RUN curl -O -L https://search.maven.org/remotecontent?filepath=fr/univ-nantes/termsuite/termsuite-core/${TERMSUITE_VERSION}/termsuite-core-${TERMSUITE_VERSION}.jar

ENV PATH /opt/TermSuite:${PATH}

# Set up working directory and default command

WORKDIR /tmp
RUN chmod 1777 /tmp

CMD ["/usr/bin/TermSuiteWrapper.sh", "-h"]
