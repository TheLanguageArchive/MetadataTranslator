<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tla="http://tla.mpi.nl"
    xmlns:lat="http://lat.mpi.nl/" version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">

    <xsl:template name="COLLECTION2CORPUS">
        <METATRANSCRIPT xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" FormatId="IMDI 3.0" Type="CORPUS"
            Version="0"
            xsi:schemaLocation="http://www.mpi.nl/IMDI/Schema/IMDI http://www.mpi.nl/IMDI/Schema/IMDI_3.0.xsd">
            <xsl:attribute name="Date">
                <xsl:value-of select="$datum"/>
            </xsl:attribute>
            <xsl:attribute name="ArchiveHandle">
                <xsl:value-of select="tla:getHandle(//Header/MdSelfLink, 'imdi')"/>
            </xsl:attribute>
            <xsl:attribute name="Originator">
                <xsl:value-of
                    select="tla:create-originator('collection2corpus.xslt', //Header/MdSelfLink)"/>
            </xsl:attribute>
            <Corpus>
                <xsl:apply-templates select="//collection" mode="COLLECTION2CORPUS"/>
                <xsl:apply-templates select="//ResourceProxy" mode="COLLECTION2CORPUS"/>
            </Corpus>
        </METATRANSCRIPT>
    </xsl:template>

    <xsl:template match="ResourceProxy" mode="COLLECTION2CORPUS">
        <xsl:variable name="id" select="@id" />
        <xsl:if
            test="child::ResourceType = 'Metadata' and not(//CollectionInfo/Description[@ref=$id])">
            <CorpusLink Name="">
                <xsl:variable name="handle" select="tla:getHandle(ResourceRef, 'imdi')"/>
                <xsl:if test="string-length($handle) > 0">
                    <xsl:attribute name="ArchiveHandle" select="tla:getHandle(ResourceRef, 'imdi')"
                    />
                </xsl:if>
                <xsl:value-of select="tla:getTranslationUri(tla:getlocalURIorfallback(.), 'imdi')"/>
            </CorpusLink>
        </xsl:if>
    </xsl:template>

    <xsl:template match="collection" mode="COLLECTION2CORPUS">
        <Name>
            <xsl:value-of select="CollectionInfo/Name"/>
        </Name>
        <Title/>
        <xsl:for-each select="CollectionInfo/Description/Description">
            <Description>
                <xsl:attribute name="LanguageId" select="concat('ISO639-2:',@xml:lang)"/>
                <xsl:variable name="id">
                    <xsl:value-of select="ancestor::Description/@ref"/>
                </xsl:variable>
                <xsl:variable name="handle"
                    select="tla:getBaseHandle(ancestor::Components/preceding-sibling::Resources/ResourceProxyList/ResourceProxy[@id=$id]/ResourceRef)"/>
                <xsl:choose>
                    <xsl:when test="$handle">
                        <xsl:attribute name="ArchiveHandle">
                            <xsl:value-of select="concat('hdl:',$handle)"/>
                        </xsl:attribute>
                        <xsl:variable name="proxy" select="//ResourceProxy[@id eq $id]"/>
                        <xsl:variable name="localUri" select="$proxy/ResourceRef/@lat:localURI"/>
                        <xsl:if test="normalize-space($localUri) != ''">
                            <xsl:attribute name="Link">
                                <xsl:value-of select="resolve-uri($localUri, $source-location)"/>
                            </xsl:attribute>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="Link">
                            <xsl:value-of
                                select="ancestor::Components/preceding-sibling::Resources/ResourceProxyList/ResourceProxy[@id=$id]/ResourceRef/text()"
                            />
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="."/>
            </Description>
        </xsl:for-each>
        <xsl:if test="empty(CollectionInfo/Description/Description)">
            <Description/>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
