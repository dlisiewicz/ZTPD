/*
1. Utwórz w swoim schemacie tabelę DOKUMENTY o poniższej strukturze:
ID NUMBER(12) PRIMARY KEY
DOKUMENT CLOB
*/

CREATE TABLE DOKUMENTY (
  ID NUMBER(12) PRIMARY KEY,
  DOKUMENT CLOB
);

/*
2. Wstaw do tabeli DOKUMENTY dokument utworzony przez konkatenację 10000 kopii
tekstu 'Oto tekst. ' nadając mu ID = 1 (Wskazówka: wykorzystaj anonimowy blok kodu
PL/SQL).
*/

DECLARE
    v_clob CLOB;
BEGIN
    FOR i IN 1..10000 LOOP
        v_clob := v_clob || 'Oto tekst. ';
    END LOOP;
    INSERT INTO DOKUMENTY VALUES (1, v_clob);
    COMMIT;
END;

/*
3. Wykonaj poniższe zapytania:
a) odczyt całej zawartości tabeli DOKUMENTY
b) odczyt treści dokumentu po zamianie na wielkie litery
c) odczyt rozmiaru dokumentu funkcją LENGTH
d) odczyt rozmiaru dokumentu odpowiednią funkcją z pakietu DBMS_LOB
e) odczyt 1000 znaków dokumentu począwszy od znaku na pozycji 5 funkcją SUBSTR
f) odczyt 1000 znaków dokumentu począwszy od znaku na pozycji 5 odpowiednią funkcją
z pakietu DBMS_LOB
*/

SELECT DOKUMENT FROM DOKUMENTY;
SELECT UPPER(DOKUMENT) FROM DOKUMENTY;
SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT DBMS_LOB.GETLENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT SUBSTR(DOKUMENT, 5, 1000) FROM DOKUMENTY;
SELECT DBMS_LOB.SUBSTR(DOKUMENT, 1000, 5) FROM DOKUMENTY;

/*
4. Wstaw do tabeli drugi dokument jako pusty obiekt CLOB nadając mu ID = 2.
*/

INSERT INTO DOKUMENTY VALUES (2, EMPTY_CLOB());

/*
5. Wstaw do tabeli trzeci dokument jako NULL nadając mu ID = 3. Zatwierdź transakcję.
*/

INSERT INTO DOKUMENTY VALUES (3, NULL);

/*
6. Sprawdź jaki będzie efekt zapytań z punktu 3 dla wszystkich trzech dokumentów.
*/

SELECT DOKUMENT FROM DOKUMENTY;
SELECT UPPER(DOKUMENT) FROM DOKUMENTY;
SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT DBMS_LOB.GETLENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT SUBSTR(DOKUMENT, 5, 1000) FROM DOKUMENTY;
SELECT DBMS_LOB.SUBSTR(DOKUMENT, 1000, 5) FROM DOKUMENTY;

/*
7. Napisz program w formie anonimowego bloku PL/SQL, który do dokumentu
o identyfikatorze 2 przekopiuje tekstową zawartość pliku dokument.txt znajdującego się
w katalogu systemu plików serwera udostępnionym przez obiekt DIRECTORY o nazwie
TPD_DIR do pustego w tej chwili obiektu CLOB w tabeli DOKUMENTY. Wykorzystaj
poniższy schemat postępowania:
1) Zadeklaruj w programie zmienną typu BFILE i zwiąż ją z plikiem tekstowym
w katalogu na serwerze.
2) Odczytaj z tabeli DOKUMENTY pusty obiekt CLOB do zmiennej (nie zapomnij
o klauzuli zakładającej blokadę na wierszu zawierającym obiekt CLOB,
który będzie modyfikowany).
3) Przekopiuj zawartość z BFILE do CLOB procedurą LOADCLOBFROMFILE
z pakietu DBMS_LOB (nie zapominając o otwarciu i zamknięciu pliku BFILE!).
Wskazówki: Pamiętaj aby parametry przekazywane w trybie IN OUT i OUT
przekazać jako zmienne. Wartości parametrów określających identyfikator zestawu
znaków źródła i kontekst językowy ustaw na 0. Wartość 0 identyfikatora zestawu
znaków źródła oznacza że jest on taki jak w bazie danych dla wykorzystywanego typu
dużego obiektu tekstowego.
*/

DECLARE
    v_bfile BFILE;
    v_clob CLOB;
BEGIN
    SELECT DOKUMENT INTO v_clob
    FROM DOKUMENTY
    WHERE ID = 2
    FOR UPDATE;
    v_bfile := BFILENAME('TPD_DIR', 'dokument.txt');
    DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY);
    DECLARE
        v_src_offset INTEGER := 1;
        v_dest_offset INTEGER := 1;
        v_csid INTEGER := 0;
        v_ctx INTEGER := 0;
    BEGIN
        DBMS_LOB.LOADCLOBFROMFILE(v_clob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile), v_dest_offset, v_src_offset, v_csid, v_ctx, v_ctx);
    END;
    DBMS_LOB.CLOSE(v_bfile);    
    COMMIT;
END;

/*
8. Do dokumentu o identyfikatorze 3 przekopiuj tekstową zawartość pliku dokument.txt
znajdującego się w katalogu systemu plików serwera (za pośrednictwem obiektu BFILE), tym
razem nie korzystając z PL/SQL, a ze zwykłego polecenia UPDATE z poziomu SQL.
Wskazówka: Od wersji Oracle 12.2 funkcje TO_BLOB i TO_CLOB zostały rozszerzone
o obsługę parametru typu BFILE.
(https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/TO_CLOB-bfile-
blob.html)
*/

UPDATE DOKUMENTY
SET DOKUMENT = TO_CLOB(BFILENAME('TPD_DIR', 'dokument.txt'))
WHERE ID = 3;

/*
9. Odczytaj zawartość tabeli DOKUMENTY
*/

SELECT * FROM DOKUMENTY;

/*
10. Odczytaj rozmiar wszystkich dokumentów z tabeli DOKUMENTY.
*/

SELECT ID, LENGTH(DOKUMENT) FROM DOKUMENTY;

/*
11. Usuń tabelę DOKUMENTY
*/

DROP TABLE DOKUMENTY;

/*
12. Zaimplementuj w PL/SQL procedurę CLOB_CENSOR, która w podanym jako pierwszy
parametr dużym obiekcie CLOB zastąpi wszystkie wystąpienia tekstu podanego jako drugi
parametr (typu VARCHAR2) kropkami, tak aby każdej zastępowanej literze odpowiadała
jedna kropka.
Wskazówka: Nie korzystaj z funkcji REPLACE (tylko z funkcji INSTR i procedury WRITE
z pakietu DBMS_LOB), tak aby procedura była zgodna z wcześniejszymi wersjami Oracle,
w których funkcja REPLACE była ograniczona do tekstów, których długość nie przekraczała
limitu dla VARCHAR2.
*/

CREATE OR REPLACE PROCEDURE CLOB_CENSOR(
    p_clob IN OUT CLOB,
    p_text IN VARCHAR2
) AS
    v_pos INTEGER;
    v_len INTEGER;
BEGIN
    v_pos := 1;
    v_len := LENGTH(p_text);
    WHILE v_pos > 0 LOOP
        v_pos := INSTR(p_clob, p_text, v_pos);
        IF v_pos > 0 THEN
            DBMS_LOB.WRITE(p_clob, v_len, v_pos, RPAD('.', v_len, '.'));
            v_pos := v_pos + v_len;
        END IF;
    END LOOP;
END;

/*
13. Utwórz w swoim schemacie kopię tabeli BIOGRAPHIES ze schematu ZTPD i przetestuj
swoją procedurę zastępując nazwisko „Cimrman” kropkami w biografii Jary Cimrmana.
*/

CREATE TABLE BIOGRAPHIES_COPY AS SELECT * FROM ZTPD.BIOGRAPHIES;

DECLARE
    v_biography CLOB;
BEGIN
    SELECT BIOGRAPHY INTO v_biography
    FROM BIOGRAPHIES_COPY
    WHERE FIRST_NAME = 'Jara' AND LAST_NAME = 'Cimrman'
    FOR UPDATE;
    CLOB_CENSOR(v_biography, 'Cimrman');
    UPDATE BIOGRAPHIES_COPY
    SET BIOGRAPHY = v_biography
    WHERE FIRST_NAME = 'Jara' AND LAST_NAME = 'Cimrman';
    COMMIT;
END;

/*
14. Usuń kopię tabeli BIOGRAPHIES ze swojego schematu.
*/

DROP TABLE BIOGRAPHIES_COPY;
