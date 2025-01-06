(:

32.
for $k in doc('file:///C:/Users/Dawid/Documents/XPath-XSLT/XPath-XSLT/swiat.xml')//KRAJ[substring(NAZWA, 1, 1) = substring(STOLICA, 1, 1)]
return <KRAJ>
{$k/NAZWA, $k/STOLICA}
</KRAJ>


33.
for $k in doc('file:///C:/Users/Dawid/Documents/XPath-XSLT/XPath-XSLT/zesp_prac.xml')
return $k//ROW/NAZWISKO

33.
for $k in doc('file:///C:/Users/Dawid/Documents/XPath-XSLT/XPath-XSLT/zesp_prac.xml')//ROW[NAZWA='SYSTEMY EKSPERCKIE']/PRACOWNICY/ROW
return $k//NAZWISKO

34.
for $k in doc('file:///C:/Users/Dawid/Documents/XPath-XSLT/XPath-XSLT/zesp_prac.xml')/count(ZESPOLY/ROW[ID_ZESP=10]/PRACOWNICY/ROW)
return $k

35.
for $k in doc('file:///C:/Users/Dawid/Documents/XPath-XSLT/XPath-XSLT/zesp_prac.xml')/ZESPOLY/ROW/PRACOWNICY/ROW[ID_SZEFA=100]
return $k//NAZWISKO

36.
:)

for $k in doc('file:///C:/Users/Dawid/Documents/XPath-XSLT/XPath-XSLT/zesp_prac.xml')/sum(ZESPOLY/ROW/PRACOWNICY[ROW/NAZWISKO="BRZEZINSKI"]/ROW/PLACA_POD)
return $k