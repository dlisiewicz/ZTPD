/*
1. Zdefiniuj typ obiektowy reprezentujący SAMOCHODY. Każdy samochód powinien
mieć markę, model, liczbę kilometrów oraz datę produkcji i cenę. Stwórz tablicę
obiektową i wprowadź kilka przykładowych obiektów, obejrzyj zawartość tablicy
*/

CREATE OR REPLACE TYPE SAMOCHOD AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10,2)
);

DESC SAMOCHOD;

CREATE TABLE SAMOCHODY OF SAMOCHOD;

INSERT INTO SAMOCHODY VALUES (
    SAMOCHOD('FIAT', 'BRAVA', 60000, TO_DATE('30-11-1999', 'DD-MM-YYYY'), 25000)
);
INSERT INTO SAMOCHODY VALUES (
    SAMOCHOD('FORD', 'MONDEO', 80000, TO_DATE('10-05-1997', 'DD-MM-YYYY'), 45000)
);
INSERT INTO SAMOCHODY VALUES (
    SAMOCHOD('MAZDA', '323', 12000 , TO_DATE('22-09-2000', 'DD-MM-YYYY'), 52000)
);

SELECT * FROM SAMOCHODY;
/*
2. Stwórz tablicę WLASCICIELE zawierającą imiona i nazwiska właścicieli oraz atrybut
obiektowy SAMOCHOD. Wprowadź do tabeli przykładowe dane i wyświetl jej
zawartość.
*/

CREATE TABLE WLASCICIELE (
    IMIE varchar2(100),
    NAZWISKO varchar2(100),
    AUTO SAMOCHOD
);

DESC WLASCICIELE;

INSERT INTO WLASCICIELE VALUES (
    'JAN', 'KOWALSKI', NEW SAMOCHOD('FIAT', 'SEICENTO', 30000, '02-12-0010', 'DD-MM-YYYY', 19500)
);
INSERT INTO WLASCICIELE VALUES (
    'ADAM', 'NOWAK', NEW SAMOCHOD('OPEL', 'ASTRA', 34000, '01-06-0009', 'DD-MM-YYYY', 33700)
);

SELECT * FROM WLASCICIELE;

/*
3. Wartość samochodu maleje o 10% z każdym rokiem. Dodaj do typu obiektowego
SAMOCHOD metodę wyliczającą aktualną wartość samochodu na podstawie wieku.
*/

ALTER TYPE SAMOCHOD ADD MEMBER FUNCTION WARTOSC RETURN NUMBER CASCADE;

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        lata NUMBER;
        aktualna_cena NUMBER;
    BEGIN
        lata := FLOOR(MONTHS_BETWEEN(SYSDATE, DATA_PRODUKCJI) / 12);
        aktualna_cena := CENA * POWER(0.9, lata);
        RETURN aktualna_cena;
    END;
END;

SELECT s.marka, s.cena, s.wartosc() FROM SAMOCHODY s;

/*
4. Dodaj do typu SAMOCHOD metodę odwzorowującą, która pozwoli na porównywanie
samochodów na podstawie ich wieku i zużycia. Przyjmij, że 10000 km odpowiada
jednemu rokowi wieku samochodu.
*/

ALTER TYPE SAMOCHOD ADD MAP MEMBER FUNCTION POROWNAJ RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        lata NUMBER;
        aktualna_cena NUMBER;
    BEGIN
        lata := FLOOR(MONTHS_BETWEEN(SYSDATE, DATA_PRODUKCJI) / 12);
        aktualna_cena := CENA * POWER(0.9, lata);
        RETURN aktualna_cena;
    END;
    MAP MEMBER FUNCTION POROWNAJ RETURN NUMBER IS
    BEGIN
        RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, DATA_PRODUKCJI) / 12) + (kilometry / 10000);
    END;
END;

SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);

/*
5. Stwórz typ WLASCICIEL zawierający imię i nazwisko właściciela samochodu, dodaj
do typu SAMOCHOD referencje do właściciela. Wypełnij tabelę przykładowymi
danymi.
*/

CREATE OR REPLACE TYPE WLASCICIEL AS OBJECT (
    IMIE VARCHAR2(20),
    NAZWISKO VARCHAR2(20)
);

ALTER TYPE SAMOCHOD ADD ATTRIBUTE WLASCICIEL_AUTA REF WLASCICIEL CASCADE;

DROP TABLE WLASCICIELE;

CREATE TABLE WLASCICIELE OF WLASCICIEL;

INSERT INTO WLASCICIELE VALUES (
    NEW WLASCICIEL('JAN', 'KOWALSKI')
);
INSERT INTO WLASCICIELE VALUES (
   NEW WLASCICIEL('ADAM', 'NOWAK')
);

INSERT INTO SAMOCHODY VALUES (
    NEW SAMOCHOD('FIAT', 'BRAVA', 60000, TO_DATE('30-11-1999', 'DD-MM-YYYY'), 25000,
    (select ref(w) from wlasciciele w where w.imie = 'JAN' and w.nazwisko = 'KOWALSKI'))
);

SELECT * FROM SAMOCHODY;

/*
6. Zbuduj kolekcję (tablicę o zmiennym rozmiarze) zawierającą informacje
o przedmiotach (łańcuchy znaków). Wstaw do kolekcji przykładowe przedmioty,
rozszerz kolekcję, wyświetl zawartość kolekcji, usuń elementy z końca kolekcji
*/

DECLARE
    TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
    moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.EXTEND(9);
    FOR i IN 2..10 LOOP
            moje_przedmioty(i) := 'PRZEDMIOT_' || i;
        END LOOP;
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
        END LOOP;
    moje_przedmioty.TRIM(2);
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.EXTEND();
    moje_przedmioty(9) := 9;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.DELETE();
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;

/*
7. Zdefiniuj kolekcję (w oparciu o tablicę o zmiennym rozmiarze) zawierającą listę
tytułów książek. Wykonaj na kolekcji kilka czynności (rozszerz, usuń jakiś element,
wstaw nową książkę).
*/

DECLARE
    TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
    moje_ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    moje_ksiazki.EXTEND(5);
    moje_ksiazki(1) := 'KSIĄŻKA_1';
    moje_ksiazki(2) := 'KSIĄŻKA_2';
    moje_ksiazki(3) := 'KSIĄŻKA_3';
    moje_ksiazki(4) := 'KSIĄŻKA_4';
    moje_ksiazki(5) := 'KSIĄŻKA_5';
    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
        END LOOP;
    moje_ksiazki.EXTEND();
    moje_ksiazki(6) := 'KSIĄŻKA_6';
    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
        END LOOP;
    moje_ksiazki.TRIM(3);
    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;
END;

/*
8. Zbuduj kolekcję (tablicę zagnieżdżoną) zawierającą informacje o wykładowcach.
Przetestuj działanie kolekcji podobnie jak w przykładzie 6.
*/

DECLARE
    TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.EXTEND(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    moi_wykladowcy.EXTEND(8);
    FOR i IN 3..10 LOOP
            moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
        END LOOP;
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END LOOP;
    moi_wykladowcy.TRIM(2);
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END LOOP;
    moi_wykladowcy.DELETE(5,7);
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            IF moi_wykladowcy.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
            END IF;
        END LOOP;
    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
            IF moi_wykladowcy.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
            END IF;
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;

/*
9. Zbuduj kolekcję (w oparciu o tablicę zagnieżdżoną) zawierającą listę miesięcy. Wstaw
do kolekcji właściwe dane, usuń parę miesięcy, wyświetl zawartość kolekcji.
*/

DECLARE
    TYPE t_miesiace IS TABLE OF VARCHAR2(20);
    moje_miesiace t_miesiace := t_miesiace();
BEGIN
    moje_miesiace.EXTEND(12);
    moje_miesiace(1) := 'STYCZEN';
    moje_miesiace(2) := 'LUTY';
    moje_miesiace(3) := 'MARZEC';
    moje_miesiace(4) := 'KWIECIEN';
    moje_miesiace(5) := 'MAJ';
    moje_miesiace(6) := 'CZERWIEC';
    moje_miesiace(7) := 'LIPIEC';
    moje_miesiace(8) := 'SIERPIEN';
    moje_miesiace(9) := 'WRZESIEN';
    moje_miesiace(10) := 'PAZDZIERNIK';
    moje_miesiace(11) := 'LISTOPAD';
    moje_miesiace(12) := 'GRUDZIEN';

    FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
            DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
        END LOOP;

    moje_miesiace.DELETE(2, 4);

    FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP
            IF moje_miesiace.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moje_miesiace(i));
            END IF;
        END LOOP;
END;

/*
10. Sprawdź działanie obu rodzajów kolekcji w przypadku atrybutów bazodanowych.
*/

CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/
CREATE TYPE stypendium AS OBJECT (
nazwa VARCHAR2(50),
kraj VARCHAR2(30),
jezyki jezyki_obce );
/
CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia VALUES
('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES
('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));
SELECT * FROM stypendia;
SELECT s.jezyki FROM stypendia s;
UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';
CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/
CREATE TYPE semestr AS OBJECT (
numer NUMBER,
egzaminy lista_egzaminow );
/
CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry VALUES
(semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES
(semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));
SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;
SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;
SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );
INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 )
VALUES ('METODY NUMERYCZNE');
UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';
DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';

/*
11. Zbuduj tabelę ZAKUPY zawierającą atrybut zbiorowy KOSZYK_PRODUKTOW
w postaci tabeli zagnieżdżonej. Wstaw do tabeli przykładowe dane. Wyświetl
zawartość tabeli, usuń wszystkie transakcje zawierające wybrany produkt.
*/

CREATE TYPE PRODUKTY AS TABLE OF VARCHAR2(20);

CREATE TYPE ZAKUP AS OBJECT
(
    ID NUMBER,
    KOSZYK_PRODUKTOW PRODUKTY
);

CREATE TABLE ZAKUPY OF ZAKUP
    NESTED TABLE KOSZYK_PRODUKTOW STORE AS TAB_KOSZYK_PRODUKTOW;

INSERT INTO ZAKUPY
VALUES (ZAKUP(1, PRODUKTY('CHLEB', 'WODA', 'BANANY')));
INSERT INTO ZAKUPY
VALUES (ZAKUP(2, PRODUKTY('WODA', 'HERBATA')));
INSERT INTO ZAKUPY
VALUES (ZAKUP(3, PRODUKTY('JABLKA', 'MASŁO')));

SELECT Z.*, K.*
FROM ZAKUPY Z, TABLE (Z.KOSZYK_PRODUKTOW) K;

SELECT K.*
FROM ZAKUPY Z, TABLE (Z.KOSZYK_PRODUKTOW) K;

DELETE
FROM ZAKUPY Z
where Z.ID IN (
    SELECT Z1.ID
    FROM ZAKUPY Z1, TABLE (Z1.KOSZYK_PRODUKTOW) K
    WHERE K.COLUMN_VALUE = 'CHLEB'
);

/*
12. Zbuduj hierarchię reprezentującą instrumenty muzyczne.
*/

CREATE
 TYPE instrument AS OBJECT (
nazwa VARCHAR2(20),
dzwiek VARCHAR2(20),
MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
CREATE TYPE BODY instrument AS
MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN dzwiek;
END;
END;
/
CREATE TYPE instrument_dety UNDER instrument (
material VARCHAR2(20),
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_dety AS
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN 'dmucham: '||dzwiek;
END;
MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
BEGIN
RETURN glosnosc||':'||dzwiek;
END;
END;
/
CREATE TYPE instrument_klawiszowy UNDER instrument (
producent VARCHAR2(20),
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN 'stukam w klawisze: '||dzwiek;
END;
END;
/
DECLARE
tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','ping-ping','steinway');
BEGIN
dbms_output.put_line(tamburyn.graj);
dbms_output.put_line(trabka.graj);
dbms_output.put_line(trabka.graj('glosno'));
dbms_output.put_line(fortepian.graj);
END;

/*
13. Zbuduj hierarchię zwierząt i przetestuj klasy abstrakcyjne.
*/

CREATE TYPE istota AS OBJECT (
nazwa VARCHAR2(20),
NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
NOT INSTANTIABLE NOT FINAL;
CREATE TYPE lew UNDER istota (
liczba_nog NUMBER,
OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
CREATE OR REPLACE TYPE BODY lew AS
OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
BEGIN
RETURN 'upolowana ofiara: '||ofiara;
END;
END;
DECLARE
KrolLew lew := lew('LEW',4);
InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;

/*
14. Zbadaj własność polimorfizmu na przykładzie hierarchii instrumentów.
*/

DECLARE
tamburyn instrument;
cymbalki instrument;
trabka instrument_dety;
saksofon instrument_dety;
BEGIN
tamburyn := instrument('tamburyn','brzdek-brzdek');
cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
-- saksofon := instrument('saksofon','tra-taaaa');
-- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;

/*
15. Zbuduj tabelę zawierającą różne instrumenty. Zbadaj działanie funkcji wirtualnych.
*/

CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa')
);
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','ping-ping','steinway') );
SELECT i.nazwa, i.graj() FROM instrumenty i;