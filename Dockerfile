ARG ARCH=amd64
FROM balenalib/${ARCH}-debian

LABEL maintainer="bofalot"

HEALTHCHECK --interval=1m --timeout=20s --start-period=1m \
  CMD if test $( curl -m 10 -s https://api.nordvpn.com/vpn/check | jq -r '.["status"]' ) = "Protected" ; then exit 0; else nordvpn d ; nordvpn c ${CONNECT} ; exit $?; fi

#CROSSRUN [ "cross-build-start" ]
RUN addgroup --system vpn && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y wget dpkg curl gnupg2 jq ipset iptables xsltproc && \
    wget -nc https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn_3.7.4_amd64.deb && \
    dpkg -i nordvpn_3.7.4_amd64.deb && \
    apt-get clean && \
    update-alternatives --set iptables /usr/sbin/iptables-legacy && \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy && \
    apt-get clean && \
    rm -rf \
        ./nordvpn* \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*
#CROSSRUN [ "cross-build-end" ]

CMD /usr/bin/start_vpn.sh
COPY start_vpn.sh /usr/bin

