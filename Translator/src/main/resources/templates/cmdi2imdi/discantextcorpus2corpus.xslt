<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tla="http://tla.mpi.nl"
	version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/" 
    >
    
    <xsl:template name="DISCANTEXTCORPUS2CORPUS">
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
                <xsl:apply-templates select="//DiscAn_TextCorpus"/>
                <xsl:apply-templates select="//ResourceProxy" mode="COLLECTION2CORPUS"/>
            </Corpus>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="DiscAn_TextCorpus">
        <Name><xsl:value-of select="GeneralInfo/ResourceName"/></Name>
        <Title><xsl:value-of select="GeneralInfo/ResourceTitle"/></Title>
        <Description><xsl:value-of select="GeneralInfo/Descriptions/Description"/></Description>
        <MDGroup>
            <Location>
                <Continent>Europe</Continent>
                <Country>Netherlands</Country>
            </Location>
            <xsl:apply-templates select="Project"/>
            <Keys>
                <xsl:for-each select="Publications/Publication">
                    <Key Name="Publication.Description"><xsl:value-of select="Descriptions/Description"/></Key>
                </xsl:for-each>
            </Keys>
            <Content>
                <Genre>Discourse</Genre>
                <Modalities><xsl:value-of select="ModalityInfo/Modalities" /></Modalities>
                <CommunicationContext>
                </CommunicationContext>
                <Languages>
                    <xsl:apply-templates select="SubjectLanguages/SubjectLanguage" />
                </Languages>
                <Keys>
                    <Key Name="SizeInfo.TotalSize.Size"><xsl:value-of select="SizeInfo/TotalSize/Size"></xsl:value-of></Key>
                    <Key Name="SizeInfo.TotalSize.SizeUnit"><xsl:value-of select="SizeInfo/TotalSize/SizeUnit"></xsl:value-of></Key>
                    <Key Name="SizeInfo.TotalSize.Description"><xsl:value-of select="SizeInfo/TotalSize/Descriptions/Description"></xsl:value-of></Key>
                    <Key Name="Annotation.AnnotationMode"><xsl:value-of select="Creation/Annotation/AnnotationMode"></xsl:value-of></Key>
                    <Key Name="Annotation.AnnotationStandoff"><xsl:value-of select="Creation/Annotation/AnnotationStandoff"></xsl:value-of></Key>
                    <Key Name="Annotation.SegmentationUnits.SegmentationUnit"><xsl:value-of select="Creation/Annotation/SegmentationUnits/SegmentationUnit"></xsl:value-of></Key>
                    <Key Name="Annotation.AnnotationTypes.AnnotationType.AnnotationLevelType"><xsl:value-of select="Creation/Annotation/AnnotationTypes/AnnotationType/AnnotationLevelType"></xsl:value-of></Key>
                    <Key Name="CorpusContext.CorpusType"><xsl:value-of select="CorpusContext/CorpusType"/></Key>
                    <Key Name="CorpusContext.TemporalClassification"><xsl:value-of select="CorpusContext/TemporalClassification"/></Key>
                </Keys>
            </Content>
            <Actors>
                <xsl:apply-templates select="Creation/Creators/Creator/Contact" />
            </Actors>
        </MDGroup>    
    </xsl:template>
    
    <xsl:template match="Project">
        <Project>
            <Name><xsl:value-of select="ProjectTitle"/></Name>
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

    <xsl:template match="SubjectLanguage">
        <Language>
            <Id>ISO639-3:<xsl:value-of select="Language/ISO639/iso-639-3-code"/></Id>
            <Name><xsl:value-of select="Language/LanguageName"/></Name>
        </Language>
    </xsl:template>
    
    <xsl:template match="Creator/Contact">
        <Actor>
            <Role><xsl:value-of select="Role" /></Role>
            <Name><xsl:value-of select="Person" /></Name>
            <FullName><xsl:value-of select="Person" /></FullName>
            <Code></Code>
            <FamilySocialRole></FamilySocialRole>
            <Languages></Languages>
            <EthnicGroup></EthnicGroup>
            <Age></Age>
            <BirthDate></BirthDate>
            <Sex></Sex>
            <Education></Education>
            <Anonymized>false</Anonymized>
            <Keys>
                <Key Name="Address"><xsl:value-of select="Address" /></Key>
                <Key Name="Email"><xsl:value-of select="Email" /></Key>
                <Key Name="Department"><xsl:value-of select="Department" /></Key>
                <Key Name="Organisation"><xsl:value-of select="Organisation" /></Key>
                <Key Name="TelephoneNumber"><xsl:value-of select="TelephoneNumber" /></Key>
                <Key Name="FaxNumber"><xsl:value-of select="FaxNumber" /></Key>
                <Key Name="Url"><xsl:value-of select="Url" /></Key>
            </Keys>
        </Actor>
    </xsl:template>

</xsl:stylesheet>