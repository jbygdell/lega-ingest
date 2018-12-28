FROM python:3.6.7-alpine3.8 as BUILD

RUN apk add git postgresql-dev gcc musl-dev libffi-dev make gnupg

ARG checkout=dev

RUN pip install -r https://raw.githubusercontent.com/NBISweden/LocalEGA-cryptor/master/requirements.txt
RUN pip install git+https://github.com/NBISweden/LocalEGA-cryptor.git

RUN pip install -r https://raw.githubusercontent.com/NBISweden/LocalEGA/${checkout}/requirements.txt
RUN pip install git+https://github.com/NBISweden/LocalEGA.git@${checkout}


FROM python:3.6.7-alpine3.8

LABEL maintainer "EGA System Developers"

RUN apk add --no-cache --update shadow postgresql-dev

RUN groupadd -r lega && \
    useradd -M -r -g lega lega

COPY --from=BUILD usr/local/lib/python3.6/ usr/local/lib/python3.6/

COPY --from=BUILD /usr/local/bin/lega-cryptor /usr/local/bin/

COPY --from=BUILD /usr/local/bin/ega-ingest /usr/local/bin/

USER lega:lega

ENTRYPOINT [ "/usr/local/bin/ega-ingest" ]