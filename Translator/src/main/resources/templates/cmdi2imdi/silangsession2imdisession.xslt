<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tla="http://tla.mpi.nl"
                xmlns:lat="http://lat.mpi.nl/" version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">

    <xsl:variable name="sl-mediaFileMimeTypes">^(video|audio|image)/.*$</xsl:variable>
    <xsl:variable name="sl-writtenResourceMimeTypes">^(text|application)/.*$</xsl:variable>

    <xsl:template name="SILANGSESSION2IMDISESSION">
        <METATRANSCRIPT xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
                        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" FormatId="IMDI 3.0" Type="SESSION"
                        Version="0"
                        xsi:schemaLocation="http://www.mpi.nl/IMDI/Schema/IMDI http://www.mpi.nl/IMDI/Schema/IMDI_3.0.xsd">
            <xsl:attribute name="ArchiveHandle">
                <xsl:value-of select="tla:getHandleWithoutFormat(//Header/MdSelfLink, 'imdi')"/>
            </xsl:attribute>
            <xsl:attribute name="Originator">
                <xsl:value-of
                    select="tla:create-originator('SILANGSESSION2IMDISESSION.xslt', //Header/MdSelfLink)"
                />
            </xsl:attribute>
            <xsl:attribute name="Date">
                <xsl:value-of select="//Header/MdCreationDate"/>
            </xsl:attribute>
            <xsl:apply-templates select="//lat-SL-session" mode="SILANGSESSION2IMDISESSION"/>
        </METATRANSCRIPT>
    </xsl:template>

    <xsl:template match="lat-SL-session" mode="SILANGSESSION2IMDISESSION">
        <History>
            <xsl:if test="normalize-space(child::History)!=''">
                <xsl:value-of select="child::History"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:text> NAME:SILANGSESSION2IMDISESSION.xslt DATE:</xsl:text>
            <xsl:value-of select="current-dateTime()"/>
            <xsl:text>.</xsl:text>
        </History>
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
            <xsl:apply-templates select="descriptions|InfoLink" mode="COMMONTLA2IMDISESSION"/>
            <MDGroup>
                <xsl:apply-templates select="Location" mode="COMMONTLA2IMDISESSION"/>
                <xsl:apply-templates select="Project" mode="SILANGSESSION2IMDISESSION"/>
                <Keys>
                    <xsl:apply-templates select="Keys" mode="COMMONTLA2IMDISESSION"/>
                    <xsl:apply-templates select="SL_CreativeCommonsLicense" mode="SILANGSESSION2IMDISESSION" />
                </Keys>
                <xsl:apply-templates select="Content" mode="SILANGSESSION2IMDISESSION"/>
                <Actors>
                    <xsl:apply-templates select="Actors/descriptions" mode="COMMONTLA2IMDISESSION"/>
                    <xsl:apply-templates select="Actors/Actor" mode="SILANGSESSION2IMDISESSION"/>
                </Actors>
            </MDGroup>
            <xsl:apply-templates select="/CMD/Resources/ResourceProxyList"
                                 mode="COMMONTLA2IMDISESSION"/>
            <References>
                <xsl:apply-templates select="References/descriptions|References/InfoLink" mode="COMMONTLA2IMDISESSION"/> 
            </References>
        </Session>
    </xsl:template>

    <xsl:template match="Project" mode="SILANGSESSION2IMDISESSION">
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
                    <xsl:value-of select="child::Contact/Name"/>
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
            <xsl:apply-templates select="descriptions|InfoLink" mode="COMMONTLA2IMDISESSION"/>
        </Project>
    </xsl:template>

    <xsl:template match="Content" mode="SILANGSESSION2IMDISESSION">
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
                <xsl:apply-templates select="child::Content_Languages/descriptions" mode="COMMONTLA2IMDISESSION"/>
                <xsl:apply-templates select="child::Content_Languages/Content_Language" mode="SILANGSESSION2IMDISESSION"/>
            </Languages>
            <Keys>
                <xsl:apply-templates select="Keys" mode="COMMONTLA2IMDISESSION"/>
                <xsl:if test="normalize-space(child::ElicitationMethod)!=''">
                    <Key Name="ElicitationMethod">
                        <xsl:value-of select="ElicitationMethod"/>
                    </Key>
                </xsl:if>
                <xsl:apply-templates select="SL_Interpreting" mode="SILANGSESSION2IMDISESSION"/>
            </Keys>
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
        </Content>
    </xsl:template>

    <xsl:template match="SL_Interpreting" mode="SILANGSESSION2IMDISESSION">
        <xsl:if test="normalize-space(child::Source)!=''">
            <Key Name="Interpreting.Source">
                <xsl:value-of select="Source"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::Target)!=''">
            <Key Name="Interpreting.Target">
                <xsl:value-of select="Target"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::Visibility)!=''">
            <Key Name="Interpreting.Visibility">
                <xsl:value-of select="Visibility"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::Audience)!=''">
            <Key Name="Interpreting.Audience">
                <xsl:value-of select="Audience"/>
            </Key>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="SL_CreativeCommonsLicense" mode="SILANGSESSION2IMDISESSION">
        <xsl:if test="normalize-space(child::AnnotationFiles)!=''">
            <Key Name="CreativeCommonsLicense.AnnotationFiles">
                <xsl:value-of select="AnnotationFiles"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::AnnotationFiles_URL)!=''">
            <Key Name="CreativeCommonsLicense.AnnotationFiles.URL">
                <xsl:value-of select="AnnotationFiles_URL"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::MediaFiles)!=''">
            <Key Name="CreativeCommonsLicense.MediaFiles">
                <xsl:value-of select="MediaFiles"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::MediaFiles_URL)!=''">
            <Key Name="CreativeCommonsLicense.MediaFiles.URL">
                <xsl:value-of select="MediaFiles_URL"/>
            </Key>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Actor" mode="SILANGSESSION2IMDISESSION">
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
                <xsl:apply-templates select="Actor_Languages/descriptions"
                                     mode="COMMONTLA2IMDISESSION"/>
                <xsl:apply-templates select="descendant::Actor_Language"
                                     mode="SILANGSESSION2IMDISESSION"/>
            </Languages>
            <EthnicGroup>
                <xsl:value-of select="child::EthnicGroup"/>
            </EthnicGroup>
            <Age>
                <xsl:apply-templates select="child::Age" mode="COMMONTLA2IMDISESSION" />
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
                <xsl:apply-templates select="Keys" mode="COMMONTLA2IMDISESSION"/>
                <xsl:if test="normalize-space(child::Handedness)!=''">
                    <Key Name="Handedness">
                        <xsl:value-of select="Handedness"/>
                    </Key>
                </xsl:if>
                <xsl:if test="normalize-space(child::Region)!=''">
                    <Key Name="Region">
                        <xsl:value-of select="Region"/>
                    </Key>
                </xsl:if>
                <xsl:apply-templates select="SL_Deafness" mode="SILANGSESSION2IMDISESSION"/>
                <xsl:apply-templates select="SL_SignLanguageExperience"
                                     mode="SILANGSESSION2IMDISESSION"/>
                <xsl:apply-templates select="SL_Family" mode="SILANGSESSION2IMDISESSION"/>
                <xsl:apply-templates select="SL_Education" mode="SILANGSESSION2IMDISESSION"/>
            </Keys>
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
        </Actor>
    </xsl:template>

    <xsl:template match="SL_Deafness" mode="SILANGSESSION2IMDISESSION">
        <xsl:if test="normalize-space(child::Status)!=''">
            <Key Name="Deafness.Status">
                <xsl:value-of select="Status"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::AidType)!=''">
            <Key Name="Deafness.AidType">
                <xsl:value-of select="AidType"/>
            </Key>
        </xsl:if>
    </xsl:template>

    <xsl:template match="SL_SignLanguageExperience" mode="SILANGSESSION2IMDISESSION">
        <xsl:if test="normalize-space(child::ExposureAge)!=''">
            <Key Name="SignLanguageExperience.ExposureAge">
                <xsl:value-of select="ExposureAge"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::AcquisitionLocation)!=''">
            <Key Name="SignLanguageExperience.AcquisitionLocation">
                <xsl:value-of select="AcquisitionLocation"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::SignTeaching)!=''">
            <Key Name="SignLanguageExperience.SignTeaching">
                <xsl:value-of select="SignTeaching"/>
            </Key>
        </xsl:if>
    </xsl:template>

    <xsl:template match="SL_Family" mode="SILANGSESSION2IMDISESSION">
        <xsl:apply-templates select="SL_Mother" mode="SILANGSESSION2IMDISESSION"/>
        <xsl:apply-templates select="SL_Father" mode="SILANGSESSION2IMDISESSION"/>
        <xsl:apply-templates select="SL_Partner" mode="SILANGSESSION2IMDISESSION"/>
    </xsl:template>

    <xsl:template match="SL_Mother|SL_Father|SL_Partner" mode="SILANGSESSION2IMDISESSION">
        <xsl:if test="normalize-space(child::Deafness)!=''">
            <Key Name="{concat('Family.',replace(name(.),'SL_',''),'.Deafness')}">
                <xsl:value-of select="Deafness"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::PrimaryCommunicationForm)!=''">
            <Key Name="{concat('Family.',replace(name(.),'SL_',''),'.PrimaryCommunicationForm')}">
                <xsl:value-of select="PrimaryCommunicationForm"/>
            </Key>
        </xsl:if>
    </xsl:template>

    <xsl:template match="SL_Education" mode="SILANGSESSION2IMDISESSION">
        <xsl:if test="normalize-space(child::Age)!=''">
            <Key Name="Education.Age">
                <xsl:value-of select="Age"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::SchoolType)!=''">
            <Key Name="Education.SchoolType">
                <xsl:value-of select="SchoolType"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::ClassKind)!=''">
            <Key Name="Education.ClassKind">
                <xsl:value-of select="ClassKind"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::EducationModel)!=''">
            <Key Name="Education.EducationModel">
                <xsl:value-of select="EducationModel"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::Location)!=''">
            <Key Name="Education.Location">
                <xsl:value-of select="Location"/>
            </Key>
        </xsl:if>
        <xsl:if test="normalize-space(child::BoardingSchool)!=''">
            <Key Name="Education.BoardingSchool">
                <xsl:value-of select="BoardingSchool"/>
            </Key>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Content_Language" mode="SILANGSESSION2IMDISESSION">
        <Language>
            <xsl:if test="@ref">
                <xsl:attribute name="ResourceRef" select="@ref" />
            </xsl:if>
            <Id>
                <xsl:value-of select="child::Id"/>
            </Id>
            <Name Link="http://www.mpi.nl/IMDI/Schema/MPI-Languages.xml" Type="OpenVocabulary">
                <xsl:value-of select="child::Name"/>
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
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
        </Language>
    </xsl:template>

    <xsl:template match="Actor_Language" mode="SILANGSESSION2IMDISESSION">
        <Language>
            <xsl:if test="@ref">
                <xsl:attribute name="ResourceRef" select="@ref" />
            </xsl:if>
            <Id>
                <xsl:value-of select="child::Id"/>
            </Id>
            <Name>
                <xsl:value-of select="child::Name"/>
            </Name>
            <MotherTongue Type="ClosedVocabulary">
                <xsl:value-of select="child::MotherTongue"/>
            </MotherTongue>
            <PrimaryLanguage Type="ClosedVocabulary">
                <xsl:value-of select="child::PrimaryLanguage"/>
            </PrimaryLanguage>
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
        </Language>
    </xsl:template>

</xsl:stylesheet>
