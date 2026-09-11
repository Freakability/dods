FROM ubuntu:22.04

ARG steam_user=anonymous
ARG steam_password=
ARG metamod_version=1.20
ARG amxmod_version=1.8.2


RUN apt update && apt install -y lib32gcc-s1 wget curl nano dos2unix libc6 libstdc++6 lib32stdc++6

WORKDIR /root
#RUN wget https://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.gz
#RUN tar -zxvf /root/glibc-2.29.tar.gz
#RUN mkdir /root/glibc-2.29/build_dir
#WORKDIR /root/glibc-2.29/build_dir
#RUN ../configure --prefix=/opt/glibc && make && make install

#RUN wget http://archive.ubuntu.com/ubuntu/pool/main/g/glibc/libc6_2.29-0ubuntu2_amd64.deb
#RUN dpkg -i /root/libc6_2.29-0ubuntu2_amd64.deb

RUN useradd -m -d /home/lan -s /bin/bash lan
USER lan
WORKDIR /home/lan

# Install SteamCMD
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

RUN ./steamcmd.sh \
        +login anonymous \
        +force_install_dir ./srcds/ \
        # mod must be chosen first (only for HLDS)
        +app_update 232290 validate \
        +quit \
        ; exit 0

# 2 runs required for successful install
RUN ./steamcmd.sh \
        +login anonymous \
        +force_install_dir ./srcds/ \
        +app_update 232290 validate \
        +quit \
        ; exit 0

RUN mkdir -p /home/lan/.steam && ln -s /home/lan/srcds /home/lan/.steam/sdk32
#RUN ln -s /home/lan/steam/ /opt/hlds/steamcmd
ADD files/steam_appid.txt /home/lan/srcds/steam_appid.txt
ADD files/dod/ /home/lan/srcds/dod/
#ADD files/server.cfg /home/lan/srcds/dod/cfg/server.cfg
ADD srcds_run.sh /home/lan/srcds_run.sh
USER root
RUN chmod +x /home/lan/srcds_run.sh
USER lan
RUN ln -s /home/lan/srcds/bin/steamclient.so /home/lan/srcds/steamclient.so

# Mods
WORKDIR /home/lan/srcds/dod/
#RUN curl -sqL "https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git971-linux.tar.gz" | tar zxvf -
#RUN curl -sqL "https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6484-linux.tar.gz" | tar zxvf -

# Cleanup
USER root
RUN apt remove -y curl
RUN chown -R lan:lan /home/lan/srcds
RUN dos2unix /home/lan/srcds_run.sh
USER lan

WORKDIR /home/lan/srcds

RUN echo "\"STEAM_0:1:35880\" \"99:z\"" >> /home/lan/srcds/dod/addons/sourcemod/configs/admins_simple.ini
RUN echo "\"STEAM_0:1:54002478\" \"99:z\"" >> /home/lan/srcds/dod/addons/sourcemod/configs/admins_simple.ini

ENTRYPOINT ["/home/lan/srcds_run.sh"]


#example run: docker run -d -p 26900:26900/udp -p 27020:27020/udp -p 27015:27015/udp -p 27015:27015 -e ADMIN_STEAM=1:1:35880 --name dod dod
