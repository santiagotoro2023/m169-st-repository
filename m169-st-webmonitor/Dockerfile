FROM dominikreussbzu/node

CMD ["node", "/webmonitor/app.js"]

ENV TARGET="sidmar.ch" \
    METHOD="HEAD" \
    INTERVAL="1000"

WORKDIR /webmonitor
COPY app.js .
