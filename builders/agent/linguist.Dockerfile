
RUN apk add --no-cache ruby ruby-rugged ruby-charlock_holmes ruby-json

RUN apk add --no-cache --virtual build_deps ruby-dev build-base cmake icu-dev 

RUN gem install --no-ri --no-rdoc github-linguist

RUN apk del build_deps
