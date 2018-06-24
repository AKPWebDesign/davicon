# usage: docker run --rm -it -v $(pwd):/app/icons akpwebdesign/davicon [options] <image>
FROM alpine:3.7

RUN apk --no-cache add inkscape imagemagick bash

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
