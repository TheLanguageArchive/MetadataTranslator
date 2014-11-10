<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tla="http://tla.mpi.nl"
	version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:template name="TLACOLLECTION2CORPUS">
        <METATRANSCRIPT xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"            
            FormatId="IMDI 3.0"
            Type="CORPUS"
            Version="0"
            xsi:schemaLocation="http://www.mpi.nl/IMDI/Schema/IMDI http://www.mpi.nl/IMDI/Schema/IMDI_3.0.xsd">            
            <xsl:attribute name="ArchiveHandle">
                <xsl:value-of select="tla:getHandle(//Header/MdSelfLink, 'imdi')"/>
            </xsl:attribute>            
            <xsl:attribute name="Originator">
                <xsl:value-of select="tla:create-originator('tlacollection2corpus.xslt', //Header/MdSelfLink)" />
            </xsl:attribute>
            <Corpus>
                <xsl:apply-templates select="//Corpus" mode="TLACOLLECTION2CORPUS"/>
                <xsl:apply-templates select="//ResourceProxy" mode="TLACOLLECTION2CORPUS"/>
            </Corpus>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="ResourceProxy" mode="TLACOLLECTION2CORPUS">
         <xsl:choose>
             <xsl:when test="child::ResourceType = 'Metadata'">
                 <CorpusLink>
                     <xsl:variable name="idref"><xsl:value-of select="@id" /></xsl:variable>
                     <xsl:attribute name="Name"><xsl:value-of select="//CorpusLink[@ref=$idref]/CorpusLinkContent/@Name"/></xsl:attribute>
                     <xsl:variable name="handle" select="substring-before(tla:getBaseHandle(ResourceRef),'@')"/>
                     <xsl:if test="string-length($handle) > 0">
                         <xsl:attribute name="ArchiveHandle" select="substring-before(tla:getBaseHandle(ResourceRef),'@')" />
                     </xsl:if>
                     <xsl:value-of select="//CorpusLink[@ref=$idref]/CorpusLinkContent"/>                     
                 </CorpusLink>
             </xsl:when>
          </xsl:choose> 
    </xsl:template>
    
    <xsl:template match="Corpus" mode="TLACOLLECTION2CORPUS">
        <Name>
            <xsl:value-of select="child::Name"/>
        </Name>
        <Title>
            <xsl:value-of select="child::Title"/>
        </Title>   
        <xsl:for-each select="child::descriptions/Description">
            <Description>
                <xsl:attribute name="LanguageId" select="@LanguageId" />
                <xsl:variable name="id"><xsl:value-of select="ancestor::Description/@ref" /></xsl:variable>
                <xsl:variable name="handle" select="tla:getBaseHandle(ancestor::Components/preceding-sibling::Resources/ResourceProxyList/ResourceProxy[@id=$id]/ResourceRef)"/>
                <xsl:choose>
                    <xsl:when  test="$handle">
                        <xsl:attribute name="ArchiveHandle">
                            <xsl:value-of select="concat('hdl:',$handle)"/>
                        </xsl:attribute>
                        <xsl:attribute name="Link">
                            <xsl:value-of select="ancestor::Components/preceding-sibling::Resources/ResourceProxyList/ResourceProxy[@id=$id]/ResourceRef/text()"/>
                        </xsl:attribute>
                    </xsl:when>       
                </xsl:choose>                
                <xsl:value-of select="."/>
            </Description>       
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>