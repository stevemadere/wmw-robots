FROM takitake/docker-poltergeist
MAINTAINER Steve Madere <steve@stevemadere.com>

RUN apt-get install -y vim
RUN gem install capybara awesome_print

ENV share_dir /shared
ENV install_dir /usr/src/app


RUN mkdir -p  $install_dir
RUN mkdir -p  $share_dir
WORKDIR $install_dir
COPY . $install_dir

CMD ["bash"]
