<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tla="http://tla.mpi.nl" 
    version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:template name="SOUNDBITES2IMDI">
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
                <xsl:value-of select="tla:create-originator('SOUNDBITES2IMDI.xslt', //Header/MdSelfLink)" />
            </xsl:attribute>
            <Session>
                <xsl:apply-templates select="//Header" mode="SOUNDBITES2IMDI"/>
                <xsl:apply-templates select="//Soundbites-recording" mode="SOUNDBITES2IMDI"/>
             <!--   <Resources>
                   <xsl:apply-templates select="//ResourceProxy" mode="SOUNDBITES2IMDI" />
                </Resources>-->
            </Session>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="Header" mode="SOUNDBITES2IMDI"/>        
    
    
    
    
    
    
    
    
    <xsl:template match="Soundbites-recording" mode="SOUNDBITES2IMDI">
        <Name>
            <xsl:choose>
                <xsl:when test="SESSION/Name = ''">Unknown Name</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="SESSION/Name"/>
                </xsl:otherwise>
            </xsl:choose>            
        </Name>
        <Title/>
        <Date><xsl:choose>            
            <xsl:when test="CreationYear != ''"><xsl:value-of select="CreationYear"/></xsl:when>
            <xsl:otherwise>Unspecified</xsl:otherwise>
        </xsl:choose></Date>
        <MDGroup>
            <xsl:apply-templates select="GeoLocation" mode="SOUNDBITES2IMDI"/>
            <Project>
                <Name>Meertens Collection: Soundbites</Name>
                <Title/>
                <Id/>
                <Contact>
                    <Name/>
                    <Address/>
                    <Email/>
                    <Organisation/>
                </Contact>
                <Description LanguageId="" Link=""/>
            </Project>
            <Keys>
                <Key Name="Rights"><xsl:value-of select="RightStmt/Rights"/></Key>
                <Key Name="Availability"><xsl:value-of select="RightStmt/Availability"/></Key>
            </Keys>
            <xsl:apply-templates select="SESSION/Content" mode="SOUNDBITES2IMDI"/>
            <Actors/>
        </MDGroup>
        <Resources>
            <xsl:apply-templates select="child::TechnicalMetadata" mode="SOUNDBITES2IMDI"/>
        </Resources>
        <References>
        </References>
    </xsl:template>
    

    
    <xsl:template match="GeoLocation" mode="SOUNDBITES2IMDI">
        <Location>
            <Continent Link="http://www.mpi.nl/IMDI/Schema/Continents.xml" Type="ClosedVocabulary">
                <xsl:choose>
                    <xsl:when test="child::Continent/Code = 'EU'">Europe</xsl:when>
                </xsl:choose>                
            </Continent>
            <Country Link="http://www.mpi.nl/IMDI/Schema/Countries.xml" Type="OpenVocabulary">
                <xsl:choose>
                    <xsl:when test="child::Country/Code = 'BE'">Belgium</xsl:when>
                    <xsl:when test="child::Country/Code = 'FR'">France</xsl:when>
                    <xsl:when test="child::Country/Code = 'NL'">Netherlands</xsl:when>
                </xsl:choose>
            </Country>
            <Region><xsl:value-of select="child::Municipality"/></Region>
            <Region><xsl:value-of select="child::Province"/></Region>
            <Address><xsl:value-of select="child::City"/></Address>
        </Location>
    </xsl:template>
    
    <xsl:template match="SESSION/Content" mode="SOUNDBITES2IMDI">
        <Content>
            <Genre Link="http://www.mpi.nl/IMDI/Schema/Content-Genre.xml" Type="OpenVocabulary"><xsl:value-of select="child::Genre"/></Genre>
            <SubGenre Link="http://www.mpi.nl/IMDI/Schema/Content-SubGenre.xml" Type="OpenVocabularyList"><xsl:value-of select="child::SubGenre"/></SubGenre>
            <Task Link="http://www.mpi.nl/IMDI/Schema/Content-Task.xml" Type="OpenVocabulary"><xsl:value-of select="child::Task"></xsl:value-of></Task>
            <Modalities Link="http://www.mpi.nl/IMDI/Schema/Content-Modalities.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Modality"/></Modalities>
            <Subject Link="http://www.mpi.nl/IMDI/Schema/Content-Subject.xml" Type="OpenVocabularyList">
                <xsl:for-each select="child::Topic">
                    <xsl:choose>
                        <xsl:when test="not(position() = last())">
                            <xsl:value-of select="." />
                            <xsl:if test="not(ends-with(.,','))">
                                <xsl:text>,</xsl:text>
                            </xsl:if>
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="." />
                        </xsl:otherwise>
                    </xsl:choose>                     
                </xsl:for-each></Subject>
            <CommunicationContext>
                <Interactivity Link="http://www.mpi.nl/IMDI/Schema/Content-Interactivity.xml" Type="ClosedVocabulary">Unspecified</Interactivity>
                <PlanningType Link="http://www.mpi.nl/IMDI/Schema/Content-PlanningType.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/PlanningType"/></PlanningType>
                <Involvement Link="http://www.mpi.nl/IMDI/Schema/Content-Involvement.xml" Type="ClosedVocabulary">Unspecified</Involvement>
                <SocialContext Link="http://www.mpi.nl/IMDI/Schema/Content-SocialContext.xml" Type="ClosedVocabulary">Unspecified</SocialContext>
                <EventStructure Link="http://www.mpi.nl/IMDI/Schema/Content-EventStructure.xml" Type="ClosedVocabulary">Unspecified</EventStructure>
                <Channel Link="http://www.mpi.nl/IMDI/Schema/Content-Channel.xml" Type="ClosedVocabulary">Unspecified</Channel>
            </CommunicationContext>
            <Languages>
                <Description LanguageId="" Link=""/>
                <Language>
                    <Id>ISO639-3:<xsl:value-of select="preceding-sibling::SubjectLanguages/SubjectLanguage/Language/ISO639/iso-639-3-code"/></Id>
                    <Name Link="http://www.mpi.nl/IMDI/Schema/MPI-Languages.xml" Type="OpenVocabulary"><xsl:value-of select="preceding-sibling::SubjectLanguages/SubjectLanguage/Language/LanguageName"/></Name>
                    <Dominant Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary">Unspecified</Dominant>
                    <SourceLanguage Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary">Unspecified</SourceLanguage>
                    <TargetLanguage Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary">Unspecified</TargetLanguage>
                    <Description LanguageId="" Link=""/>
                </Language>
            </Languages>
            <Keys />            
            <Description LanguageId="" Link=""/>
        </Content>
    </xsl:template>
    
    
    
    <xsl:template match="TechnicalMetadata" mode="SOUNDBITES2IMDI">
        <MediaFile>
            <xsl:variable name="id"><xsl:value-of select="@ref" /></xsl:variable>
            <ResourceLink><xsl:value-of select="ancestor::Components/preceding-sibling::Resources/ResourceProxyList/ResourceProxy[@id=$id]/ResourceRef" /></ResourceLink>
            <Type Link="http://www.mpi.nl/IMDI/Schema/MediaFile-Type.xml" Type="ClosedVocabulary"><xsl:value-of select="substring-before(child::MimeType,'/')" /></Type>
            <Format Link="http://www.mpi.nl/IMDI/Schema/MediaFile-Format.xml" Type="OpenVocabulary"><xsl:value-of select="child::MimeType" /></Format>
            <Size><xsl:value-of select="child::Size/TotalSize[last()]/Number" /><xsl:text> </xsl:text><xsl:value-of select="child::Size/TotalSize[last()]/SizeUnit" /></Size>
            <Quality Link="http://www.mpi.nl/IMDI/Schema/Quality.xml" Type="ClosedVocabulary">Unspecified</Quality>
            <RecordingConditions/>
            <TimePosition>
                <Start>Unspecified</Start>
                <End>Unspecified</End>
            </TimePosition>
            <Access>
                <Availability/>
                <Date>Unspecified</Date>
                <Owner/>
                <Publisher/>
                <Contact>
                    <Name/>
                    <Address/>
                    <Email/>
                    <Organisation/>
                </Contact>
                <Description LanguageId="" Link=""/>
            </Access>
            <Description LanguageId="" Link=""/>
            <Keys/>
        </MediaFile>
    </xsl:template>
    
    
</xsl:stylesheet>