FROM balenalib/amd64-debian

ARG VERSION
ENV VERSION=${VERSION:-3.7.4}

LABEL maintainer="bofalot"

COPY start_vpn.sh /usr/bin
COPY healthcheck.sh /usr/bin

HEALTHCHECK --interval=1m --timeout=20s --start-period=1m CMD bash /usr/bin/healthcheck.sh

RUN echo Installing "nordvpn_"${VERSION}"_amd64.deb" && \
    addgroup --system vpn && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y wget dpkg curl gnupg2 jq ipset iptables xsltproc && \
    wget -nc "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn_"${VERSION}"_amd64.deb" && \
    dpkg -i "nordvpn_"${VERSION}"_amd64.deb" && \
    apt-get clean && \
    update-alternatives --set iptables /usr/sbin/iptables-legacy && \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy && \
    apt-get clean && \
    rm -rf \
        ./nordvpn* \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

CMD /usr/bin/start_vpn.sh
