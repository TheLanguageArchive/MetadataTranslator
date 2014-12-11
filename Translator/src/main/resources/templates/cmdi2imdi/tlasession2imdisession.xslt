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
            <xsl:apply-templates select="//lat-session" mode="TLASESSION2IMDISESSION"/>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="lat-session" mode="TLASESSION2IMDISESSION">
        <xsl:choose>
            <xsl:when test="normalize-space(child::History)!=''">
                <History>
                    <xsl:value-of select="child::History"/>
                </History>
            </xsl:when>
        </xsl:choose>
        <Session>
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
                <Keys>
                <xsl:apply-templates select="Keys" mode="TLASESSION2IMDISESSION"/>
                </Keys>
                <xsl:apply-templates select="Content" mode="TLASESSION2IMDISESSION"/>
                <Actors>
                    <xsl:apply-templates select="Actors/descriptions" mode="TLASESSION2IMDISESSION"/> 
                    <xsl:apply-templates select="Actors/Actor" mode="TLASESSION2IMDISESSION"/>                
                </Actors>
            </MDGroup>
            <xsl:apply-templates select="Resources" mode="TLASESSION2IMDISESSION"/>
            <References />
        </Session>
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
            <xsl:if test="normalize-space(child::SubGenre)!=''">
                <!-- removed the following attributes: 
                            Link="http://www.mpi.nl/IMDI/Schema/Content-SubGenre.xml" Type="OpenVocabularyList"
                     because the subgenre link depends on the selected genre
                    -->
                <SubGenre><xsl:value-of select="child::SubGenre"/></SubGenre>
            </xsl:if>
            <xsl:if test="normalize-space(child::Task)!=''">
                <Task Link="http://www.mpi.nl/IMDI/Schema/Content-Task.xml" Type="OpenVocabulary"><xsl:value-of select="child::Task" /></Task>
            </xsl:if>
            <xsl:if test="normalize-space(child::Modalities)!=''"> 
                <Modalities Link="http://www.mpi.nl/IMDI/Schema/Content-Modalities.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Modalities"/></Modalities>
            </xsl:if>
            <xsl:if test="normalize-space(child::Subject)!=''">
                <Subject Link="http://www.mpi.nl/IMDI/Schema/Content-Subject.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Subject"/></Subject>
            </xsl:if>
            <CommunicationContext>
                <Interactivity Link="http://www.mpi.nl/IMDI/Schema/Content-Interactivity.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/Interactivity"/></Interactivity>
                <PlanningType Link="http://www.mpi.nl/IMDI/Schema/Content-PlanningType.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/PlanningType"/></PlanningType>
                <Involvement Link="http://www.mpi.nl/IMDI/Schema/Content-Involvement.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/Involvement"/></Involvement>
                <SocialContext Link="http://www.mpi.nl/IMDI/Schema/Content-SocialContext.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/SocialContext"/></SocialContext>
                <EventStructure Link="http://www.mpi.nl/IMDI/Schema/Content-EventStructure.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/EventStructure"/></EventStructure>
                <Channel Link="http://www.mpi.nl/IMDI/Schema/Content-Channel.xml" Type="ClosedVocabulary"><xsl:value-of select="child::CommunicationContext/Channel"/></Channel>
            </CommunicationContext>
            <Languages>
                <xsl:apply-templates select="//Content_Language" mode="TLASESSION2IMDISESSION"/>
            </Languages>
            <Keys>
            <xsl:apply-templates select="Keys" mode="TLASESSION2IMDISESSION"/>           
            </Keys>
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>  
        </Content>
    </xsl:template>
    
    <xsl:template match="Actor" mode="TLASESSION2IMDISESSION">
        <Actor>
            <xsl:if test="@ref">
                <xsl:attribute name="ResourceRef" select="@ref" />
            </xsl:if>
            
            <Role Link="http://www.mpi.nl/IMDI/Schema/Actor-Role.xml" Type="OpenVocabularyList"><xsl:value-of select="child::Role"/></Role>
            <Name><xsl:value-of select="child::Name"/></Name>
            <FullName><xsl:value-of select="child::FullName"/></FullName>
            <Code><xsl:value-of select="child::Code"/></Code>
            <FamilySocialRole Link="http://www.mpi.nl/IMDI/Schema/Actor-FamilySocialRole.xml" Type="OpenVocabularyList"><xsl:value-of select="child::FamilySocialRole"/></FamilySocialRole>
            <Languages>
                <xsl:apply-templates select="Actor_Languages/descriptions" mode="TLASESSION2IMDISESSION"/>  
                <xsl:apply-templates select="descendant::Actor_Language" mode="TLASESSION2IMDISESSION"/>
            </Languages>
            <EthnicGroup><xsl:value-of select="child::EthnicGroup"/></EthnicGroup>
            <Age><xsl:value-of select="child::Age"/></Age>
            <BirthDate><xsl:value-of select="child::BirthDate"/></BirthDate>
            <Sex Link="http://www.mpi.nl/IMDI/Schema/Actor-Sex.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Sex"/></Sex>
            <Education><xsl:value-of select="child::Education"/></Education>
            <Anonymized Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Anonymized"/></Anonymized>
            <Contact><xsl:apply-templates select="Contact" mode="TLASESSION2IMDISESSION"/></Contact>
            <Keys>
                <xsl:apply-templates select="Keys" mode="TLASESSION2IMDISESSION"/>
            </Keys>
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>  
        </Actor>
    </xsl:template>
    
    <xsl:template match="Content_Language" mode="TLASESSION2IMDISESSION">
        <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>  
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
            <Name><xsl:value-of select="child::Name"/></Name>
            <MotherTongue Type="ClosedVocabulary"><xsl:value-of select="child::MotherTongue"/></MotherTongue>
            <PrimaryLanguage Type="ClosedVocabulary"><xsl:value-of select="child::PrimaryLanguage"/></PrimaryLanguage>
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>
        </Language>
    </xsl:template>
    
    
    <xsl:template match="Access" mode="TLASESSION2IMDISESSION">
        <Access>
            <Availability><xsl:value-of select="Availability"/></Availability>
            <Date><xsl:value-of select="Date"/></Date>
            <Owner><xsl:value-of select="Owner"/></Owner>
            <Publisher><xsl:value-of select="Publisher"/></Publisher>
            <Contact><xsl:apply-templates select="Contact" mode="TLASESSION2IMDISESSION"/></Contact>
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>                
        </Access>
    </xsl:template>

    <xsl:template match="Contact" mode="TLASESSION2IMDISESSION">
       <xsl:if test="normalize-space(Name)!=''">
        <Name><xsl:value-of select="Name" /></Name>
       </xsl:if>
       <xsl:if test="normalize-space(Address)!=''">
           <Address><xsl:value-of select="Address"/></Address>
       </xsl:if>
       <xsl:if test="normalize-space(Email)!=''">
           <Email><xsl:value-of select="Email"/></Email>
       </xsl:if>
       <xsl:if test="normalize-space(Organisation)!=''">
           <Organisation><xsl:value-of select="Organisation"/></Organisation>
       </xsl:if>       
    </xsl:template>
    
    <xsl:template match="Resources" mode="TLASESSION2IMDISESSION">
        <Resources>
            <xsl:apply-templates select="MediaFile" mode="TLASESSION2IMDISESSION"/>
            <xsl:apply-templates select="WrittenResource" mode="TLASESSION2IMDISESSION"/>
            <xsl:apply-templates select="Source" mode="TLASESSION2IMDISESSION"/>            
        </Resources>
    </xsl:template>
    
    <xsl:template match="descriptions" mode="TLASESSION2IMDISESSION">
        <xsl:for-each select="Description">
            <xsl:choose>
                <xsl:when test="normalize-space(.)!=''">                    
                    <Description>
                        <xsl:choose>
                            <xsl:when test="normalize-space(@xml:lang)!=''">
                                <xsl:choose>
                                    <xsl:when test="string-length(@xml:lang)=3">
                                        <xsl:attribute name="LanguageId" select="concat('ISO639-3:',@xml:lang)" /> <!-- this probably needs to be more sophisticated to cover all cases -->                                        
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:message>WARN: encountered xml:lang attribute with a length != 3, skipped.</xsl:message>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
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
        <xsl:call-template name="generate-ResourceId"></xsl:call-template>
        <MediaFile>
            <ResourceLink><xsl:apply-templates select="//ResourceProxy[@id eq current()/@ref]" mode="create-resource-link-content"/></ResourceLink>
            <Type><xsl:value-of select="Type"/></Type>
            <Format><xsl:value-of select="Format"/></Format>
            <Size><xsl:value-of select="Size"/></Size>
            <Quality><xsl:value-of select="Quality"/></Quality>
            <RecordingConditions><xsl:value-of select="RecordingConditions"/></RecordingConditions>
            <xsl:apply-templates select="TimePosition" mode="TLASESSION2IMDISESSION" />
            <xsl:apply-templates select="Access" mode="TLASESSION2IMDISESSION" />  
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>
            <Keys>
                <xsl:apply-templates select="Keys" mode="TLASESSION2IMDISESSION"/>
            </Keys>
        </MediaFile>
    </xsl:template>
    
    <xsl:template match="WrittenResource" mode="TLASESSION2IMDISESSION">
        <WrittenResource>
            <xsl:call-template name="generate-ResourceId"></xsl:call-template>
            <ResourceLink><xsl:apply-templates select="//ResourceProxy[@id eq current()/@ref]" mode="create-resource-link-content"/></ResourceLink>
            <MediaResourceLink></MediaResourceLink> <!-- todo -->            
            <Date><xsl:value-of select="Date"/></Date>
            <Type><xsl:value-of select="Type"/></Type>
            <SubType><xsl:value-of select="SubType"/></SubType>
            <Format><xsl:value-of select="Format"/></Format>
            <Size><xsl:value-of select="Size"/></Size>
            <Validation>
                <Type><xsl:value-of select="Validation/Type"/></Type>
                <Methodology><xsl:value-of select="Validation/Methodology"/></Methodology>
                <xsl:choose>
                    <xsl:when test="normalize-space(Validation/Level)!=''">
                        <Level><xsl:value-of select="Validation/Level"/></Level>
                    </xsl:when>
                    <xsl:otherwise>
                        <Level>Unspecified</Level>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>
            </Validation>
            <Derivation><xsl:value-of select="Derivation"/></Derivation>
            <CharacterEncoding><xsl:value-of select="CharacterEncoding"/></CharacterEncoding>
            <ContentEncoding><xsl:value-of select="ContentEncoding"/></ContentEncoding>
            <LanguageId><xsl:value-of select="LanguageId"/></LanguageId>
            <Anonymized><xsl:value-of select="Anonymized"/></Anonymized>
            <xsl:apply-templates select="Access" mode="TLASESSION2IMDISESSION" /> 
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>
            <Keys>
                <xsl:apply-templates select="Keys" mode="TLASESSION2IMDISESSION"/>
            </Keys>
        </WrittenResource>
    </xsl:template>
    
    <xsl:template match="Source" mode="TLASESSION2IMDISESSION">
        <Source>
            <Id><xsl:value-of select="Id" /></Id>
            <Format><xsl:value-of select="Format" /></Format>
            <Quality><xsl:value-of select="Quality" /></Quality>
            <xsl:apply-templates select="CounterPosition" mode="TLASESSION2IMDISESSION" />
            <xsl:apply-templates select="TimePosition" mode="TLASESSION2IMDISESSION" />
            <xsl:apply-templates select="Access" mode="TLASESSION2IMDISESSION" />            
            <xsl:apply-templates select="descriptions" mode="TLASESSION2IMDISESSION"/>
            <Keys>
                <xsl:apply-templates select="Keys" mode="TLASESSION2IMDISESSION"/>
            </Keys>
        </Source>
    </xsl:template>
    
    <xsl:template match="CounterPosition|TimePosition" mode="TLASESSION2IMDISESSION">
        <xsl:element name="{name()}">
            <Start><xsl:value-of select="Start" /></Start>
            <End><xsl:value-of select="End" /></End>
        </xsl:element>
    </xsl:template>
        
    <xsl:template name="generate-ResourceId">
        <xsl:if test="//Actor[@ref=current()/@ref]">
            <xsl:attribute name="ResourceId" select="@ref" />
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Keys" mode="TLASESSION2IMDISESSION">
        <xsl:choose>
            <xsl:when test="child::Key[1]">
                    <xsl:for-each select="child::Key">
                        <Key>
                            <xsl:attribute name="Name">
                                <xsl:value-of select="@Name"/>
                            </xsl:attribute>
                            <xsl:if test="normalize-space(@Link)!=''">
                                <xsl:attribute name="Link">
                                    <xsl:value-of select="@Link"/>    							
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if test="normalize-space(@Type)!=''">
                                <xsl:attribute name="Type">
                                    <xsl:value-of select="@Type"/>    							
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="./text()"/>
                        </Key>
                    </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>