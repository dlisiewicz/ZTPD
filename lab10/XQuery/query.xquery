(:
5.
for $last in doc("db/bib/bib.xml")//author/last
return $last

6.
for $book in doc("db/bib/bib.xml")//book,
    $title in $book/title,
    $author in $book/author
return 
    <ksiazka>
        <title>{$title}</title>
        <author>{$author}</author>
    </ksiazka>
    
7.
for $book in doc("db/bib/bib.xml")//book,
    $title in $book/title,
    $author in $book/author
return 
    <ksiazka>
        <autor>{concat($author/last, $author/first)}</autor>
        <tytul>{$title}</tytul>
    </ksiazka>
    
8.
for $book in doc("db/bib/bib.xml")//book,
    $title in $book/title,
    $author in $book/author
return 
    <ksiazka>
        <autor>{concat($author/last, " ", $author/first)}</autor>
        <tytul>{$title}</tytul>
    </ksiazka>
    
9.
<wynik>{
    for $book in doc("db/bib/bib.xml")//book,
        $title in $book/title,
        $author in $book/author
    return 
        <ksiazka>
            <autor>{concat($author/last, " ", $author/first)}</autor>
            <tytul>{$title}</tytul>
        </ksiazka>
}</wynik>

10.
<imiona>{
    for $author in doc("db/bib/bib.xml")//book[title = "Data on the Web"]/author
    return <imie>{$author/first}</imie>
}</imiona>

11.
doc("db/bib/bib.xml")//book[title = "Data on the Web"]

for $book in doc("db/bib/bib.xml")//book
where $book/title = "Data on the Web"
return $book

12.
<Data>{
    for $author in doc("db/bib/bib.xml")//book[contains(title, "Data")]/author
    return <nazwisko>{$author/last}</nazwisko>
}</Data>


13.
<Data>{
    for $book in doc("db/bib/bib.xml")//book[contains(title, "Data")],
        $author in $book/author
    return (
        <title>{$book/title}</title>,
        <nazwisko>{$author/last}</nazwisko>
    )
}</Data>

14.
for $book in doc("db/bib/bib.xml")//book
where count($book/author) <= 2
return $book/title

15.
for $book in doc("db/bib/bib.xml")//book
return 
    <ksiazka>
        <title>{$book/title}</title>
        <autorow>{count($book/author)}</autorow>
    </ksiazka>
    
16.
<przedział>{
    let $years := doc("db/bib/bib.xml")//book/@year
    return concat(min($years), " - ", max($years))
}</przedział>


17.
<różnica>{
    let $prices := doc("db/bib/bib.xml")//book/price/xs:decimal(.)
    return max($prices) - min($prices)
}</różnica>

18.
<najtańsze>{
    let $minPrice := min(doc("db/bib/bib.xml")//book/price/xs:decimal(.))
    for $book in doc("db/bib/bib.xml")//book[price = $minPrice]
    return 
        <najtańsza>
            <title>{$book/title}</title>
            {for $author in $book/author return $author}
        </najtańsza>
}</najtańsze>

19.
for $author in distinct-values(doc("db/bib/bib.xml")//author/last)
return 
    <autor>
        <last>{$author}</last>
        {for $book in doc("db/bib/bib.xml")//book[author/last = $author]
         return <title>{$book/title}</title>}
    </autor>

20.
<wynik>{
    for $play in collection("db/shakespeare")//PLAY
    return <TITLE>{$play/TITLE}</TITLE>
}</wynik>

21.
<wynik>{
    for $play in collection("db/shakespeare")//PLAY
    where contains($play//LINE, "or not to be")
    return <TITLE>{$play/TITLE}</TITLE>
}</wynik>

22.
:)

<wynik>{
    for $play in collection("db/shakespeare")//PLAY
    let $title := $play/TITLE
    let $characters := count($play//PERSONA)
    let $acts := count($play//ACT)
    let $scenes := count($play//SCENE)
    return 
        <sztuka tytul="{$title}">
            <postaci>{$characters}</postaci>
            <aktow>{$acts}</aktow>
            <scen>{$scenes}</scen>
        </sztuka>
}</wynik>