/*
1. Utwórz w swoim schemacie kopię tabeli CYTATY ze schematu ZTPD.
*/

CREATE TABLE CYTATY AS
SELECT * FROM ZTPD.CYTATY;

/*
2. Znajdź w tabeli CYTATY za pomocą standardowego operatora LIKE cytaty, które
zawierają zarówno słowo ‘optymista’ jak i ‘pesymista’ ignorując wielkość liter.
*/
SELECT * 
FROM CYTATY 
WHERE UPPER(TEKST) LIKE '%OPTYMISTA%' 
AND UPPER(TEKST) LIKE '%PESYMISTA%';

/*
3. Utwórz indeks pełnotekstowy typu CONTEXT na kolumnie TEKST tabeli CYTATY przy
domyślnych preferencjach dla tworzonego indeksu.
*/

CREATE INDEX CYTATY_CTX ON CYTATY(TEKST) INDEXTYPE IS CTXSYS.CONTEXT;

/*
4. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
zarówno słowo ‘optymista’ jak i ‘pesymista’ (ignorując wielkość liter w tym i kolejnych
zapytaniach ze względu na charakterystykę indeksu).
*/

SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'optymista AND pesymista', 1) > 0;

/*
5. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowo
‘pesymista’, a nie zawierają słowa ‘optymista’.
*/

SELECT *
FROM CYTATY
where CONTAINS(TEKST, 'PESYMISTA - OPTYMISTA', 1) > 0;

/*
6. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowa
‘optymista’ i ‘pesymista’ w odległości maksymalnie 3 słów.
*/

SELECT * 
FROM CYTATY 
WHERE CONTAINS(TEKST, 'NEAR((pesymista, optymista),3)') > 0;

/*
7. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowa
‘optymista’ i ‘pesymista’ w odległości maksymalnie 10 słów.
*/

SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'NEAR((pesymista, optymista),10)') > 0;

/*
8. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowo
‘życie’ i jego odmiany. Niestety Oracle nie wspiera stemmingu dla języka polskiego. Dlatego
zamiast frazy ‘$życie’ „poratujemy się” szukaniem frazy ‘życi%’.
*/

SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0;

/*
9. Zmodyfikuj poprzednie zapytanie, tak by dla każdego pasującego cytatu wyświetlony
został stopień dopasowania (SCORE).
*/

SELECT TEKST, SCORE(1) AS SCORE
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0;

/*
10. Zmodyfikuj poprzednie zapytanie, tak by wyświetlony został tylko najlepiej pasujący
cytat (w przypadku „remisu” może zostać wyświetlony dowolny z najlepiej pasujących
cytatów).
*/

SELECT TEKST, SCORE(1) AS SCORE
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0
ORDER BY SCORE DESC
FETCH FIRST 1 ROW ONLY;

/*
11. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
słowo ‘problem’ za pomocą wzorca z „literówką”: ‘probelm’.
*/

SELECT * 
FROM CYTATY 
WHERE CONTAINS(TEKST,'FUZZY(PROBELM,,,N)', 1) > 0;

/*
12. Wstaw do tabeli CYTATY cytat Bertranda Russella 'To smutne, że głupcy są tacy pewni
siebie, a ludzie rozsądni tacy pełni wątpliwości.'. Zatwierdź transakcję.
*/

INSERT INTO CYTATY VALUES (2001,'Bertrand Russell', 'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.');

COMMIT;

/*
13. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
słowo ‘głupcy’. Jak wyjaśnisz wynik zapytania?
*/

SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'głupcy', 1) > 0;

/*
14. Odszukaj w swoim schemacie tabelę, która zawiera zawartość indeksu odwróconego na
tabeli CYTATY. Wyświetl jej zawartość zwracając uwagę na to, czy słowo ‘głupcy’ znajduje
się wśród poindeksowanych słów.
*/

SELECT *
FROM DR$CYTATY_CTX$I
where lower(TOKEN_TEXT) = 'głupcy';

/*
15. Indeks CONTEXT utworzony przy domyślnych preferencjach nie jest uaktualniany na
bieżąco. Możliwa jest synchronizacja na żądanie (poprzez procedurę) lub zgodnie z zadaną
polityką (poprzez preferencję ustawioną przy tworzeniu indeksu: po zatwierdzeniu transakcji,
z zadanym interwałem czasowym). Można też przebudować indeks usuwając go i tworząc
ponownie. Wadą tej opcji jest czas trwania operacji i czasowa niedostępność indeksu, ale z tej
opcji skorzystamy ze względu na jej prostotę.
*/

DROP INDEX CYTATY_CTX;

CREATE INDEX CYTATY_CTX ON CYTATY(TEKST) INDEXTYPE IS CTXSYS.CONTEXT;

/*
16. Sprawdź czy po przebudowaniu indeksu słowo ‘głupcy’ pojawiło się w indeksie
odwróconym, a następnie powtórz zapytanie z punktu 13.
*/

SELECT *
FROM DR$CYTATY_CTX$I
where lower(TOKEN_TEXT) = 'głupcy';

SELECT *
FROM CYTATY
WHERE CONTAINS(TEKST, 'głupcy', 1) > 0;

/*
17. Usuń indeks na tabeli CYTATY, a następnie samą tabelę CYTATY.
*/

DROP INDEX CYTATY_CTX;
DROP TABLE CYTATY;

/*
Zaawansowane indeksowanie i wyszukiwanie
*/

/*
1. Utwórz w swoim schemacie kopię tabeli QUOTES ze schematu ZTPD.
*/

CREATE TABLE QUOTES AS
SELECT * FROM ZTPD.QUOTES;

/*
2. Utwórz indeks pełnotekstowy typu CONTEXT na kolumnie TEXT tabeli QUOTES przy
domyślnych preferencjach.
*/

CREATE INDEX QUOTES_CTX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT;

/*
3. Tabela QUOTES zawiera teksty w języku angielskim, dla którego Oracle Text obsługuje
stemming. Sprawdź działanie operatora CONTAINS dla wzorców:
- ‘work’
- ‘$work’
- ‘working’
- ‘$working’
*/

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'work', 1) > 0;

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, '$work', 1) > 0;

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'working', 1) > 0;

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, '$working', 1) > 0;

/*
4. Spróbuj znaleźć w tabeli QUOTES wszystkie cytaty, które zawierają słowo ‘it’. Czy
system zwrócił jakieś wyniki? Dlaczego?
*/

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'it', 1) > 0;

/*
5. Sprawdź jakie stop listy dostępne są w systemie. Odpytaj w tym celu perspektywę
słownikową CTX_STOPLISTS. Jak myślisz, którą system wykorzystywał przy
dotychczasowych zapytaniach?
*/

SELECT *
FROM CTX_STOPLISTS;

/*
6. Sprawdź jakie słowa znajdują się na domyślnej stop liście. Odpytaj w tym celu
perspektywę słownikową CTX_STOPWORDS.
*/

SELECT *
FROM CTX_STOPWORDS

/*
7. Usuń indeks pełnotekstowy na tabeli QUOTES. Utwórz go ponownie wskazując, że przy
indeksowaniu ma być użyta dostępna w systemie pusta stop lista.
*/

DROP INDEX QUOTES_CTX;

CREATE INDEX QUOTES_CTX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS('STOPLIST CTXSYS.EMPTY_STOPLIST');

/*
8. Ponów zapytanie o wszystkie cytaty, które zawierają słowo ‘it’. Czy tym razem system
zwrócił jakieś wyniki?
*/

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'it', 1) > 0;

/*
9. Znajdź w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘humans’.
*/

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool AND humans', 1) > 0;

/*
10. Znajdź w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘computer’
*/

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool AND computer', 1) > 0;

/*
11. Spróbuj znaleźć w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘humans’ w jednym
zdaniu. Zinterpretuj komunikat o błędzie.
*/

SELECT *
FROM QUOTES 
WHERE CONTAINS(TEXT,'(fool AND humans) within SENTENCE',1) > 0;

/*
12. Usuń indeks pełnotekstowy na tabeli QUOTES.
*/

DROP INDEX QUOTES_CTX;

/*
13. Utwórz grupę sekcji bazującą na NULL_SECTION_GROUP, zawierającą dodatkowo
obsługę zdań i akapitów jako sekcji.
*/

BEGIN
    CTX_DDL.CREATE_SECTION_GROUP('QUOTES_SECTION_GROUP', 'NULL_SECTION_GROUP');
    CTX_DDL.ADD_SPECIAL_SECTION('QUOTES_SECTION_GROUP', 'SENTENCE');
    CTX_DDL.ADD_SPECIAL_SECTION('QUOTES_SECTION_GROUP', 'PARAGRAPH');
END;

/*
14. Utwórz ponownie indeks pełnotekstowy na tabeli QUOTES wskazując utworzoną grupę
sekcji obsługującą zdania i akapity.
*/

CREATE INDEX QUOTES_CTX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS('SECTION GROUP QUOTES_SECTION_GROUP');

/*
15. Sprawdź czy teraz działają wzorce odwołujące się do zdań szukając najpierw cytatów
zawierających w tym samym zdaniu słowa ‘fool’ i ‘humans’, a następnie ‘fool’ i ‘computer’.
*/

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool AND humans', 1) > 0;

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool AND computer', 1) > 0;

/*  
16. Znajdź w tabeli QUOTES wszystkie cytaty, które zawierają słowo ‘humans’. Czy system
zwrócił też cytaty zawierające ‘non-humans’? Dlaczego?
*/

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'humans', 1) > 0;

/*
17. Usuń indeks pełnotekstowy na tabeli QUOTES. Utwórz preferencję dla leksera (używając
BASIC_LEXER), wskazującą, że myślnik ma być traktowany jako część indeksowanych
tokenów (składnik słów tak jak litery). Utwórz ponownie indeks pełnotekstowy na tabeli
QUOTES wskazując utworzoną preferencję dla leksera.
*/

DROP INDEX QUOTES_CTX;

BEGIN
    CTX_DDL.CREATE_PREFERENCE('QUOTES_LEXER_PREF', 'BASIC_LEXER');
    CTX_DDL.SET_ATTRIBUTE('QUOTES_LEXER_PREF', 'PRINTJOIN', '-');
END;

CREATE INDEX QUOTES_CTX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS('LEXER QUOTES_LEXER_PREF');


/*
18. Ponów zapytanie o wszystkie cytaty, które zawierają słowo ‘humans’. Czy system tym
razem zwrócił też cytaty zawierające ‘non-humans’?
*/

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'humans', 1) > 0;

/*
19. Znajdź w tabeli QUOTES wszystkie cytaty, które zawierają frazę ‘non-humans’.
Wskazówka: myślnik we wzorcu należy „escape’ować” („skorzystać z sekwencji ucieczki”).
*/

SELECT *
FROM QUOTES
WHERE CONTAINS(TEXT, 'non\-humans', 1) > 0;

/*
20. Usuń swoją kopię tabeli QUOTES i utworzoną preferencję.
*/

DROP INDEX QUOTES_CTX;

DROP PREFERENCE QUOTES_LEXER_PREF;

DROP TABLE QUOTES;
