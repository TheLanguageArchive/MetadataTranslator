<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tla="http://tla.mpi.nl"
    xmlns:lat="http://lat.mpi.nl/"
	version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:template name="TLASESSION2IMDISESSION">
        <METATRANSCRIPT xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"            
            FormatId="IMDI 3.0"
            Type="SESSION"
            Version="0"
            xsi:schemaLocation="http://www.mpi.nl/IMDI/Schema/IMDI http://www.mpi.nl/IMDI/Schema/IMDI_3.0.xsd">            
            <xsl:attribute name="ArchiveHandle">
                <xsl:value-of select="tla:getHandleWithoutFormat(//Header/MdSelfLink, 'imdi')"/>
            </xsl:attribute>            
            <xsl:attribute name="Originator">
                <xsl:value-of select="tla:create-originator('TLASESSION2IMDISESSION.xslt', //Header/MdSelfLink)" />
            </xsl:attribute>
            <xsl:attribute name="Date">
                <xsl:value-of select="//Header/MdCreationDate" />
            </xsl:attribute>
            <Session>
                <xsl:apply-templates select="//lat-session" mode="TLASESSION2IMDISESSION"/>
                <xsl:for-each select="//ResourceProxy">
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
                
            </Session>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="ResourceProxy" mode="TLASESSION2IMDISESSION">
         <xsl:choose>
             <xsl:when test="child::ResourceType = 'Metadata'">
                 <CorpusLink>
                     <xsl:variable name="idref"><xsl:value-of select="@id" /></xsl:variable>
                     <xsl:attribute name="Name"><xsl:value-of select="//CorpusLink[@ref=$idref]/CorpusLinkContent/@Name"/></xsl:attribute>
                     <xsl:variable name="handle" select="tla:getHandleWithoutFormat(ResourceRef,'imdi')"/>
                     <xsl:if test="string-length($handle) > 0">
                         <xsl:attribute name="ArchiveHandle" select="tla:getHandleWithoutFormat(ResourceRef,'imdi')" />
                     </xsl:if>
                     <xsl:value-of select="//CorpusLink[@ref=$idref]/CorpusLinkContent"/>                     
                 </CorpusLink>
             </xsl:when>
          </xsl:choose> 
    </xsl:template>
    
    <xsl:template match="lat-session" mode="TLASESSION2IMDISESSION">
        <Name>
            <xsl:value-of select="child::Name"/>
        </Name>
        <Title>
            <xsl:value-of select="child::Title"/>
        </Title>   
        <Date>
            <xsl:value-of select="child::Date"/>
        </Date>
        <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>
        <xsl:apply-templates select="InfoLink" mode="TLASESSION2IMDISESSION"/>
        <MDGroup>
            <xsl:apply-templates select="Location" mode="TLASESSION2IMDISESSION"/>
            <xsl:apply-templates select="Project" mode="TLASESSION2IMDISESSION"/>
            <Keys />
            <xsl:apply-templates select="Content" mode="TLASESSION2IMDISESSION"/>
            <Actors>
                <xsl:apply-templates select="//Actor" mode="TLASESSION2IMDISESSION"/>                
            </Actors>
        </MDGroup>
        <xsl:apply-templates select="Resources" mode="TLASESSION2IMDISESSION"/>
        <References>
        </References>
    </xsl:template>
    
    <xsl:template match="Project" mode="TLASESSION2IMDISESSION">
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
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>  
        </Project>
    </xsl:template>
    
    <xsl:template match="Location" mode="TLASESSION2IMDISESSION">
        <Location>
            <Continent Link="http://www.mpi.nl/IMDI/Schema/Continents.xml" Type="ClosedVocabulary">
                <xsl:value-of select="child::Continent"/>
            </Continent>
            <Country Link="http://www.mpi.nl/IMDI/Schema/Countries.xml" Type="OpenVocabulary">
                <xsl:value-of select="child::Country"/>
            </Country>
            <Region><xsl:value-of select="child::Region"/></Region>
            <Address><xsl:value-of select="child::Address"/></Address>
        </Location>
    </xsl:template>
    
    <xsl:template match="Content" mode="TLASESSION2IMDISESSION">
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
                <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>  
                <xsl:apply-templates select="//Content_Language" mode="TLASESSION2IMDISESSION"/>
            </Languages>
            <Keys />            
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>  
        </Content>
    </xsl:template>
    
    <xsl:template match="Actor" mode="TLASESSION2IMDISESSION">
        <Actor>
            <Role Link="http://www.mpi.nl/IMDI/Schema/Actor-Role.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Role"/></Role>
            <Name><xsl:value-of select="child::Name"/></Name>
            <FullName><xsl:value-of select="child::FullName"/></FullName>
            <Code><xsl:value-of select="child::Code"/></Code>
            <FamilySocialRole Link="http://www.mpi.nl/IMDI/Schema/Actor-FamilySocialRole.xml" Type="OpenVocabularyList"><xsl:value-of select="child::FamilySocialRole"/></FamilySocialRole>
            <Languages>
                <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>  
                <xsl:apply-templates select="descendant::Actor_Language" mode="TLASESSION2IMDISESSION"/>
            </Languages>
            <EthnicGroup><xsl:value-of select="child::EthnicGroup"/></EthnicGroup>
            <Age><xsl:value-of select="child::Age"/></Age>
            <BirthDate><xsl:value-of select="child::BirthDate"/></BirthDate>
            <Sex Link="http://www.mpi.nl/IMDI/Schema/Actor-Sex.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Sex"/></Sex>
            <Education><xsl:value-of select="child::Education"/></Education>
            <Anonymized Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Anonymized"/></Anonymized>
            <xsl:apply-templates select="Contact" mode="TLASESSION2IMDISESSION"/>            
            <Keys />            
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>  
        </Actor>
    </xsl:template>
    
    <xsl:template match="Content_Language" mode="TLASESSION2IMDISESSION">
        <Language>
            <Id><xsl:value-of select="child::Id"/></Id>
            <Name Link="http://www.mpi.nl/IMDI/Schema/MPI-Languages.xml" Type="OpenVocabulary"><xsl:value-of select="child::Name"/></Name>
            <Dominant Type="ClosedVocabulary"><xsl:value-of select="child::Dominant"/></Dominant>
            <SourceLanguage Type="ClosedVocabulary"><xsl:value-of select="child::SourceLanguage"/></SourceLanguage>
            <TargetLanguage Type="ClosedVocabulary"><xsl:value-of select="child::TargetLanguage"/></TargetLanguage>            
            <xsl:apply-templates select="descriptions"/>
        </Language>
    </xsl:template>    
    
    <xsl:template match="Actor_Language" mode="TLASESSION2IMDISESSION">
        <Language>
            <Id><xsl:value-of select="child::Id"/></Id>
            <Name Link="http://www.mpi.nl/IMDI/Schema/MPI-Languages.xml" Type="OpenVocabulary"><xsl:value-of select="child::Name"/></Name>
            <MotherTongue Type="ClosedVocabulary"><xsl:value-of select="child::MotherTongue"/></MotherTongue>
            <PrimaryLanguage Type="ClosedVocabulary"><xsl:value-of select="child::PrimaryLanguage"/></PrimaryLanguage>
            <xsl:apply-templates select="descriptions"/>
        </Language>
    </xsl:template>
    
    <xsl:template match="Contact" mode="TLASESSION2IMDISESSION">
       <Contact>
           <Name><xsl:value-of select="Name"></xsl:value-of></Name>
           <Address><xsl:value-of select="Address"></xsl:value-of></Address>
           <Email><xsl:value-of select="Email"></xsl:value-of></Email>
           <Organisation><xsl:value-of select="Organisation"></xsl:value-of></Organisation>           
       </Contact>
    </xsl:template>
    
    <xsl:template match="Resources" mode="TLASESSION2IMDISESSION">
        <Resources>
            <xsl:apply-templates select="MediaFile" mode="TLASESSION2IMDISESSION"/>
            <xsl:apply-templates select="WrittenResource" mode="TLASESSION2IMDISESSION"/>
        </Resources>
    </xsl:template>
    
    <xsl:template match="descriptions" mode="TLASESSION2IMDISESSION">
        <xsl:for-each select="Description">
            <xsl:choose>
                <xsl:when test="normalize-space(.)!=''">                    
                    <Description>
                        <xsl:choose>
                            <xsl:when test="normalize-space(@xml:lang)!=''">
                                <xsl:attribute name="LanguageId" select="concat('ISO639-3:',@xml:lang)" /> <!-- this probably needs to be more sophisticated to cover all cases -->
                            </xsl:when>
                        </xsl:choose>                
                        <xsl:value-of select="."/>
                    </Description>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="InfoLink" mode="TLASESSION2IMDISESSION">
        <Description>
            <xsl:attribute name="ArchiveHandle"><xsl:value-of select="//ResourceProxy[@id eq current()/@ref]/ResourceRef/text()"/></xsl:attribute>
            <xsl:attribute name="Link"><xsl:value-of select="//ResourceProxy[@id eq current()/@ref]/ResourceRef/@lat:localURI"/></xsl:attribute>
            <xsl:value-of select="Description"/>
        </Description>
    </xsl:template>
    
    <xsl:template match="MediaFile" mode="TLASESSION2IMDISESSION">
        <MediaFile>
            <ResourceLink>
                <xsl:attribute name="ArchiveHandle"><xsl:value-of select="//ResourceProxy[@id eq current()/@ref]/ResourceRef/text()"/></xsl:attribute>
                <xsl:value-of select="//ResourceProxy[@id eq current()/@ref]/ResourceRef/@lat:localURI"/>
            </ResourceLink>
            <Type><xsl:value-of select="Type"/></Type>
            <Format><xsl:value-of select="Format"/></Format>
            <Size><xsl:value-of select="Size"/></Size>
            <Quality><xsl:value-of select="Quality"/></Quality>
            <RecordingConditions><xsl:value-of select="RecordingConditions"/></RecordingConditions>
            <TimePosition>
                <Start><xsl:value-of select="TimePosition/Start"/></Start>
                <End><xsl:value-of select="TimePosition/End"/></End>
            </TimePosition>
            <Access>
                <Availability><xsl:value-of select="Availability"/></Availability>
                <Date><xsl:value-of select="Date"/></Date>
                <Owner><xsl:value-of select="Owner"/></Owner>
                <Publisher><xsl:value-of select="Publisher"/></Publisher>
                <xsl:apply-templates select="Contact"/>
                <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>                
            </Access>
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>
            <xsl:apply-templates select="Keys" mode="TLASESSION2IMDISESSION"/>            
        </MediaFile>
    </xsl:template>
    
    <xsl:template match="WrittenResource" mode="TLASESSION2IMDISESSION">
        <WrittenResource>
            <ResourceLink>
                <xsl:attribute name="ArchiveHandle"><xsl:value-of select="//ResourceProxy[@id eq current()/@ref]/ResourceRef/text()"/></xsl:attribute>
                <xsl:value-of select="//ResourceProxy[@id eq current()/@ref]/ResourceRef/@lat:localURI"/>
            </ResourceLink>
            <MediaResourceLink></MediaResourceLink> <!-- to do -->            
            <Date><xsl:value-of select="Date"/></Date>
            <Type><xsl:value-of select="Type"/></Type>
            <SubType><xsl:value-of select="SubType"/></SubType>
            <Format><xsl:value-of select="Format"/></Format>
            <Size><xsl:value-of select="Size"/></Size>
            <Derivation><xsl:value-of select="Derivation"/></Derivation>
            <CharacterEncoding><xsl:value-of select="CharacterEncoding"/></CharacterEncoding>
            <ContentEncoding><xsl:value-of select="ContentEncoding"/></ContentEncoding>
            <LanguageId><xsl:value-of select="LanguageId"/></LanguageId>
            <Anonymized><xsl:value-of select="Anonymized"/></Anonymized>
            <Validation>
                <Type><xsl:value-of select="Type"/></Type>
                <Methodology><xsl:value-of select="Methodology"/></Methodology>
                <Level><xsl:value-of select="Level"/></Level>
                <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>
            </Validation>
            <Access>
                <Availability><xsl:value-of select="Availability"/></Availability>
                <Date><xsl:value-of select="Date"/></Date>
                <Owner><xsl:value-of select="Owner"/></Owner>
                <Publisher><xsl:value-of select="Publisher"/></Publisher>
                <xsl:apply-templates select="Contact"/>
                <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>                
            </Access>
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>
            <xsl:apply-templates select="Keys" mode="TLASESSION2IMDISESSION"/>
            
        </WrittenResource>
    </xsl:template>
    
    <xsl:template match="Keys" mode="TLASESSION2IMDISESSION">
        <Keys/> <!-- todo: handle Keys -->
    </xsl:template>
</xsl:stylesheet>