<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tla="http://tla.mpi.nl" 
    version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:template name="LESLLA2IMDI">
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
                <xsl:value-of select="tla:create-originator('LESLLA2IMDI.xslt', //Header/MdSelfLink)" />
            </xsl:attribute>
            <Session>
                <xsl:apply-templates select="//Header" mode="LESLLA2IMDI"/>
                <xsl:apply-templates select="//LESLLA/Session" mode="LESLLA2IMDI"/>
            </Session>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="Header" mode="LESLLA2IMDI"/>        
    
    <xsl:template match="LESLLA/Session" mode="LESLLA2IMDI">
        <Name>
            <xsl:value-of select="Name"/>
        </Name>
        <Title/>
        <Date><xsl:choose>            
            <xsl:when test="Date != ''"><xsl:value-of select="tla:parse-leslla-date(Date)"/></xsl:when>
            <xsl:otherwise>Unspecified</xsl:otherwise>
        </xsl:choose></Date>
        <Description LanguageId="" Link="">
            <xsl:value-of select="Description/Description"/>
        </Description>
        <MDGroup>
            <xsl:apply-templates select="Location" mode="LESLLA2IMDI"/>
            <xsl:apply-templates select="Project" mode="LESLLA2IMDI"/>
            <xsl:apply-templates select="Content" mode="LESLLA2IMDI"/>
            <Actors>
                <xsl:apply-templates select="//ActorSigner-ChildLanguage" mode="LESLLA2IMDI"/>
                <xsl:apply-templates select="//ActorResearcher" mode="LESLLA2IMDI"/>
            </Actors>
        </MDGroup>
        <Resources>
            <xsl:apply-templates select="child::Resources" mode="LESLLA2IMDI"/>
        </Resources>
        <References>
        </References>
    </xsl:template>
    
    <xsl:template match="Project" mode="LESLLA2IMDI">
        <Project>
            <Name><xsl:value-of select="child::Name"/></Name>
            <Title><xsl:value-of select="child::Title"/></Title>
            <Id><xsl:value-of select="child::Id"/></Id>
            <Contact>
                <Name><xsl:value-of select="child::Contact/Person"/></Name>
                <Address><xsl:value-of select="child::Contact/Address" /></Address>
                <Email> <xsl:for-each select="child::Contact/Email">
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
                </xsl:for-each></Email>
                <Organisation><xsl:value-of select="child::Contact/Organisation"/></Organisation>
            </Contact>
            <Description LanguageId="" Link=""><xsl:value-of select="child::Description/Description"/></Description>           
        </Project>
        <Keys>
            <Key Name="Contact.Telephone"><xsl:value-of select="Contact/Telephone"/></Key>
            <Key Name="Contact.Website"><xsl:value-of select="Contact/Website"/></Key>
        </Keys>
    </xsl:template>
    
    <xsl:template match="Location" mode="LESLLA2IMDI">
        <Location>
            <Continent><xsl:value-of select="child::Continent"/></Continent>
            <Country><xsl:value-of select="child::Country"/></Country>
            <Region><xsl:value-of select="child::Region"/></Region>
            <Address><xsl:value-of select="child::Address"/></Address>
        </Location>
    </xsl:template>
    
    <xsl:template match="Content" mode="LESLLA2IMDI">
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
    
    <xsl:template match="ActorSigner-ChildLanguage" mode="LESLLA2IMDI">
        <Actor>
            <Role Link="http://www.mpi.nl/IMDI/Schema/Actor-Role.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Role"/></Role>
            <Name><xsl:value-of select="child::Pseudonym"/></Name>
            <FullName/>
            <Code />
            <FamilySocialRole Link="http://www.mpi.nl/IMDI/Schema/Actor-FamilySocialRole.xml" Type="OpenVocabularyList"><xsl:value-of select="child::FamilySocialRole"/></FamilySocialRole>
            <Languages>
                <Description LanguageId="" Link=""><xsl:value-of select="child::ActorLanguages/Description/Description"/></Description>
                <xsl:apply-templates select="descendant::ActorLanguage" mode="LESLLA2IMDI"/>
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
    
    
    <xsl:template match="ActorResearcher" mode="LESLLA2IMDI">
        <Actor>
            <Role Link="http://www.mpi.nl/IMDI/Schema/Actor-Role.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Role"/></Role>
            <Name><xsl:value-of select="child::FullName"/></Name>
            <FullName><xsl:value-of select="child::FullName"/></FullName>
            <Code />
            <FamilySocialRole Link="http://www.mpi.nl/IMDI/Schema/Actor-FamilySocialRole.xml" Type="OpenVocabularyList" />
            <Languages>
                <Description LanguageId="" Link=""><xsl:value-of select="child::ActorLanguages/Description/Description"/></Description>
                <xsl:apply-templates select="descendant::ActorLanguage" mode="LESLLA2IMDI"></xsl:apply-templates>
            </Languages>
            <EthnicGroup/>
            <Age />
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
    
    <xsl:template match="ActorLanguage" mode="LESLLA2IMDI">
        <Language>
            <Id>ISO639-3:<xsl:value-of select="child::Language/ISO639/iso-639-3-code"/></Id>
            <Name Link="http://www.mpi.nl/IMDI/Schema/MPI-Languages.xml" Type="OpenVocabulary"><xsl:value-of select="child::Language/LanguageName"/></Name>
            <MotherTongue Type="ClosedVocabulary"><xsl:value-of select="child::MotherTongue"/></MotherTongue>
            <PrimaryLanguage Type="ClosedVocabulary"><xsl:value-of select="child::PrimaryLanguage"/></PrimaryLanguage>
            <Description LanguageId="ISO639-2:eng" Link=""><xsl:value-of select="child::Description/Description"/></Description>
        </Language>
    </xsl:template>    
    
    <xsl:template match="Resources" mode="LESLLA2IMDI">
        <xsl:apply-templates select="//MediaFile" mode="LESLLA2IMDI"/>
        <xsl:apply-templates select="//AnnotationDocument" mode="LESLLA2IMDI"/>
        <xsl:apply-templates select="//SourceVideo" mode="LESLLA2IMDI"/>
    </xsl:template>
    
    
    <xsl:template match="AnnotationDocument" mode="LESLLA2IMDI">
        <WrittenResource>
            <xsl:variable name="id"><xsl:value-of select="@ref" /></xsl:variable>
            <ResourceLink><xsl:value-of select="ancestor::Components/preceding-sibling::Resources/ResourceProxyList/ResourceProxy[@id=$id]/ResourceRef" /></ResourceLink>
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
    
    <xsl:template match="MediaFile" mode="LESLLA2IMDI">
        <MediaFile>
            <xsl:variable name="id"><xsl:value-of select="@ref" /></xsl:variable>
            <ResourceLink><xsl:value-of select="ancestor::Components/preceding-sibling::Resources/ResourceProxyList/ResourceProxy[@id=$id]/ResourceRef" /></ResourceLink>
            <Type Link="http://www.mpi.nl/IMDI/Schema/MediaFile-Type.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Type"/></Type>
            <Format Link="http://www.mpi.nl/IMDI/Schema/MediaFile-Format.xml" Type="OpenVocabulary"/>
            <Size/>
            <Quality Link="http://www.mpi.nl/IMDI/Schema/Quality.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Quality"/></Quality>
            <RecordingConditions><xsl:value-of select="child::RecordingConditions"/></RecordingConditions>
            <TimePosition>
                <Start><xsl:choose>
                    <xsl:when test="string-length(child::TimePositionAndDuration/Start) &gt; 0"><xsl:value-of select="child::TimePositionAndDuration/Start"/></xsl:when>
                    <xsl:otherwise>Unspecified</xsl:otherwise>
                </xsl:choose></Start>
                <End><xsl:choose>
                    <xsl:when test="string-length(child::TimePositionAndDuration/End) &gt; 0"><xsl:value-of select="child::TimePositionAndDuration/End"/></xsl:when>
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
    
    <xsl:template match="SourceVideo" mode="LESLLA2IMDI">
        <Source>
            <Id><xsl:value-of select="child::Id"/></Id>
            <Format Link="http://www.mpi.nl/IMDI/Schema/Source-Format.xml" Type="OpenVocabulary"><xsl:value-of select="child::VideoTapeFormat"/></Format>
            <Quality><xsl:value-of select="child::Quality"/></Quality>
            <TimePosition>
                <Start><xsl:choose>
                    <xsl:when test="string-length(child::TimePositionAndDuration/Start) &gt; 0"><xsl:value-of select="child::TimePositionAndDuration/Start"/></xsl:when>
                    <xsl:otherwise>Unspecified</xsl:otherwise>
                </xsl:choose></Start>
                <End><xsl:choose>
                    <xsl:when test="string-length(child::TimePositionAndDuration/End) &gt; 0"><xsl:value-of select="child::TimePositionAndDuration/End"/></xsl:when>
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

    <xsl:function name="tla:parse-leslla-date">
        <xsl:param name="input-date" />
        <xsl:variable name="day" select="format-number(number(substring-before($input-date,'-')),'00')"/>
        <xsl:variable name="year" select="substring-after(substring-after($input-date,'-'),'-')"/>             
        <xsl:variable name="month">
            <xsl:choose>
                <xsl:when test="substring-before(substring-after($input-date,'-'),'-') = 'Jan'">01</xsl:when>
                <xsl:when test="substring-after($input-date,'-') = 'Feb'">02</xsl:when>
                <xsl:when test="substring-after($input-date,'-') = 'Mar'">03</xsl:when>
                <xsl:when test="substring-after($input-date,'-') = 'Apr'">04</xsl:when>
                <xsl:when test="substring-after($input-date,'-') = 'May'">05</xsl:when>
                <xsl:when test="substring-after($input-date,'-') = 'Jun'">06</xsl:when>
                <xsl:when test="substring-after($input-date,'-') = 'Jul'">07</xsl:when>
                <xsl:when test="substring-after($input-date,'-') = 'Aug'">08</xsl:when>
                <xsl:when test="substring-after($input-date,'-') = 'Sep'">09</xsl:when>
                <xsl:when test="substring-after($input-date,'-') = 'Oct'">10</xsl:when>
                <xsl:when test="substring-after($input-date,'-') = 'Nov'">11</xsl:when>
                <xsl:when test="substring-after($input-date,'-') = 'Dec'">12</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($year,'-',$month,'-',$day)"></xsl:value-of>
    </xsl:function>
    
</xsl:stylesheet>