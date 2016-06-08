FROM nginx:1.10.0
MAINTAINER Mike Metral "metral@gmail.com"

RUN apt-get update \
        && apt-get install --no-install-recommends --no-install-suggests -y \
                            curl \
        && rm -rf /var/lib/apt/lists/*

CMD ["nginx", "-g", "daemon off;"]
