FROM google/ruby

WORKDIR /app
RUN gem install redmon

EXPOSE 4567

CMD []
ENTRYPOINT ["redmon"]
