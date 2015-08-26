<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tla="http://tla.mpi.nl"
    xmlns:lat="http://lat.mpi.nl/" version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">

    <xsl:template name="DBDSESSION2IMDISESSION">
        <METATRANSCRIPT xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" FormatId="IMDI 3.0" Type="SESSION"
            Version="0"
            xsi:schemaLocation="http://www.mpi.nl/IMDI/Schema/IMDI http://www.mpi.nl/IMDI/Schema/IMDI_3.0.xsd">
            <xsl:attribute name="ArchiveHandle">
                <xsl:value-of select="tla:getHandleWithoutFormat(//Header/MdSelfLink, 'imdi')"/>
            </xsl:attribute>
            <xsl:attribute name="Originator">
                <xsl:value-of
                    select="tla:create-originator('DBDSESSION2IMDISESSION.xslt', //Header/MdSelfLink)"
                />
            </xsl:attribute>
            <xsl:attribute name="Date">
                <xsl:value-of select="//Header/MdCreationDate"/>
            </xsl:attribute>
            <xsl:apply-templates select="//DBD/Session" mode="DBDSESSION2IMDISESSION"/>
        </METATRANSCRIPT>
    </xsl:template>

    <xsl:template match="DBD/Session" mode="DBDSESSION2IMDISESSION">
        <xsl:choose>
            <xsl:when test="normalize-space(child::History)!=''">
                <History>
                    <xsl:value-of select="child::History"/>
                    <xsl:text> NAME:DBDSESSION2IMDISESSION.xslt DATE:</xsl:text>
                    <xsl:value-of select="current-dateTime()"/>
                    <xsl:text>.</xsl:text>
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
            <xsl:apply-templates select="Descriptions|InfoLink" mode="COMMONTLA2IMDISESSION"/>
            <MDGroup>
                <xsl:apply-templates select="Location" mode="DBDSESSION2IMDISESSION"/>
                <xsl:apply-templates select="Project" mode="DBDSESSION2IMDISESSION"/>
                <Keys>
                    <xsl:apply-templates select="child::IMDICreator" mode="CREATE-KEYS-OPEN">
                        <xsl:with-param name="name" select="'IMDI_file_creator'" />
                    </xsl:apply-templates>
                    <xsl:apply-templates select="child::IMDICorrector" mode="CREATE-KEYS-OPEN">
                        <xsl:with-param name="name" select="'IMDI_file_corrector'" />
                    </xsl:apply-templates>
                    <xsl:apply-templates select="Keys" mode="COMMONTLA2IMDISESSION"/>
                </Keys>
                <xsl:apply-templates select="Content" mode="DBDSESSION2IMDISESSION"/>
                <Actors>
                    <xsl:apply-templates select="Actors/Descriptions" mode="COMMONTLA2IMDISESSION"/>
                    <xsl:apply-templates select="Actors/Actor" mode="DBDSESSION2IMDISESSION"/>
                </Actors>
            </MDGroup>
            <xsl:apply-templates select="/CMD/Resources/ResourceProxyList" mode="COMMONTLA2IMDISESSION" />
            <References>
                <xsl:apply-templates select="References/descriptions|References/InfoLink" mode="COMMONTLA2IMDISESSION"/> 
            </References>
        </Session>
    </xsl:template>

    <xsl:template match="Project" mode="DBDSESSION2IMDISESSION">
        <Project>
            <Name>
                <xsl:value-of select="child::Name"/>
            </Name>
            <Title>
                <xsl:value-of select="child::Title"/>
            </Title>
            <Id>
                <xsl:value-of select="child::Id"/>
            </Id>
            <Contact>
                <Name>
                    <xsl:value-of select="child::Contact/Person"/>
                </Name>
                <Address>
                    <xsl:value-of select="child::Contact/Address"/>
                </Address>
                <Email>
                    <xsl:value-of select="child::Contact/Email"/>
                </Email>
                <Organisation>
                    <xsl:value-of select="child::Contact/Organisation"/>
                </Organisation>
            </Contact>
            <xsl:apply-templates select="Descriptions" mode="COMMONTLA2IMDISESSION"/>
        </Project>
    </xsl:template>

    <xsl:template match="Location" mode="DBDSESSION2IMDISESSION">
        <Location>
            <Continent Link="http://www.mpi.nl/IMDI/Schema/Continents.xml" Type="ClosedVocabulary">
                <xsl:value-of select="child::Continent"/>
            </Continent>
            <Country Link="http://www.mpi.nl/IMDI/Schema/Countries.xml" Type="OpenVocabulary">
                <xsl:value-of select="child::Country"/>
            </Country>
            <Region>
                <xsl:value-of select="child::Region"/>
            </Region>
            <Address>
                <xsl:value-of select="child::Address"/>
            </Address>
        </Location>
    </xsl:template>

    <xsl:template match="Content" mode="DBDSESSION2IMDISESSION">
        <Content>
            <Genre Link="http://www.mpi.nl/IMDI/Schema/Content-Genre.xml" Type="OpenVocabulary">
                <xsl:value-of select="child::Genre"/>
            </Genre>
            <xsl:if test="normalize-space(child::SubGenre)!=''">
                <!-- removed the following attributes: 
                            Link="http://www.mpi.nl/IMDI/Schema/Content-SubGenre.xml" Type="OpenVocabularyList"
                     because the subgenre link depends on the selected genre
                    -->
                <SubGenre>
                    <xsl:value-of select="child::SubGenre"/>
                </SubGenre>
            </xsl:if>
            <xsl:if test="normalize-space(child::Task)!=''">
                <Task Link="http://www.mpi.nl/IMDI/Schema/Content-Task.xml" Type="OpenVocabulary">
                    <xsl:value-of select="child::Task"/>
                </Task>
            </xsl:if>
            <xsl:if test="normalize-space(child::Modalities)!=''">
                <Modalities Link="http://www.mpi.nl/IMDI/Schema/Content-Modalities.xml"
                    Type="OpenVocabularyList">
                    <xsl:value-of select="child::Modalities"/>
                </Modalities>
            </xsl:if>
            <xsl:if test="normalize-space(child::Subject)!=''">
                <Subject Link="http://www.mpi.nl/IMDI/Schema/Content-Subject.xml"
                    Type="OpenVocabularyList">
                    <xsl:value-of select="child::Subject"/>
                </Subject>
            </xsl:if>
            <CommunicationContext>
                <Interactivity Link="http://www.mpi.nl/IMDI/Schema/Content-Interactivity.xml"
                    Type="ClosedVocabulary">
                    <xsl:value-of select="child::CommunicationContext/Interactivity"/>
                </Interactivity>
                <PlanningType Link="http://www.mpi.nl/IMDI/Schema/Content-PlanningType.xml"
                    Type="ClosedVocabulary">
                    <xsl:value-of select="child::CommunicationContext/PlanningType"/>
                </PlanningType>
                <Involvement Link="http://www.mpi.nl/IMDI/Schema/Content-Involvement.xml"
                    Type="ClosedVocabulary">
                    <xsl:value-of select="child::CommunicationContext/Involvement"/>
                </Involvement>
                <SocialContext Link="http://www.mpi.nl/IMDI/Schema/Content-SocialContext.xml"
                    Type="ClosedVocabulary">
                    <xsl:value-of select="child::CommunicationContext/SocialContext"/>
                </SocialContext>
                <EventStructure Link="http://www.mpi.nl/IMDI/Schema/Content-EventStructure.xml"
                    Type="ClosedVocabulary">
                    <xsl:value-of select="child::CommunicationContext/EventStructure"/>
                </EventStructure>
                <Channel Link="http://www.mpi.nl/IMDI/Schema/Content-Channel.xml"
                    Type="ClosedVocabulary">
                    <xsl:value-of select="child::CommunicationContext/Channel"/>
                </Channel>
            </CommunicationContext>
            <Languages>
                <xsl:apply-templates select="Languages/Descriptions" mode="COMMONTLA2IMDISESSION"/>
                <xsl:apply-templates select="Languages/Language"
                    mode="DBDSESSION2IMDISESSION_CONTENTLANG"/>
            </Languages>
            <Keys>
                <xsl:apply-templates select="child::LanguageMode" mode="CREATE-KEYS-DBD-OPEN" />
                <xsl:apply-templates select="Keys" mode="COMMONTLA2IMDISESSION"/>
            </Keys>
            <xsl:apply-templates select="Descriptions" mode="COMMONTLA2IMDISESSION"/>
        </Content>
    </xsl:template>

    <xsl:template match="Actor" mode="DBDSESSION2IMDISESSION">
        <Actor>
            <xsl:if test="@ref">
                <xsl:attribute name="ResourceRef" select="@ref"/>
            </xsl:if>

            <Role Link="http://www.mpi.nl/IMDI/Schema/Actor-Role.xml" Type="OpenVocabularyList">
                <xsl:value-of select="child::Role"/>
            </Role>
            <Name>
                <xsl:value-of select="child::Name"/>
            </Name>
            <FullName>
                <xsl:value-of select="child::FullName"/>
            </FullName>
            <Code>
                <xsl:value-of select="child::Code"/>
            </Code>
            <FamilySocialRole Link="http://www.mpi.nl/IMDI/Schema/Actor-FamilySocialRole.xml"
                Type="OpenVocabularyList">
                <xsl:value-of select="child::FamilySocialRole"/>
            </FamilySocialRole>
            <Languages>
                <xsl:apply-templates select="Languages/Descriptions" mode="COMMONTLA2IMDISESSION"/>
                <xsl:apply-templates select="descendant::Language"
                    mode="DBDSESSION2IMDISESSION_ACTORLANG"/>
            </Languages>
            <EthnicGroup>
                <xsl:value-of select="child::EthnicGroup"/>
            </EthnicGroup>
            <Age>
                <xsl:value-of select="child::Age"/>
            </Age>
            <BirthDate>
                <xsl:value-of select="child::BirthDate"/>
            </BirthDate>
            <Sex Link="http://www.mpi.nl/IMDI/Schema/Actor-Sex.xml" Type="ClosedVocabulary">
                <xsl:value-of select="child::Sex"/>
            </Sex>
            <Education>
                <xsl:value-of select="child::Education"/>
            </Education>
            <Anonymized Link="http://www.mpi.nl/IMDI/Schema/Boolean.xml" Type="ClosedVocabulary">
                <xsl:value-of select="child::Anonymized"/>
            </Anonymized>
            <Contact>
                <xsl:apply-templates select="Contact" mode="COMMONTLA2IMDISESSION"/>
            </Contact>
            <Keys>
                <xsl:apply-templates select="child::LevelOfBilingualism" mode="CREATE-KEYS-DBD-OPEN" />
                <xsl:apply-templates select="child::AgeAtImmigration" mode="CREATE-KEYS-DBD-OPEN" />
                <xsl:apply-templates select="child::BirthCountry" mode="CREATE-KEYS-OPEN">
                    <xsl:with-param name="name">DBD.CountryofBirth</xsl:with-param>
                </xsl:apply-templates>
                <xsl:apply-templates select="Keys" mode="COMMONTLA2IMDISESSION"/>
            </Keys>
            <xsl:apply-templates select="Descriptions" mode="COMMONTLA2IMDISESSION"/>
        </Actor>
    </xsl:template>

    <xsl:template match="Language" mode="DBDSESSION2IMDISESSION_CONTENTLANG">
        <Language>
            <xsl:if test="@ref">
                <xsl:attribute name="ResourceRef" select="@ref" />
            </xsl:if>
            <Id>
                <xsl:value-of select="child::LanguageID"/>
            </Id>
            <Name Link="http://www.mpi.nl/IMDI/Schema/MPI-Languages.xml" Type="OpenVocabulary">
                <xsl:value-of select="child::LanguageName"/>
            </Name>
            <Dominant Type="ClosedVocabulary">
                <xsl:value-of select="child::Dominant"/>
            </Dominant>
            <SourceLanguage Type="ClosedVocabulary">
                <xsl:value-of select="child::SourceLanguage"/>
            </SourceLanguage>
            <TargetLanguage Type="ClosedVocabulary">
                <xsl:value-of select="child::TargetLanguage"/>
            </TargetLanguage>
            <xsl:apply-templates select="Descriptions" mode="COMMONTLA2IMDISESSION"/>
        </Language>
    </xsl:template>

    <xsl:template match="Language" mode="DBDSESSION2IMDISESSION_ACTORLANG">
        <Language>
            <xsl:if test="@ref">
                <xsl:attribute name="ResourceRef" select="@ref" />
            </xsl:if>
            <Id>
                <xsl:value-of select="child::LanguageID"/>
            </Id>
            <Name>
                <xsl:value-of select="child::LanguageName"/>
            </Name>
            <MotherTongue Type="ClosedVocabulary">
                <xsl:value-of select="child::MotherTongue"/>
            </MotherTongue>
            <PrimaryLanguage Type="ClosedVocabulary">
                <xsl:value-of select="child::PrimaryLanguage"/>
            </PrimaryLanguage>
            <xsl:apply-templates select="Descriptions" mode="COMMONTLA2IMDISESSION"/>
        </Language>
    </xsl:template>
    
    <!-- Create keys where name is "DBD.{node name}" -->
    <xsl:template match="node()" mode="CREATE-KEYS-DBD-OPEN">
        <xsl:apply-templates select="." mode="CREATE-KEYS-OPEN">
            <xsl:with-param name="name" select="concat('DBD.',name())" />
        </xsl:apply-templates>
    </xsl:template>


</xsl:stylesheet>
