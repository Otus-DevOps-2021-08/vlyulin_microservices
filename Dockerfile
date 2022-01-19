FROM ruby:2.4.2

ADD ./reddit /reddit
RUN cd /reddit && ls && bundle install
ENV SERVER_IP=51.250.1.180
ENV REPO_NAME=vlyulin/reddit
ENV DEPLOY_USER=deploy
RUN cd /reddit && ruby simpletest.rb
