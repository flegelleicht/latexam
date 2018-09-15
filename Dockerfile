FROM alpine:latest
RUN apk update \
		&& apk add ruby texlive-full pdftk
CMD ["/bin/bash"]

