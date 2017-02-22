<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tla="http://tla.mpi.nl" 
    version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">
    
    <xsl:template name="DLUCEA2IMDI">
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
                <xsl:value-of select="tla:create-originator('DLUCEA2IMDI.xslt', //Header/MdSelfLink)" />
            </xsl:attribute>
            <Session>
                <xsl:apply-templates select="//Header" mode="DLUCEA2IMDI"/>
                <xsl:apply-templates select="//lucea" mode="DLUCEA2IMDI"/>
            </Session>
        </METATRANSCRIPT>
    </xsl:template>
    
    <xsl:template match="Header" mode="DLUCEA2IMDI"/>        
    
    <xsl:template match="lucea" mode="DLUCEA2IMDI">
        <Name>
            <xsl:value-of select="id"/>
        </Name>
        <Title/>
        <Date>Unspecified</Date>
        <Description LanguageId="" Link="" />
        <MDGroup>
            <Location>
                <Continent>Unspecified</Continent>
                <Country>Unspecified</Country>
                <Region/>
            </Location>
            <Project>
                <Name/>
                <Title/>
                <Id/>
                <Contact>
                    <Name/>
                    <Address/>
                    <Email/>
                    <Organisation/>
                </Contact>
                <Description LanguageId=""/>
            </Project>
            <Keys/>           
            <Content>
                <Genre Link="http://www.mpi.nl/IMDI/Schema/Content-Genre.xml" Type="OpenVocabulary"/>
                <SubGenre Link="http://www.mpi.nl/IMDI/Schema/Content-SubGenre.xml" Type="OpenVocabularyList"/>
                <Task Link="http://www.mpi.nl/IMDI/Schema/Content-Task.xml" Type="OpenVocabulary"/>
                <Modalities Link="http://www.mpi.nl/IMDI/Schema/Content-Modalities.xml" Type="OpenVocabularyList"/>
                <Subject Link="http://www.mpi.nl/IMDI/Schema/Content-Subject.xml" Type="OpenVocabularyList"/>
                <CommunicationContext>
                    <Interactivity Link="http://www.mpi.nl/IMDI/Schema/Content-Interactivity.xml" Type="ClosedVocabulary"/>
                    <PlanningType Link="http://www.mpi.nl/IMDI/Schema/Content-PlanningType.xml" Type="ClosedVocabulary"/>
                    <Involvement Link="http://www.mpi.nl/IMDI/Schema/Content-Involvement.xml" Type="ClosedVocabulary"/>
                    <SocialContext Link="http://www.mpi.nl/IMDI/Schema/Content-SocialContext.xml" Type="ClosedVocabulary"/>
                    <EventStructure Link="http://www.mpi.nl/IMDI/Schema/Content-EventStructure.xml" Type="ClosedVocabulary"/>
                    <Channel Link="http://www.mpi.nl/IMDI/Schema/Content-Channel.xml" Type="ClosedVocabulary"/>
                </CommunicationContext>
                <Languages>
                    <Description LanguageId="" Link=""/>
                </Languages>
                <Keys>
            </Keys>
                <Description LanguageId="" Link=""/>
            </Content>
            
            <Actors>
                <Description/>
                <xsl:apply-templates select="//facilitator" mode="DLUCEA2IMDI"/>
                <xsl:apply-templates select="//speaker" mode="DLUCEA2IMDI"/>                
            </Actors>
        </MDGroup>
        <Resources>
            <xsl:apply-templates select="//lucea-recording/MediaFile" mode="DLUCEA2IMDI"/>
        </Resources>
    </xsl:template>
    
  
    
    <xsl:template match="facilitator" mode="DLUCEA2IMDI">
        <Actor>
            <Role Link="http://www.mpi.nl/IMDI/Schema/Actor-Role.xml" Type="OpenVocabularyList">Researcher</Role>
            <Name><xsl:value-of select="child::name"/></Name>
            <FullName/>
            <Code/>
            <FamilySocialRole Link="http://www.mpi.nl/IMDI/Schema/Actor-FamilySocialRole.xml" Type="OpenVocabularyList"/>
            <Languages>
                <Description LanguageId="" Link=""/>
                <xsl:apply-templates select="descendant::language" mode="DLUCEA2IMDI" />
            </Languages>
            <EthnicGroup>Unspecified</EthnicGroup>
            <Age>Unspecified</Age>
            <BirthDate><xsl:value-of select="child::birthYear"></xsl:value-of></BirthDate>
            <Sex Link="http://www.mpi.nl/IMDI/Schema/Actor-Sex.xml" Type="ClosedVocabulary"><xsl:value-of select="concat(upper-case(substring(child::sex,1,1)),substring(child::sex,2))"/></Sex>
            <Education/>
            <Anonymized Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary">Unspecified</Anonymized>
            <Contact>
                <Name/>
                <Address/>
                <Email/>
                <Organisation/>
            </Contact>
            <Keys/>                       
            <Description LanguageId="" Link=""/>
        </Actor>
    </xsl:template>
    
    <xsl:template match="speaker" mode="DLUCEA2IMDI">
        <Actor>
            <Role Link="http://www.mpi.nl/IMDI/Schema/Actor-Role.xml" Type="OpenVocabularyList">Consultant</Role>
            <Name>Unspecified</Name>
            <FullName/>
            <Code><xsl:value-of select="child::id"/></Code>
            <FamilySocialRole Link="http://www.mpi.nl/IMDI/Schema/Actor-FamilySocialRole.xml" Type="OpenVocabularyList"/>
            <Languages>
                <Description LanguageId="" Link=""/>
                <xsl:apply-templates select="descendant::language" mode="DLUCEA2IMDI" />
            </Languages>
            <EthnicGroup>Unspecified</EthnicGroup>
            <Age>Unspecified</Age>
            <BirthDate><xsl:value-of select="child::birthYear"></xsl:value-of></BirthDate>
            <Sex Link="http://www.mpi.nl/IMDI/Schema/Actor-Sex.xml" Type="ClosedVocabulary"><xsl:value-of select="concat(upper-case(substring(child::sex,1,1)),substring(child::sex,2))"/></Sex>
            <Education/>
            <Anonymized Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary">Unspecified</Anonymized>
            <Contact>
                <Name/>
                <Address/>
                <Email/>
                <Organisation/>
            </Contact>
            <Keys/>                       
            <Description LanguageId="" Link=""/>
        </Actor>
    </xsl:template>
  
    <xsl:template match="language" mode="DLUCEA2IMDI">
      <Language>
          <Id>ISO639-3:<xsl:value-of select="child::Language/ISO639/iso-639-3-code"/></Id>
          <Name Link="http://www.mpi.nl/IMDI/Schema/MPI-Languages.xml" Type="OpenVocabulary"><xsl:value-of select="child::Language/LanguageName"/></Name>
          <MotherTongue Type="ClosedVocabulary">
              <xsl:choose>
                  <xsl:when test="isChildhoodLanguage=1">true</xsl:when>
                  <xsl:when test="isChildhoodLanguage=0">false</xsl:when>
              </xsl:choose>
          </MotherTongue>
          <PrimaryLanguage Type="ClosedVocabulary">Unspecified</PrimaryLanguage>
      </Language>
    </xsl:template>
    
    <xsl:template match="lucea-recording/MediaFile" mode="DLUCEA2IMDI">
        <MediaFile>
            <xsl:variable name="id"><xsl:value-of select="@ref" /></xsl:variable>
            <ResourceLink><xsl:apply-templates select="//Resources/ResourceProxyList/ResourceProxy[@id=$id]" mode="create-resource-link-content"/></ResourceLink>
            <Type Link="http://www.mpi.nl/IMDI/Schema/MediaFile-Type.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Type"/></Type>
            <Format Link="http://www.mpi.nl/IMDI/Schema/MediaFile-Format.xml" Type="OpenVocabulary">
                <xsl:value-of select="//Resources/ResourceProxyList/ResourceProxy[@id=$id]/ResourceType/@mimetype"/>
            </Format>
            <Size/>
            <Quality Link="http://www.mpi.nl/IMDI/Schema/Quality.xml" Type="ClosedVocabulary"><xsl:value-of select="child::Quality"/></Quality>
            <RecordingConditions><xsl:value-of select="child::RecordingConditions"/></RecordingConditions>
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