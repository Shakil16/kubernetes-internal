FROM nginx:stable-alpine

COPY index.html README.md _sidebar.md .nojekyll topics.txt /usr/share/nginx/html/
COPY docs/ /usr/share/nginx/html/docs/
COPY labs/ /usr/share/nginx/html/labs/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1/ || exit 1
