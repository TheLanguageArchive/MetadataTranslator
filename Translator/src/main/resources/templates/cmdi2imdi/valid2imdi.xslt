<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tla="http://tla.mpi.nl" 
    version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:template name="VALID2IMDI">
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
                <xsl:value-of select="tla:create-originator('VALID2IMDI.xslt', //Header/MdSelfLink)" />
            </xsl:attribute>
            <Session>
                <xsl:apply-templates select="//Header" mode="VALID2IMDI"/>
                <xsl:apply-templates select="//VALID" mode="VALID2IMDI"/>
            </Session>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="Header" mode="VALID2IMDI"/>        
    
    <xsl:template match="VALID" mode="VALID2IMDI">
        <xsl:apply-templates select="Session" mode="VALID2IMDI"/>
    </xsl:template>
    
    <xsl:template match="Session" mode="VALID2IMDI">
        <Name>
            <xsl:choose>
                <xsl:when test="normalize-space(Name)!=''">
                    <xsl:value-of select="Name"/>                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Unspecified</xsl:text>
                </xsl:otherwise>
            </xsl:choose>            
        </Name>
        <Title>
            <xsl:value-of select="Title"/>
        </Title>
        <Date>
            <xsl:choose>
                <xsl:when test="normalize-space(Date)!=''">
                    <xsl:value-of select="Date"/>                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Unspecified</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </Date>
        <xsl:apply-templates select="Descriptions"/>
        
        <MDGroup>
            <xsl:apply-templates select="Location" mode="VALID2IMDI"/>
            <xsl:apply-templates select="Project" mode="VALID2IMDI"/>
            <Keys>
                <Key>
                    <xsl:attribute name="Name">ProjectStartYear</xsl:attribute>
                    <xsl:value-of select="Project/Duration/StartYear"></xsl:value-of>
                </Key>
                <Key>
                    <xsl:attribute name="Name">ProjectCompletionYear</xsl:attribute>
                    <xsl:value-of select="Project/Duration/CompletionYear"></xsl:value-of>
                </Key>                
            </Keys>
            <xsl:apply-templates select="Content" mode="VALID2IMDI"/>
            <Actors>
                <xsl:apply-templates select="//Actor" mode="VALID2IMDI"/>                
            </Actors>
        </MDGroup>
        <Resources>
            <xsl:apply-templates select="child::Resources" mode="VALID2IMDI"/>
        </Resources>
        <References>
        </References>
    </xsl:template>
    
    <xsl:template match="Project" mode="VALID2IMDI">
        <Project>
            <Name><xsl:value-of select="child::Name"/></Name>
            <Title><xsl:value-of select="child::Title"/></Title>
            <Id><xsl:value-of select="child::ID"/></Id>
            <Contact>
                <Name><xsl:value-of select="child::Contact/Person"/></Name>
                <Address><xsl:value-of select="child::Contact/Address" /></Address>
                <Email><xsl:value-of select="child::Contact/Email"/></Email>
                <Organisation><xsl:value-of select="child::Contact/Organisation"/></Organisation>
            </Contact>
            <xsl:apply-templates select="child::Descriptions"/>
            <Description><xsl:value-of select="//VALID/Description"/></Description>
        </Project>
    </xsl:template>
    
    <xsl:template match="Location" mode="VALID2IMDI">
        <Location>
            <Continent Link="http://www.mpi.nl/IMDI/Schema/Continents.xml" Type="ClosedVocabulary">
                <xsl:value-of select="Continent"/>
            </Continent>
            <Country Link="http://www.mpi.nl/IMDI/Schema/Countries.xml" Type="OpenVocabulary">
                <xsl:choose>
                    <xsl:when test="child::Country = 'NL'">Netherlands</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="Country"/>
                    </xsl:otherwise>
                </xsl:choose>                
            </Country>
            <Region><xsl:value-of select="child::Region"/></Region>
            <Address><xsl:value-of select="child::Address"/></Address>
        </Location>
    </xsl:template>
    
    <xsl:template match="Content" mode="VALID2IMDI">
        <Content>
            <Genre Link="http://www.mpi.nl/IMDI/Schema/Content-Genre.xml" Type="OpenVocabulary"><xsl:value-of select="child::Genre"/></Genre>
            <SubGenre Link="http://www.mpi.nl/IMDI/Schema/Content-SubGenre.xml" Type="OpenVocabularyList"><xsl:value-of select="child::SubGenre"/></SubGenre>
            <Task Link="http://www.mpi.nl/IMDI/Schema/Content-Task.xml" Type="OpenVocabulary"><xsl:value-of select="child::Task"/></Task>
            <Modalities Link="http://www.mpi.nl/IMDI/Schema/Content-Modalities.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Modalities"/></Modalities>
            <Subject Link="http://www.mpi.nl/IMDI/Schema/Content-Subject.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Subject"/></Subject>
            <CommunicationContext>
                <Interactivity Link="http://www.mpi.nl/IMDI/Schema/Content-Interactivity.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/Interactivity"/></Interactivity>
                <PlanningType Link="http://www.mpi.nl/IMDI/Schema/Content-PlanningType.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/PlanningType"/></PlanningType>
                <Involvement Link="http://www.mpi.nl/IMDI/Schema/Content-Involvement.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/Involvement"/></Involvement>
                <SocialContext Link="http://www.mpi.nl/IMDI/Schema/Content-SocialContext.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/SocialContext"/></SocialContext>
                <EventStructure Link="http://www.mpi.nl/IMDI/Schema/Content-EventStructure.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/EventStructure"/></EventStructure>
                <Channel Link="http://www.mpi.nl/IMDI/Schema/Content-Channel.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/Channel"/></Channel>
            </CommunicationContext>
            <Languages>
                <xsl:apply-templates select="Descriptions"/>
                <xsl:apply-templates select="descendant::Language" mode="CONTENT"/>
            </Languages>
            <Keys />
            <xsl:apply-templates select="Descriptions"/>
        </Content>
    </xsl:template>
    
    <xsl:template match="Actor" mode="VALID2IMDI">
        <Actor>
            <Role Link="http://www.mpi.nl/IMDI/Schema/Actor-Role.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Role"/></Role>
            <Name><xsl:value-of select="child::Name"/></Name>
            <FullName/>
            <Code />
            <FamilySocialRole Link="http://www.mpi.nl/IMDI/Schema/Actor-FamilySocialRole.xml" Type="OpenVocabularyList"><xsl:value-of select="child::FamilySocialRole"/></FamilySocialRole>
            <Languages>
                <xsl:apply-templates select="Descriptions"/>
                <xsl:apply-templates select="descendant::Language" mode="ACTOR"/>
            </Languages>
            <EthnicGroup/>
            <Age><xsl:value-of select="child::Age"/></Age>
            <BirthDate />
            <Sex Link="http://www.mpi.nl/IMDI/Schema/Actor-Sex.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Sex"/></Sex>
            <Education />
            <Anonymized Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary">Unspecified</Anonymized>
            <Contact>
                <Name><xsl:value-of select="child::Contact/Person"/></Name>
                <Address><xsl:value-of select="child::Contact/Address"/></Address>
                <Email><xsl:value-of select="child::Contact/Email"/></Email>
                <Organisation><xsl:value-of select="child::Contact/Organisation"/></Organisation>
            </Contact>
            <Keys />            
            <Description LanguageId="" Link=""/>
        </Actor>
    </xsl:template>
     
    <xsl:template match="Language" mode="ACTOR">
        <Language>
            <Id>ISO639-3:<xsl:value-of select="lower-case(child::LanguageID)"/></Id>
            <Name Link="http://www.mpi.nl/IMDI/Schema/MPI-Languages.xml" Type="OpenVocabulary"><xsl:value-of select="child::LanguageName"/></Name>
            <MotherTongue Type="ClosedVocabulary"><xsl:value-of select="lower-case(child::MotherTongue)"/></MotherTongue>
            <PrimaryLanguage Type="ClosedVocabulary"><xsl:value-of select="lower-case(child::PrimaryLanguage)"/></PrimaryLanguage>
            <xsl:apply-templates select="Descriptions"/>
        </Language>
    </xsl:template>    
    
    <xsl:template match="Language" mode="CONTENT">
        <Language>
            <Id>ISO639-3:<xsl:value-of select="lower-case(child::LanguageID)"/></Id>
            <Name Link="http://www.mpi.nl/IMDI/Schema/MPI-Languages.xml" Type="OpenVocabulary"><xsl:value-of select="child::LanguageName"/></Name>
            <Dominant Type="ClosedVocabulary"><xsl:value-of select="lower-case(child::Dominant)"/></Dominant>
            <SourceLanguage Type="ClosedVocabulary"><xsl:value-of select="lower-case(child::SourceLanguage)"/></SourceLanguage>
            <TargetLanguage Type="ClosedVocabulary"><xsl:value-of select="lower-case(child::TargetLanguage)"/></TargetLanguage>
            <xsl:apply-templates select="Descriptions"/>
        </Language>
    </xsl:template>
    
    <xsl:template match="Resources" mode="VALID2IMDI">
        <xsl:apply-templates select="MediaFile" mode="VALID2IMDI"/>
        <xsl:apply-templates select="WrittenResource" mode="VALID2IMDI"/>
        <xsl:apply-templates select="Source" mode="VALID2IMDI"/>
    </xsl:template>
    
    
    <xsl:template match="WrittenResource" mode="VALID2IMDI">
        <WrittenResource>
            <xsl:variable name="id"><xsl:value-of select="@ref" /></xsl:variable>
            <ResourceLink><xsl:apply-templates select="//Resources/ResourceProxyList/ResourceProxy[@id=$id]" mode="create-resource-link-content"/></ResourceLink>
            <MediaResourceLink/>
            <Date>Unspecified</Date>
            <Type Link="http://www.mpi.nl/IMDI/Schema/WrittenResource-Type.xml" Type="OpenVocabulary"><xsl:value-of select="child::Type"/></Type>
            <SubType Link="http://www.mpi.nl/IMDI/Schema/WrittenResource-SubType.xml" Type="OpenVocabularyList"><xsl:value-of select="child::SubType"/></SubType>
            <Format Link="http://www.mpi.nl/IMDI/Schema/WrittenResource-Format.xml" Type="OpenVocabulary"><xsl:value-of select="child::Format"/></Format>
            <Size/>
            <Validation>
                <Type Link="http://www.mpi.nl/IMDI/Schema/Validation-Type.xml" Type="ClosedVocabulary"/>
                <Methodology Link="http://www.mpi.nl/IMDI/Schema/Validation-Methodology.xml" Type="ClosedVocabulary"/>
                <Level>Unspecified</Level>
                <xsl:apply-templates select="Descriptions"/>
            </Validation>
            <Derivation Link="http://www.mpi.nl/IMDI/Schema/WrittenResource-Derivation.xml" Type="ClosedVocabulary"/>
            <CharacterEncoding/>
            <ContentEncoding/>
            <LanguageId><xsl:value-of select="child::LanguageId"/></LanguageId>
            <Anonymized Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary">Unspecified</Anonymized>
            <Access>
                <Availability><xsl:value-of select="child::Access/Availability"/></Availability>
                <Date>Unspecified</Date>
                <Owner/>
                <Publisher/>
                <Contact>
                    <Name><xsl:value-of select="child::Access/Contact/Person"/></Name>
                    <Address><xsl:value-of select="child::Access/Contact/Address"/></Address>
                    <Email><xsl:value-of select="child::Access/Contact/Email"/></Email>
                    <Organisation><xsl:value-of select="child::Access/Contact/Organisation"/></Organisation>
                </Contact>
                <Description LanguageId="" Link=""/>
            </Access>
            <xsl:apply-templates select="Descriptions"/>
            <Keys/>
        </WrittenResource>
    </xsl:template>
    
    <xsl:template match="MediaFile" mode="VALID2IMDI">
        <MediaFile>
            <xsl:variable name="id"><xsl:value-of select="@ref" /></xsl:variable>
            <ResourceLink><xsl:apply-templates select="//Resources/ResourceProxyList/ResourceProxy[@id=$id]" mode="create-resource-link-content"/></ResourceLink>
            <Type Link="http://www.mpi.nl/IMDI/Schema/MediaFile-Type.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Type"/></Type>
            <Format Link="http://www.mpi.nl/IMDI/Schema/MediaFile-Format.xml" Type="OpenVocabulary"/>
            <Size/>
            <Quality Link="http://www.mpi.nl/IMDI/Schema/Quality.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Quality"/></Quality>
            <RecordingConditions><xsl:value-of select="child::RecordingConditions"/></RecordingConditions>
            <TimePosition>
                <Start><xsl:choose>
                    <xsl:when test="string-length(child::SL-TimePositionAndDuration/Start) &gt; 0"><xsl:value-of select="child::SL-TimePositionAndDuration/Start"/></xsl:when>
                    <xsl:otherwise>Unspecified</xsl:otherwise>
                </xsl:choose></Start>
                <End><xsl:choose>
                    <xsl:when test="string-length(child::SL-TimePositionAndDuration/End) &gt; 0"><xsl:value-of select="child::SL-TimePositionAndDuration/End"/></xsl:when>
                    <xsl:otherwise>Unspecified</xsl:otherwise>
                </xsl:choose></End>
            </TimePosition>
            <Access>
                <Availability><xsl:value-of select="child::Access/Availability"/></Availability>
                <Date>Unspecified</Date>
                <Owner/>
                <Publisher/>
                <Contact>
                    <Name><xsl:value-of select="child::Access/Contact/Person"/></Name>
                    <Address><xsl:value-of select="child::Access/Contact/Address"/></Address>
                    <Email><xsl:value-of select="child::Access/Contact/Email"/></Email>
                    <Organisation><xsl:value-of select="child::Access/Contact/Organisation"/></Organisation>
                </Contact>
                <Description LanguageId="" Link=""/>
            </Access>
            <xsl:apply-templates select="Descriptions"/>
            <Keys/>
        </MediaFile>
    </xsl:template>
    
    <xsl:template match="Source" mode="VALID2IMDI">
        <Source>
            <Id><xsl:value-of select="child::Id"/></Id>
            <Format Link="http://www.mpi.nl/IMDI/Schema/Source-Format.xml" Type="OpenVocabulary"><xsl:value-of select="child::VideoTapeFormat"/></Format>
            <Quality><xsl:value-of select="child::Quality"/></Quality>
            <TimePosition>
                <Start><xsl:choose>
                    <xsl:when test="string-length(child::SL-TimePositionAndDuration/Start) &gt; 0"><xsl:value-of select="child::SL-TimePositionAndDuration/Start"/></xsl:when>
                    <xsl:otherwise>Unspecified</xsl:otherwise>
                </xsl:choose></Start>
                <End><xsl:choose>
                    <xsl:when test="string-length(child::SL-TimePositionAndDuration/End) &gt; 0"><xsl:value-of select="child::SL-TimePositionAndDuration/End"/></xsl:when>
                    <xsl:otherwise>Unspecified</xsl:otherwise>
                </xsl:choose></End>
            </TimePosition>
            <Access>
                <Availability/>
                <Date/>
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
            <xsl:apply-templates select="Descriptions"/>
            <Keys />            
        </Source>
    </xsl:template>
    
    <xsl:template match="Descriptions">
        <xsl:for-each select="child::Description">
            <Description><xsl:value-of select="current()/text()"/></Description>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>