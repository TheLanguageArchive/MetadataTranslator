<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tla="http://tla.mpi.nl" 
    version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:template name="SLTLA2IMDI">
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
                <xsl:value-of select="tla:create-originator('SLTLA2IMDI.xslt', //Header/MdSelfLink)" />
            </xsl:attribute>
            <Session>
                <xsl:apply-templates select="//Header" mode="SLTLA2IMDI"/>
                <xsl:apply-templates select="//SL-TLA" mode="SLTLA2IMDI"/>
            </Session>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="Header" mode="SLTLA2IMDI"/>        
    
    <xsl:template match="SL-TLA" mode="SLTLA2IMDI">
        <Name>
            <xsl:value-of select="ElicitationMaterialName"/>
        </Name>
        <Title/>
        <Date><xsl:value-of select="$datum"/></Date>
        <Description LanguageId="" Link="">
            <xsl:value-of select="SL-Session/Description/Description"/>
        </Description>
        <MDGroup>
            <xsl:apply-templates select="Location" mode="SLTLA2IMDI"/>
            <xsl:apply-templates select="Project" mode="SLTLA2IMDI"/>
            <Keys />
            <xsl:apply-templates select="SL-ContentElicitation" mode="SLTLA2IMDI"/>
            <Actors>
                <xsl:apply-templates select="//SL-ActorSigner-ChildLanguage" mode="SLTLA2IMDI"/>
                <xsl:apply-templates select="//SL-ActorResearcher" mode="SLTLA2IMDI"/>
            </Actors>
        </MDGroup>
        <Resources>
            <xsl:apply-templates select="child::SL-Resources" mode="SLTLA2IMDI"/>
        </Resources>
        <References>
        </References>
    </xsl:template>
    
    <xsl:template match="Project" mode="SLTLA2IMDI">
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
            <Description LanguageId="" Link=""><xsl:value-of select="child::Description/Description"/></Description>
        </Project>
    </xsl:template>
    
    <xsl:template match="Location" mode="SLTLA2IMDI">
        <Location>
            <Continent Link="http://www.mpi.nl/IMDI/Schema/Continents.xml" Type="ClosedVocabulary">
                <xsl:choose>
                    <xsl:when test="child::Country/Code = 'AS'">Asia</xsl:when>
                    <xsl:when test="child::Continent/Code = 'EU'">Europe</xsl:when>
                    <xsl:when test="child::Continent/Code = 'NA'">North-America</xsl:when>
                    <xsl:when test="child::Country/Code = 'OC'">Oceania</xsl:when>
                </xsl:choose>                
            </Continent>
            <Country Link="http://www.mpi.nl/IMDI/Schema/Countries.xml" Type="OpenVocabulary">
                <xsl:choose>
                    <xsl:when test="child::Country/Code = 'AU'">Australia</xsl:when>
                    <xsl:when test="child::Country/Code = 'BE'">Belgium</xsl:when>
                    <xsl:when test="child::Country/Code = 'DE'">Germany</xsl:when>
                    <xsl:when test="child::Country/Code = 'DK'">Denmark</xsl:when>
                    <xsl:when test="child::Country/Code = 'ES'">Spain</xsl:when>
                    <xsl:when test="child::Country/Code = 'GB'">United Kingdom</xsl:when>
                    <xsl:when test="child::Country/Code = 'GR'">Greece</xsl:when>
                    <xsl:when test="child::Country/Code = 'IS'">Israel</xsl:when>
                    <xsl:when test="child::Country/Code = 'IT'">Italy</xsl:when>                    
                    <xsl:when test="child::Country/Code = 'NL'">Netherlands</xsl:when>                    
                    <xsl:when test="child::Country/Code = 'SA'">Saudi Arabia</xsl:when>
                    <xsl:when test="child::Country/Code = 'SE'">Sweden</xsl:when>
                    <xsl:when test="child::Country/Code = 'TR'">Turkey</xsl:when>
                    <xsl:when test="child::Country/Code = 'US'">United States</xsl:when>                    
                </xsl:choose>
            </Country>
            <Region><xsl:value-of select="child::Region"/></Region>
            <Address><xsl:value-of select="child::Address"/></Address>
        </Location>
    </xsl:template>
    
    <xsl:template match="SL-ContentElicitation" mode="SLTLA2IMDI">
        <Content>
            <Genre Link="http://www.mpi.nl/IMDI/Schema/Content-Genre.xml" Type="OpenVocabulary"><xsl:value-of select="child::Genre"/></Genre>
            <SubGenre Link="http://www.mpi.nl/IMDI/Schema/Content-SubGenre.xml" Type="OpenVocabularyList"><xsl:value-of select="child::SubGenre"/></SubGenre>
            <Task Link="http://www.mpi.nl/IMDI/Schema/Content-Task.xml" Type="OpenVocabulary" />
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
                <Description LanguageId="" Link=""/>
            </Languages>
            <Keys />            
            <Description LanguageId="" Link=""><xsl:value-of select="child::Description/Description"/></Description>
        </Content>
    </xsl:template>
    
    <xsl:template match="SL-ActorSigner-ChildLanguage" mode="SLTLA2IMDI">
        <Actor>
            <Role Link="http://www.mpi.nl/IMDI/Schema/Actor-Role.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Role"/></Role>
            <Name><xsl:value-of select="child::Pseudonym"/></Name>
            <FullName/>
            <Code />
            <FamilySocialRole Link="http://www.mpi.nl/IMDI/Schema/Actor-FamilySocialRole.xml" Type="OpenVocabularyList"><xsl:value-of select="child::FamilySocialRole"/></FamilySocialRole>
            <Languages>
                <Description LanguageId="" Link=""><xsl:value-of select="child::ActorLanguages/Description/Description"/></Description>
                <xsl:apply-templates select="descendant::ActorLanguage" mode="SLTLA2IMDI"/>
            </Languages>
            <EthnicGroup/>
            <Age><xsl:value-of select="child::Age"/></Age>
            <BirthDate />
            <Sex Link="http://www.mpi.nl/IMDI/Schema/Actor-Sex.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Sex"/></Sex>
            <Education />
            <Anonymized Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary">Unspecified</Anonymized>
            <Contact>
                <Name/>
                <Address/>
                <Email/>
                <Organisation/>
            </Contact>
            <Keys />            
            <Description LanguageId="" Link=""/>
        </Actor>
    </xsl:template>
    
    <xsl:template match="SL-ActorSpeakerSigner" mode="SLTLA2IMDI">
        <Actor>
            <Role Link="http://www.mpi.nl/IMDI/Schema/Actor-Role.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Role"/></Role>
            <Name><xsl:value-of select="child::Pseudonym"/></Name>
            <FullName/>
            <Code />
            <FamilySocialRole Link="http://www.mpi.nl/IMDI/Schema/Actor-FamilySocialRole.xml" Type="OpenVocabularyList"><xsl:value-of select="child::FamilySocialRole"/></FamilySocialRole>
            <Languages>
                <Description LanguageId="" Link=""><xsl:value-of select="child::ActorLanguages/Description/Description"/></Description>
                <xsl:apply-templates select="descendant::ActorLanguage" mode="SLTLA2IMDI"/>
            </Languages>
            <EthnicGroup/>
            <Age><xsl:value-of select="child::Age"/></Age>
            <BirthDate />
            <Sex Link="http://www.mpi.nl/IMDI/Schema/Actor-Sex.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Sex"/></Sex>
            <Education />
            <Anonymized Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary">Unspecified</Anonymized>
            <Contact>
                <Name/>
                <Address/>
                <Email/>
                <Organisation/>
            </Contact>
            <Keys />            
            <Description LanguageId="" Link=""/>
        </Actor>
    </xsl:template>
    
    <xsl:template match="SL-ActorResearcher" mode="SLTLA2IMDI">
        <Actor>
            <Role Link="http://www.mpi.nl/IMDI/Schema/Actor-Role.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Role"/></Role>
            <Name><xsl:value-of select="child::FullName"/></Name>
            <FullName><xsl:value-of select="child::FullName"/></FullName>
            <Code />
            <FamilySocialRole Link="http://www.mpi.nl/IMDI/Schema/Actor-FamilySocialRole.xml" Type="OpenVocabularyList" />
            <Languages>
                <Description LanguageId="" Link=""><xsl:value-of select="child::ActorLanguages/Description/Description"/></Description>
                <xsl:apply-templates select="descendant::ActorLanguage" mode="SLTLA2IMDI"></xsl:apply-templates>
            </Languages>
            <EthnicGroup/>
            <Age>Unknown</Age>
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
            <Description LanguageId="" Link=""><xsl:value-of select="child::Description/Description"/></Description>
        </Actor>
    </xsl:template>
    
    <xsl:template match="ActorLanguage" mode="SLTLA2IMDI">
        <Language>
            <Id>ISO639-3:<xsl:value-of select="child::Language/ISO639/iso-639-3-code"/></Id>
            <Name Link="http://www.mpi.nl/IMDI/Schema/MPI-Languages.xml" Type="OpenVocabulary"><xsl:value-of select="child::Language/LanguageName"/></Name>
            <MotherTongue Type="ClosedVocabulary">
                <xsl:call-template name="orUnspecified">
                    <xsl:with-param name="value" select="child::MotherTongue"/>
                </xsl:call-template>            
            </MotherTongue>
            <PrimaryLanguage Type="ClosedVocabulary">
                <xsl:call-template name="orUnspecified">
                    <xsl:with-param name="value" select="child::PrimaryLanguage"/>
                </xsl:call-template>                
            </PrimaryLanguage>
            <Description LanguageId="ISO639-2:eng" Link=""><xsl:value-of select="child::Description/Description"/></Description>
        </Language>
    </xsl:template>    
    
    <xsl:template match="SL-Resources" mode="SLTLA2IMDI">
        <xsl:apply-templates select="SL-MediaFile" mode="SLTLA2IMDI"/>
        <xsl:apply-templates select="SL-AnnotationDocument" mode="SLTLA2IMDI"/>
        <xsl:apply-templates select="SL-SourceVideo" mode="SLTLA2IMDI"/>
    </xsl:template>
    
    
    <xsl:template match="SL-AnnotationDocument" mode="SLTLA2IMDI">
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
                <Description LanguageId="" Link=""/>
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
            <Description LanguageId="" Link=""><xsl:value-of select="child::Description/Description"/></Description>
            <Keys/>
        </WrittenResource>
    </xsl:template>
    
    <xsl:template match="SL-MediaFile" mode="SLTLA2IMDI">
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
            <Description LanguageId="" Link=""><xsl:value-of select="child::Description/Description"/></Description>
            <Keys/>
        </MediaFile>
    </xsl:template>
    
    <xsl:template match="SL-SourceVideo" mode="SLTLA2IMDI">
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
            <Description LanguageId="" Link=""><xsl:value-of select="child::Description/Description"/></Description>
            <Keys />            
        </Source>
    </xsl:template>
    
    <xsl:template name="orUnspecified">
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="normalize-space($value)!=''">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Unspecified</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>