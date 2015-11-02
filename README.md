A DNS Manifesto
===============

Introduction
------------
The DNS protocol has been stretched in ways far beyond the original
architecture. It continues to be pushed further, but at the same time
is limited by old design decisions.

It is time to consider fundamental changes to the protocol. These
changes should:

1. Keep most of what DNS has gotten right
2. Throw away most of what DNS has gotten wrong
3. Allow DNS to more easily evolve in the future


Shoulders of Giants
-------------------
The DNS has gotten many things right.

[ talk about how the DNS is an old, successful protocol ]

### Name space

The DNS name space is straightforward: labels separated by dots.
EXAMPLE.COM. IP6.ARPA. IETF.ORG. This simple abstraction is easily
understood by people, but also forms the basis that allows:

1. Separation of responsibility between each layer, and 
2. A hierarchy of servers (an upside-down tree)

The name space has a few decisions which might be different if it
was created today (such as being case-insensitive, and being limited
to ASCII alphanumeric symbols and dash), but it is basically great.
Any future protocol/scheme should keep the namespace in current use
with the DNS.

Both the separation of responsibility and the hierarchy in the name
space allow DNS to be massively scalable on both an organizational and
a technological basis. Further, those responsible for any given name
can use as many or as few resources to service that name as necessary.

### Redundancy

Each label in the DNS name space is unique. However, within each label
the way the data is maintained and published is completely redundant.
This is achieved by having a set of servers, any of which can answer
queries about the label.

This redundancy applies for every point in DNS. There is no single
point of failure in the system.

### Caching

The DNS architecture allows various components to re-use information
for a period of time. This caching is a key part of scaling, as it
moves the server load closer to where the data is consumed.

### Loose coherency

Because of this caching and because of the use of several different
sources in data publication, potentially operated by independent and
collaborating entitires, different places of the Internet may have
slightly different views of the DNS at any given time. This "loose
consistency" is an explicit trade-off of exact answers for
performance, and is key to the scaling of DNS today.

### Data authentication

A relatively late addition to the DNS are the DNS Security Extensions
(DNSSEC). This adds an authentication system to the data published in
DNS. It is independent of how the data is published or accessed,
meaning that it can be authenticated at any and every step as needed.

While the details of DNSSEC are more complicated than they would be if
designed today, the principle of securing the data itself is good.

### Open Standards, Open Source Implementations

Open standards and open source implementations of the DNS have allowed
it to be ported to every system on the Internet. Vendors have been
able to provide solutions in many different ways, while at the same
time dedicated individuals or organizations can solve problems on
their own.

This also provides a low barrier to entry, which given the basic
infrastructure nature of DNS, allows for a low barrier of entrance to
deployment of new Internet services.


Decisions to Revisit
--------------------
The DNS has a lot of cruft, which is not surprising for a technology
more than 30 years old that has been changed every few months in that
time.

### Protocol Inflexibility

The reason that this Manifesto is needed is at least partially because
the DNS protocol itself is difficult to change.

There are few signaling within the protocol to specify versions or
capabilities. The expectation is that systems will continue to run
largely unmodified for many years, often only changing when hardware
fails.

This limitation has had impact beyond the DNS itself, as the role of
DNS in the larger Internet is limited by current capabilities.

In addition to making extensions or improvements to the protocol
difficult, the inflexibility of DNS has had security implications.
Vulnerabilities in the protocol itself are basically impossible to fix
completely, resulting in long-lasting weaknesses in the wider
Internet.

The new minimum requisite features must include the capability to
communicate versions as well as capability negotiation between any two
end-points.

### Denial of Service (Distributed and Otherwise)

Like any other service on the Internet the DNS is vulnerable to denial
of service attacks today. However, it is both the target of these
attacks and used as an unwilling accomplice by those launching attacks
on other systems.

In order to defend against DoS attacks, DNS systems must be heavily
over-provisioned, constantly monitored, or both. An ideal protocol
would be able to defend itself against DoS and avoid being used as a
vector to attack other systems. One feature to consider in this regard
easing capability to provide end-point validation.

### Hints about the User

Since DNS is used to locate servers, it is used by CDN and anyone
wishing to provide a better user experience. Protocols that perform
services that users want can be delivered in customized to that user.
For example, traffic can be routed to servers that are closer, less
busy, or otherwise provide a faster response.

Recently the ability to include some information about the device
network has been added, which provides part of this benefit. This is a
very limited step, partially due to difficult privacy concerns. 

Beyond this, devices have no way to describe the environment they are
operating in. For example, the network of one mobile device may have
different qualities than that of different mobile device or a fixed
device. All queries are the same in the current DNS.

Currently there are no ways to express user preferences in the DNS. In
addition to faster service, privacy concerns or other desires have no
way to be declared and must be handled by later protocols.

These two aspects are often in conflict, so a solution must enable
both under user control.

### Missing Server Metadata

The DNS has almost no information about the DNS servers themselves.
There is no way for authoritative servers to publish their
capabilities. The recursive resolvers and stub resolvers have only
minimal ability to declare what they can do (limited to UDP buffer
sizes and DNSSEC support) or how they are configured.

This means that servers must infer how the various systems work, which
is currently done by repeatedly scanning remote capabilities (for
example EDNS buffer size adjustment).  The lack of explicit
information means that the process is inefficient and occasionally
results in very sub-optimal behavior or even complete failure.

### Missing Encryption

At no point is any DNS data encrypted. Queries and answers are
cleartext, as is zone data replicated between servers. This means that
both passive and active snooping of the DNS is almost trivial.

Certain kinds of traffic analysis will likely always be possible given
that servers act as proxies in the DNS architecture. For example,
caching resolvers see the queries of stub resolvers. Without proxies
the traffic analysis risk is still present, although different since
then queries would need to come directly from end users' devices.

### Data completeness

To avoid errors derived from partial information publication the new
unit of data transfer must be the equivalent of today's RRsets rather
than individual records.

### Weak Data Synchronization Tools

DNS has a protocol to share data between authoritative servers. This
protocol has a number of limitations. It does not provide a way to add
or remove servers within a given label. It provides very few ways for
parent and child zones to synchronize. It scales quite poorly with
large numbers of zones, and DNSSEC data can greatly increases the
amount of data to periodically synchronize.

### Protocol Debugging Support

DNS has a very few tools for administrators to understand DNS
problems. For example, the ServFail code is used to cover a huge
number of possible problems without any details, meaning operators
must try to infer the true problem. Likewise there are few methods
that operators can use to figure out the state of the various servers,
caches, and so on in the system.


Stuff to Jettison
-----------------
Some things just don't make sense and can probably be removed with
extreme prejudice.

* Name compression is extremely CPU-intensive. Either a more efficient
  compression mechanism should be developed or no compression applied.
* Limitation of one query per message.
* Class.
* Unvalidated UDP.
* Wildcards.


Uncharted Continents
--------------------
There are other areas that might be explored.

### Distributed Management

Currently a single label is managed by a single organization.
Protocols like Bitcoin have proven that distributed management is
possible. This could be useful for politically contentious zones like
the root zone, or act as an alternate model instead of a
registry/registrar split for large zones.

### Topology Awareness

Many name servers use anycasting today, where a single IP address is
served from separate physical locations. There may be alternate ways
to get DNS data closer to where it needs to be than relying on the
routing system. Or, if DNS does interact with the routing world,
perhaps there are smarter ways to do it.

### Historical Data, Audit Trails

Today the DNS always provides the latest & greatest versions of
information. This matches the original intent of supporting other
protocols need to map host names to IP addresses. However other uses
may benefit from knowing prior values of DNS data.


Here There Be Dragons
---------------------
DNS is an important part of the Internet. It may not be more important
than the number system, or the routing system, or the servers or other
devices on the network. However, the DNS has a few features that make
it important in the business and political realms:

1. The DNS is highly visible, unlike many other critical protocols
   (for example DHCP or NTP). You see it every time you read the
   address of a web site or an e-mail.
2. The DNS is hierarchical, so that labels near the top of the tree
   naturally have more perceived importance than labels near the
   bottom.
3. The DNS has country codes at the top level, which are delegated at
   the behest of the country they are for.

For the most part the business and political interests allow the
technical folks in the DNS free reign, although this may not be true
if technology changes appear to threaten their goals.


Reboot the DNS!
---------------
DNS can evolve.

DNS can be changed in ways that work with old servers and software,
and still provide real benefits to organizations and individuals
able and willing to upgrade.

DNS can be changed in steps. It can be experimented with. Mistakes can
be made, and mistakes can be fixed.
