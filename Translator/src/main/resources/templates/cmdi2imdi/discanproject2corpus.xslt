<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tla="http://tla.mpi.nl"
	version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/" 
    >
    
    <xsl:template name="DISCANPROJECT2CORPUS">
        <METATRANSCRIPT xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"            
            FormatId="IMDI 3.0"
            Type="CORPUS"
            Version="0"
            xsi:schemaLocation="http://www.mpi.nl/IMDI/Schema/IMDI http://www.mpi.nl/IMDI/Schema/IMDI_3.0.xsd">
            <xsl:attribute name="Date"><xsl:value-of select="$datum"/></xsl:attribute>
            <xsl:attribute name="ArchiveHandle">
                <xsl:value-of select="tla:getHandle(//Header/MdSelfLink, 'imdi')"/>
            </xsl:attribute>            
            <xsl:attribute name="Originator">
                <xsl:value-of select="tla:create-originator('discanproject2corpus.xslt', //Header/MdSelfLink)" />
            </xsl:attribute>
            <Corpus>
                <xsl:apply-templates select="//DiscAn_Project"/>
                <xsl:apply-templates select="//ResourceProxy" mode="COLLECTION2CORPUS"/>
            </Corpus>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="DiscAn_Project">
        <Name><xsl:value-of select="Project/ProjectName"/></Name>
        <Title><xsl:value-of select="Project/ProjectName"/></Title>
        <Description><xsl:value-of select="Project/ProjectTitle"/></Description>
        <MDGroup>
            <Location>
                <Continent>Europe</Continent>
                <Country>Netherlands</Country>
            </Location>
            <xsl:apply-templates select="Project"/>
            <Keys>
                <Key Name="Duration.StartYear"><xsl:value-of select="Project/Duration/StartYear"/></Key>
                <Key Name="Duration.CompletionYear"><xsl:value-of select="Project/Duration/CompletionYear"/></Key>
            </Keys>
            <Content>
                <Genre>Discourse</Genre>
                <CommunicationContext>
                </CommunicationContext>
                <Languages>
                </Languages>
                <Keys>
                    <Key Name="Annotation.AnnotationMode"><xsl:value-of select="Annotation/AnnotationMode"/></Key>
                    <Key Name="Annotation.AnnotationStandoff"><xsl:value-of select="Annotation/AnnotationStandoff"/></Key>
                    <Key Name="Annotation.AnnotationFormat"><xsl:value-of select="Annotation/AnnotationFormat"/></Key>
                    <xsl:apply-templates select="Annotation/SegmentationUnits/SegmentationUnit"/>
                    <Key Name="Annotation.SegmentationUnits.Description"><xsl:value-of select="Annotation/SegmentationUnits/Descriptions/Description"></xsl:value-of></Key>
                </Keys>
            </Content>
            <Actors>
            </Actors>
        </MDGroup>    
    </xsl:template>
    
    <xsl:template match="Project">
        <Project>
            <Name><xsl:value-of select="ProjectName"/></Name>
            <Title><xsl:value-of select="ProjectTitle"/></Title>
            <Id></Id>
            <!-- IMDI allows only one contact :( -->
            <Contact>
                <Name><xsl:value-of select="Contact[1]/Person"/></Name>
                <Address><xsl:value-of select="Contact[1]/Address"/></Address>
                <Email><xsl:value-of select="Contact[1]/Email"/></Email>
                <Organisation><xsl:value-of select="Contact[1]/Organisation" /></Organisation>
            </Contact>
        </Project>
    </xsl:template>
    
    <xsl:template match="SegmentationUnit">
        <Key Name="Annotation.SegmentationUnits.SegmentationUnit"><xsl:value-of select="."/></Key>
    </xsl:template>

</xsl:stylesheet>