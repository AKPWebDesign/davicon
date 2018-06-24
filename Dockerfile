# usage: docker run --rm -it -v $(pwd):/app/icons akpwebdesign/davicon [options] <SVG file>
FROM alpine:3.7

RUN apk --no-cache add inkscape imagemagick

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
