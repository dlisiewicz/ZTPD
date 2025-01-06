<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:template match="/">
        <html>
            <head>
                <title>Zespoły</title>
            </head>
            <body>
                <h1>ZESPOŁY:</h1>
                <ol>
                    <xsl:apply-templates select="/ZESPOLY/ROW" mode="list"/>
                </ol>
                <h2>Szczegóły Zespołów:</h2>
                <div>
                    <xsl:apply-templates select="/ZESPOLY/ROW" mode="details"/>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="ROW" mode="list">
        <li>
            <a href="#{ID_ZESP}">
                <xsl:value-of select="NAZWA"/>
            </a>
        </li>
    </xsl:template>
    <xsl:template match="ROW" mode="details">
        <h2 id="{ID_ZESP}">
            <xsl:value-of select="NAZWA"/>
        </h2>
        <p>
            <strong>Adres:</strong> <xsl:value-of select="ADRES"/>
        </p>
        <xsl:choose>
            <xsl:when test="count(PRACOWNICY/ROW) > 0">
                <h3>Pracownicy:</h3>
                <table border="1" cellpadding="5" cellspacing="0">
                    <thead>
                        <tr>
                            <th>ID Pracownika</th>
                            <th>Nazwisko</th>
                            <th>Etat</th>
                            <th>Zatrudniony</th>
                            <th>Płaca Podstawowa</th>
                            <th>Płaca Dodatkowa</th>
                            <th>Szef</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:apply-templates select="PRACOWNICY/ROW">
                            <xsl:sort select="NAZWISKO"/>
                        </xsl:apply-templates>
                    </tbody>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <p>Brak pracowników w tym zespole.</p>
            </xsl:otherwise>
        </xsl:choose>
        <p>Liczba pracowników: <xsl:value-of select="count(PRACOWNICY/ROW)"/></p>
    </xsl:template>
    <xsl:template match="ROW">
        <tr>
            <td><xsl:value-of select="ID_PRAC"/></td>
            <td><xsl:value-of select="NAZWISKO"/></td>
            <td><xsl:value-of select="ETAT"/></td>
            <td><xsl:value-of select="ZATRUDNIONY"/></td>
            <td><xsl:value-of select="PLACA_POD"/></td>
            <td><xsl:value-of select="PLACA_DOD"/></td>
            <td>
                <xsl:choose>
                    <xsl:when test="/ZESPOLY/ROW/PRACOWNICY/ROW[ETAT='DYREKTOR' and ID_PRAC != current()/ID_PRAC]">
                        <xsl:value-of select="/ZESPOLY/ROW/PRACOWNICY/ROW[ETAT='DYREKTOR' and ID_PRAC != current()/ID_PRAC]/NAZWISKO"/>
                    </xsl:when>
                    <xsl:otherwise>brak</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
