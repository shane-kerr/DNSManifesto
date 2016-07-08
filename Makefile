all: draft-shane-dns-manifesto.txt draft-shane-dns-manifesto.html

draft-shane-dns-manifesto.txt: draft-shane-dns-manifesto.xml
	xml2rfc --text draft-shane-dns-manifesto.xml

draft-shane-dns-manifesto.html: draft-shane-dns-manifesto.xml
	xml2rfc --html draft-shane-dns-manifesto.xml

draft-shane-dns-manifesto.xml: draft-shane-dns-manifesto.md
	mmark -xml2 -page draft-shane-dns-manifesto.md > draft-shane-dns-manifesto.xml

