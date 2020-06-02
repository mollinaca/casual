#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import socket
import dns.resolver
import nslookup
import pydig

domain = 'www.example.com'

# socket
print ("=== socket.getaddinfo")
addrs = socket.getaddrinfo(domain, 80)
for addr in addrs:
    print(addr)

print ("=== socket.gethostbyname")
addrs = socket.gethostbyname(domain)
print (addrs)

# dnspython
# https://github.com/rthalley/dnspython/blob/master/examples/query_specific.py
print ("=== dns.resolver")
qname = dns.name.from_text('www.example.com')
q = dns.message.make_query(qname, dns.rdatatype.NS)
r = dns.query.udp(q, '8.8.8.8')
print (r)

# nslookup
# https://pypi.org/project/nslookup/
print ("=== nslookup")
dns_query = nslookup.Nslookup()
ips_record = dns_query.dns_lookup(domain)
print(ips_record.response_full, ips_record.answer)

# pydig
# https://pypi.org/project/pydig/
answer = pydig.query(domain, 'A')
print (answer)
