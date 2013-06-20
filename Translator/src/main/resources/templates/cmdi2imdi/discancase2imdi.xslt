<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tla="http://tla.mpi.nl" 
    version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:template name="DISCANCASE2IMDI">
        <METATRANSCRIPT xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"            
            FormatId="IMDI 3.0"
            Type="SESSION"
            Version="0"
            xsi:schemaLocation="http://www.mpi.nl/IMDI/Schema/IMDI http://www.mpi.nl/IMDI/Schema/IMDI_3.0.xsd">
            <xsl:attribute name="Date"><xsl:value-of select="$datum"/></xsl:attribute>
            <xsl:attribute name="ArchiveHandle">
                <xsl:value-of select="tla:getHandle(//Header/MdSelfLink, 'imdi')"/>
            </xsl:attribute>
            <xsl:attribute name="Originator">
                <xsl:value-of select="tla:create-originator('discancase2imdi.xslt', //Header/MdSelfLink)" />
            </xsl:attribute>
            <Session>
                <xsl:apply-templates select="//Header" mode="DISCANCASE2IMDI"/>
                <xsl:apply-templates select="//Components/DiscAn_Case" mode="DISCANCASE2IMDI"/>
                <Resources>
                    <xsl:apply-templates select="//ResourceProxy" mode="DISCANCASE2IMDI" />
                </Resources>
            </Session>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="Header" mode="DISCANCASE2IMDI"/>        
    
    <xsl:template match="DiscAn_Case" mode="DISCANCASE2IMDI">
        <Name><xsl:value-of select="concat(DiscAn_AnnotatedFeatures/SubcorpusName, ' ', DiscAn_AnnotatedFeatures/FragmentID)"/></Name>
        <Title><xsl:value-of select="TextTitle"/></Title>
        <Date><xsl:value-of select="Source_DiscAn/Publication_DiscAn/PublicationDate"/></Date>
        <MDGroup>
            <Location>
                <Continent></Continent>
                <Country></Country>
            </Location>
            <Project>
                <Name><xsl:value-of select="ProjectName"/></Name>
                <Title>DiscAn: <xsl:value-of select="ProjectName"/></Title>
                <Id></Id>
                <Contact>
                </Contact>
            </Project>
            <Keys>
            </Keys>
            <Content>
                <Genre><xsl:value-of select="TextType" /></Genre>
                <CommunicationContext>
                </CommunicationContext>
                <Languages>
                    <xsl:for-each select="Language">
                        <Language>
                            <Id>ISO639-3:<xsl:value-of select="ISO639/iso-639-3-code"/></Id>
                            <Name><xsl:value-of select="LanguageName"/></Name>
                        </Language>
                    </xsl:for-each>
                </Languages>
                <Keys>
                    <Key Name="TotalSize.Number"><xsl:value-of select="TotalSize/Number"/></Key>
                    <Key Name="TotalSize.SizeUnit"><xsl:value-of select="TotalSize/SizeUnit"/></Key>
                    <Key Name="Source.SourceName"><xsl:value-of select="Source_DiscAn/SourceName"/></Key>
                    <xsl:for-each select="ModalityInfo/Modalities">
                        <Key Name="ModalityInfo.Modalities"><xsl:value-of select="."/></Key>
                    </xsl:for-each>
                    <!-- Add keys for all annotated features -->
                    <xsl:for-each select="DiscAn_AnnotatedFeatures/*">
                        <Key><xsl:attribute name="Name" select="concat('AnnotatedFeatures.', name(.))"></xsl:attribute><xsl:value-of select="."/></Key>
                    </xsl:for-each>                
                </Keys>
            </Content>
            <Actors>
                <Actor>
                    <Role>Author</Role>
                    <Name><xsl:value-of select="Author_DiscAn/Name"/></Name>
                    <FullName></FullName>
                    <Code></Code>
                    <FamilySocialRole></FamilySocialRole>
                    <Languages></Languages>
                    <EthnicGroup></EthnicGroup>
                    <Age></Age>
                    <BirthDate></BirthDate>
                    <Sex></Sex>
                    <Education></Education>
                    <Anonymized>false</Anonymized>
                    <Keys></Keys>
                </Actor>
            </Actors>
        </MDGroup>
    </xsl:template>
    
    <xsl:template match="ResourceProxy" mode="DISCANCASE2IMDI">
        <WrittenResource>
            <ResourceLink>
                <xsl:variable name="handle" select="tla:getBaseHandle(ResourceRef)"/>
                <xsl:choose>
                    <xsl:when  test="$handle">
                        <xsl:value-of select="concat('http://hdl.handle.net/',$handle)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ResourceRef"/>
                    </xsl:otherwise>
                </xsl:choose></ResourceLink>
            <MediaResourceLink></MediaResourceLink>
            <Date></Date>
            <Type>Annotation</Type>
            <SubType></SubType>
            <Format><xsl:value-of select="ResourceType/@mimetype"/></Format>
            <Size></Size>
            <Validation>
                <Type></Type>
                <Methodology></Methodology>
            </Validation>
            <Derivation></Derivation>
            <CharacterEncoding></CharacterEncoding>
            <ContentEncoding></ContentEncoding>
            <LanguageId></LanguageId>
            <Anonymized>false</Anonymized>
            <Access>
                <Availability></Availability>
                <Date></Date>
                <Owner></Owner>
                <Publisher></Publisher>
                <Contact>
                    <Name>Prof. dr. Ted Sanders</Name>
                    <Address>Trans 10, 3512 JK, Utrecht / Korte Nieuwstraat 2-4</Address>
                    <Email>T.J.M.Sanders@uu.nl</Email>
                    <Organisation>Utrecht University</Organisation>
                </Contact>
            </Access>
            <Keys></Keys>
        </WrittenResource>
    </xsl:template>
    
</xsl:stylesheet>