/*
Ćwiczenie 1
Standard SQL/MM Part: 3 Spatial.
*/

/*
A. Wykorzystując klauzulę CONNECT BY wyświetl hierarchię typu ST_GEOMETRY.
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||
', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
and prior t.owner = t.owner;
*/

/*
B. Wyświetl nazwy metod typu ST_POLYGON.
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;
*/

/*
C. Utwórz tabelę MYST_MAJOR_CITIES o następujących kolumnach:
• FIPS_CNTRY VARCHAR2(2),
• CITY_NAME VARCHAR2(40),
• STGEOM ST_POINT.
*/

CREATE TABLE MYST_MAJOR_CITIES
(
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);

/*
D. Przepisz zawartość tabeli MAJOR_CITIES (znajduje się ona w schemacie ZTPD) do
stworzonej przez Ciebie tabeli MYST_MAJOR_CITIES dokonując odpowiedniej
konwersji typów.
*/

INSERT INTO MYST_MAJOR_CITIES (FIPS_CNTRY, CITY_NAME, STGEOM)
SELECT ztpd.FIPS_CNTRY, ztpd.CITY_NAME, TREAT(ST_POINT.FROM_SDO_GEOM(ztpd.GEOM) AS ST_POINT) STGEOM
FROM MAJOR_CITIES ztpd;


/*
Ćwiczenie 2
Standard SQL/MM Part: 3 Spatial – definiowanie geometrii
A. Wstaw do tabeli MYST_MAJOR_CITIES informację dotyczącą Szczyrku. Załóż, że
centrum Szczyrku znajduje się w punkcie o współrzędnych 19.036107;
49.718655. Wykorzystaj 3-argumentowy konstruktor ST_POINT (ostatnim
argumentem jest identyfikator układu współrzędnych).
*/

INSERT INTO MYST_MAJOR_CITIES (FIPS_CNTRY, CITY_NAME, STGEOM)
VALUES ('PL', 'Szczyrk', ST_POINT(19.036107, 49.718655, 4326));

/*
Ćwiczenie 3
Standard SQL/MM Part: 3 Spatial – pobieranie własności i miar
*/

/*
A. Utwórz tabelę MYST_COUNTRY_BOUNDARIES z następującymi atrybutami
• FIPS_CNTRY VARCHAR2(2),
• CNTRY_NAME VARCHAR2(40),
• STGEOM ST_MULTIPOLYGON.
*/

CREATE TABLE MYST_COUNTRY_BOUNDARIES
(
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
);


/*
B. Przepisz zawartość tabeli COUNTRY_BOUNDARIES do nowo utworzonej tabeli
dokonując odpowiednich konwersji.
*/

insert into MYST_COUNTRY_BOUNDARIES (FIPS_CNTRY, CNTRY_NAME, STGEOM)
select ZTPD.FIPS_CNTRY, ZTPD.CNTRY_NAME, ST_MULTIPOLYGON(ZTPD.GEOM)
from COUNTRY_BOUNDARIES ZTPD;

/*
C. Sprawdź jakiego typu i ile obiektów przestrzennych zostało umieszczonych
w tabeli MYST_COUNTRY_BOUNDARIES.
*/


SELECT M.STGEOM.ST_GEOMETRYTYPE(), count(*)
from MYST_COUNTRY_BOUNDARIES M
group by M.STGEOM.ST_GEOMETRYTYPE();

/*
D. Sprawdź czy wszystkie definicje przestrzenne uznawane są za proste.
*/

SELECT M.STGEOM.ST_ISSIMPLE(), count(*)
from MYST_COUNTRY_BOUNDARIES M
group by M.STGEOM.ST_ISSIMPLE();

/*
Ćwiczenie 4
Standard SQL/MM Part: 3 Spatial – przetwarzanie danych przestrzennych
*/

/*
A. Sprawdź ile miejscowości (MYST_MAJOR_CITIES) zawiera się w danym państwie
(MYST_COUNTRY_BOUNDARIES).
*/

SELECT C.CNTRY_NAME, count(*)
FROM MYST_COUNTRY_BOUNDARIES C, MYST_MAJOR_CITIES M
WHERE SDO_RELATE(C.STGEOM, M.STGEOM, 'mask=inside+contains') = 'TRUE'
GROUP BY C.CNTRY_NAME;

/*
B. Znajdź te państwa, które graniczą z Czechami.
*/

SELECT C1.CNTRY_NAME AS PANSTWO
FROM MYST_COUNTRY_BOUNDARIES C1 ,MYST_COUNTRY_BOUNDARIES C2
WHERE SDO_RELATE(C1.STGEOM, C2.STGEOM, 'mask=touch') = 'TRUE'
AND C2.CNTRY_NAME='Czech Republic';

/*
C. Znajdź nazwy tych rzek, które przecinają granicę Czech – wykorzystaj tabelę
RIVERS (z racji korzystania z implementacji SQL/MM w Oracle konieczne jest
wykorzystanie także konstruktora typu ST_LINESTRING).
*/

SELECT M.CNTRY_NAME, R.NAME
FROM MYST_COUNTRY_BOUNDARIES M, RIVERS R
WHERE ST_LINESTRING(R.GEOM).ST_INTERSECTS(M.STGEOM) = 1
AND M.CNTRY_NAME = 'Czech Republic';

/*
D. Sprawdź, jaka powierzchnia jest Czech i Słowacji połączonych w jeden obiekt
przestrzenny.
*/

SELECT TREAT(M.STGEOM.ST_UNION(M2.STGEOM) as ST_POLYGON).ST_AREA()
FROM MYST_COUNTRY_BOUNDARIES M, MYST_COUNTRY_BOUNDARIES M2
WHERE M.CNTRY_NAME = 'Czech Republic'
AND M2.CNTRY_NAME = 'Slovakia';


/*
E. Sprawdź jakiego typu obiektem są Węgry z "wykrojonym" Balatonem –
wykorzystaj tabelę WATER_BODIES.
*/

SELECT M.CNTRY_NAME, W.NAME, M.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(W.GEOM)).ST_GEOMETRYTYPE()
FROM MYST_COUNTRY_BOUNDARIES M, WATER_BODIES W
WHERE M.CNTRY_NAME = 'Hungary'
AND W.NAME = 'Balaton';

/*
Ćwiczenie 5
Standard SQL/MM Part: 3 Spatial – indeksowanie i przetwarzanie przy
użyciu operatorów SDO_NN i SDO_WITHIN_DISTANCE.
*/

/*
A. Wykorzystując operator SDO_WITHIN_DISTANCE znajdź liczbę miejscowości
oddalonych od terytorium Polski nie więcej niż 100 km. (wykorzystaj tabele
MYST_MAJOR_CITIES i MYST_COUNTRY_BOUNDARIES). Obejrzyj plan wykonania
zapytania. (Uwaga: We wcześniejszych wersjach Oracle użycie tych operatorów
nawet dla standardowych typów SQL/MM było możliwe tylko z pomocą indeksu
przestrzennego. Bez niego zapytanie kończyło się błędem „ORA-13226: interfejs
nie jest obsługiwany bez indeksu przestrzennego”.)
*/

SELECT count(*)
FROM MYST_MAJOR_CITIES M, MYST_COUNTRY_BOUNDARIES C
WHERE SDO_WITHIN_DISTANCE(M.STGEOM, C.STGEOM, 'distance=100 unit=km') = 'TRUE'
AND C.CNTRY_NAME <> 'Poland';

/*
B. Zarejestruj metadane dotyczące stworzonych przez Ciebie tabeli
MYST_MAJOR_CITIES i/lub MYST_COUNTRY_BOUNDARIES.
*/

INSERT INTO USER_SDO_GEOM_METADATA
SELECT 'MYST_MAJOR_CITIES', 'STGEOM', DIMINFO, SRID
FROM ALL_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'MAJOR_CITIES';

/*
C. Utwórz na tabelach MYST_MAJOR_CITIES i/lub MYST_COUNTRY_BOUNDARIES
indeks R-drzewo.
*/

CREATE INDEX MYST_MAJOR_CITIES_IDX ON MYST_MAJOR_CITIES(STGEOM) INDEXTYPE IS MDSYS.SPATIAL_INDEX;

/*
D. Ponownie znajdź liczbę miejscowości oddalonych od terytorium Polski nie więcej
niż 100 km. Sprawdź jednocześnie, czy założone przez Ciebie indeksy są
wykorzystywane wyświetlając plan wykonania zapytania.
*/

EXPLAIN PLAN FOR
select M.CNTRY_NAME, COUNT(*) 
from MYST_COUNTRY_BOUNDARIES M, MYST_MAJOR_CITIES M2
WHERE SDO_WITHIN_DISTANCE(M2.STGEOM, M.STGEOM, 'distance=100 unit=km') = 'TRUE' AND M.CNTRY_NAME = 'Poland'
group by M.CNTRY_NAME;