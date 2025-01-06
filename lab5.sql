/*
Ćwiczenie 1
Tworzenie własnych metadanych i indeksów.

A. W ramach poprzednich ćwiczeń stworzona została tabela FIGURY. Zawiera ona kolumnę
przestrzenną – warstwę mapy przestrzennej
Zarejestruj stworzoną przez Ciebie warstwę w słowniku bazy danych (metadanych). Domyślna
tolerancja niechaj wynosi 0.01.

B. Dokonaj estymacji rozmiaru indeksu R-drzewo dla stworzonej przez Ciebie tabeli FIGURY.
Przyjmij następujące dane:
• docelowa liczba wierszy: 3 miliony,
• wielkość bloku bazy danych: 8192,
• parametr SDO_RTR_PCTFREE: 10,
• liczba wymiarów: 2,
• indeks nie będzie indeksem geodezyjnym (0).

C. Utwórz indeks R-drzewo na utworzonej przez Ciebie tabeli.
Indeks został utworzony.

D. Sprawdź za pomocą operatora SDO_FILTER, które z utworzonych geometrii "mają coś
wspólnego" z punktem 3,3. Czy wynik odpowiada rzeczywistości? Czym to jest spowodowane?

E. Sprawdź za pomocą operatora SDO_RELATE, które z utworzonych geometrii "mają coś
wspólnego" (nie są rozłączne) z punktem 3,3. Czy teraz wynik odpowiada rzeczywistości?
*/

-- A
INSERT INTO USER_SDO_GEOM_METADATA
VALUES('FIGURY', 'KSZTALT', MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('X', 0, 9, 0.01), MDSYS.SDO_DIM_ELEMENT('Y', 0, 9, 0.01)), NULL);

-- B
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0) FROM DUAL;

-- C
CREATE INDEX FIGURY_IDX ON FIGURY(KSZTALT) INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-- D
SELECT ID
FROM FIGURY
WHERE SDO_FILTER(KSZTALT, SDO_GEOMETRY(2001, NULL, NULL, SDO_ELEM_INFO_ARRAY(1,1,1), SDO_ORDINATE_ARRAY(3,3)), 'querytype=WINDOW') = 'TRUE';

-- E
SELECT ID
FROM FIGURY
WHERE SDO_RELATE(KSZTALT, SDO_GEOMETRY(2001, NULL, NULL, SDO_ELEM_INFO_ARRAY(1,1,1), SDO_ORDINATE_ARRAY(3,3)), 'mask=ANYINTERACT
') = 'TRUE';

/*
Ćwiczenie 2
Wykorzystanie operatorów do przetwarzania danych przestrzennych.
W bazie danych dostępnych jest pięć tabel zawierających dane przestrzenne obejmujące swoim
zakresem środkową Europę. Tabele te to:
• COUNTRY_BOUNDARIES – granice państw,
• RIVERS – rzeki,
• MAJOR_CITIES – główne miasta,
• WATER_BODIES – śródlądowe obszary wodne,
• STREETS_AND_RAILROADS – drogi.
Powyższe dane znajdują się w innym schemacie niż Twój, ale posiadają publiczne synonimy,
dlatego nie ma potrzeby dodawania nazwy schematu przy odwoływaniu się do nich.
Przed przetwarzaniem możesz „zobaczyć” dane wykorzystując SQL Developera. Pamiętaj
o ewentualnym usunięciu warstw z poprzedniego ćwiczenia lub utworzeniu nowej zakładki
w narzędziu Map Viewer. Załaduj do widoku map wszystkie pięć warstw, a następnie ułóż je
w następującej kolejności:
• COUNTRY_BOUNDARIES
• MAJOR_CITIES
• STREETS_AND_RAILROADS
• WATER_BODIES
• RIVERS
Teraz już wiesz jak dane, na których będziemy działać wyglądają.
Możesz zamknąć widok mapy i po prostu wykonywać poniższe ćwiczenia, możesz także wykonywać
niektóre ćwiczenia (wydobywające dane przestrzenne) dodatkowo korzystając z mapy – umieszczając
wyniki jako kolejne warstwy – pamiętaj aby w takim przypadku do rozwiązań dodawać kolumnę
SDO_GEOMETRY.
*/

/*
A. Wykorzystując operator SDO_NN i funkcję SDO_NN_DISTANCE znajdź dziewięć najbliższych
miast wraz z odległościami od Warszawy.
*/

SELECT CITY_NAME as MIASTO, SDO_NN_DISTANCE(1) as ODL
FROM MAJOR_CITIES
WHERE SDO_NN(GEOM, (SELECT GEOM FROM MAJOR_CITIES WHERE city_name='Warsaw'), 'sdo_num_res=10 unit=km',1) = 'TRUE' 
AND ID <> (SELECT ID FROM MAJOR_CITIES where city_name='Warsaw')

/*
B. Sprawdź, które miasta znajdują się w odległości 100 km od Warszawy. Skorzystaj z operatora
SDO_WITHIN_DISTANCE. Wynik porównaj z wynikiem z zadania powyżej.
*/

SELECT CITY_NAME as MIASTO
FROM MAJOR_CITIES
WHERE SDO_WITHIN_DISTANCE(GEOM, (SELECT GEOM FROM MAJOR_CITIES WHERE city_name='Warsaw'), 'distance=100 unit=km') = 'TRUE'
AND ID <> (SELECT ID FROM MAJOR_CITIES where city_name='Warsaw');


/*
C. Wyświetl miasta ze Słowacji. Skorzystaj z operatora SDO_RELATE
*/

SELECT CITY_NAME as MIASTO, CNTRY_NAME as KRAJ
FROM MAJOR_CITIES
WHERE SDO_RELATE(GEOM, (SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME='Slovakia'), 'mask=inside+contains') = 'TRUE';

/*
D. Znajdź odległości pomiędzy Polską a krajami, które z nią nie graniczą. Wykorzystaj operator
SDO_RELATE oraz funkcję SDO_DISTANCE.
*/

SELECT C1.CNTRY_NAME AS PANSTWO, SDO_GEOM.SDO_DISTANCE(C1.GEOM, C2.GEOM, 1, 'unit=km') AS ODL
FROM COUNTRY_BOUNDARIES C1 ,COUNTRY_BOUNDARIES C2
WHERE SDO_RELATE(C1.GEOM, C2.GEOM, 'mask=antyinteract') <> 'TRUE' 
AND C2.CNTRY_NAME='Poland'
AND SDO_GEOM.SDO_DISTANCE(C1.GEOM, C2.GEOM, 1, 'unit=km')>0;


/*
Ćwiczenie 3
Wykorzystanie funkcji geometrycznych do przetwarzania danych przestrzennych.
*/

/*
A. Znajdź sąsiadów Polski oraz odczytaj długość granicy z każdym z nich.
*/

SELECT C1.CNTRY_NAME AS PANSTWO, SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(C1.GEOM, C2.GEOM, 1), 1, 'unit=km') AS DLUGOSC
FROM COUNTRY_BOUNDARIES C1 ,COUNTRY_BOUNDARIES C2
WHERE SDO_RELATE(C1.GEOM, C2.GEOM, 'mask=touch') = 'TRUE'
AND C2.CNTRY_NAME='Poland';

/*
B. Podaj nazwę Państwa, którego fragment przechowywany w bazie danych jest największy.
*/

SELECT CNTRY_NAME
FROM COUNTRY_BOUNDARIES
WHERE SDO_GEOM.SDO_AREA(GEOM) = (SELECT MAX(SDO_GEOM.SDO_AREA(GEOM)) FROM COUNTRY_BOUNDARIES);

/*
C. Wyznacz pole minimalnego ograniczającego prostokąta (MBR), w którym znajdują się Warszawa
i Łódź.
*/

SELECT ROUND(SDO_GEOM.SDO_AREA(SDO_GEOM.SDO_MBR(SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 0.01)),1, 'unit=SQ_KM'), 5) as SQ_KM
FROM MAJOR_CITIES A, MAJOR_CITIES B
WHERE A.CITY_NAME = 'Warsaw' AND B.CITY_NAME='Lodz';


/*
D. Jakiego typu geometria będzie sumą geometryczną państwa polskiego i Pragi. Wykorzystaj
odpowiednią metodę lub atrybut typu SDO_GEOMETRY.
Uwaga: Poniższy wynik uzyskano odczytując atrybut. Metoda zwraca liczbę, którą tworzą dwie
ostatnie cyfry kodu typu geometrii.
*/

SELECT SDO_GEOM.SDO_UNION(C1.GEOM, C2.GEOM, 0.01).GET_DIMS() || SDO_GEOM.SDO_UNION(C1.GEOM, C2.GEOM, 0.01).GET_LRS_DIM() || LPAD(SDO_GEOM.SDO_UNION(C1.GEOM, C2.GEOM, 0.01).GET_GTYPE(), 2, '0') as GTYPE
FROM COUNTRY_BOUNDARIES C1, MAJOR_CITIES C2
WHERE C1.CNTRY_NAME = 'Poland'AND C2.CITY_NAME = 'Prague';

/*
E. Znajdź nazwę miasta, które znajduje się najbliżej centrum ciężkości swojego państwa.
*/

SELECT M.CITY_NAME MIASTO, SDO_GEOM.SDO_DISTANCE(M.GEOM, SDO_GEOM.SDO_CENTROID(C.GEOM, 0.01), 1, 'unit=km') as ODL
FROM MAJOR_CITIES M, COUNTRY_BOUNDARIES C
ORDER BY ODL;

/*
F. Podaj długość tych z rzek, które przepływają przez terytorium Polski. Ogranicz swoje obliczenia
tylko do tych fragmentów, które leżą na terytorium Polski.
*/

SELECT NAME as RZEKA, SUM(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(R.GEOM, C.GEOM, 1), 1, 'unit=km')) as DLUGOSC
FROM RIVERS R, COUNTRY_BOUNDARIES C
WHERE SDO_RELATE(R.GEOM, C.GEOM, 'mask=anyinteract') = 'TRUE'
AND C.CNTRY_NAME='Poland'
group by NAME;