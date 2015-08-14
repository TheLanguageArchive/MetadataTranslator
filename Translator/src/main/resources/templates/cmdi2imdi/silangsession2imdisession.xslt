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
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
            <xsl:apply-templates select="InfoLink" mode="create-info-link-description"/>
            <MDGroup>
                <xsl:apply-templates select="Location" mode="SILANGSESSION2IMDISESSION"/>
                <xsl:apply-templates select="Project" mode="SILANGSESSION2IMDISESSION"/>
                <Keys>
                    <xsl:apply-templates select="Keys" mode="SILANGSESSION2IMDISESSION"/>
                </Keys>
                <xsl:apply-templates select="Content" mode="SILANGSESSION2IMDISESSION"/>
                <Actors>
                    <xsl:apply-templates select="Actors/descriptions" mode="COMMONTLA2IMDISESSION"/>
                    <xsl:apply-templates select="Actors/Actor" mode="SILANGSESSION2IMDISESSION"/>
                </Actors>
            </MDGroup>
            <xsl:apply-templates select="/CMD/Resources/ResourceProxyList"
                mode="SILANGSESSION2IMDISESSION"/>
            <References/>
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
                <xsl:value-of select="child::ID"/>
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
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
        </Project>
    </xsl:template>

    <xsl:template match="Location" mode="SILANGSESSION2IMDISESSION">
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
                <xsl:apply-templates select="//Content_Language" mode="SILANGSESSION2IMDISESSION"/>
            </Languages>
            <Keys>
                <xsl:apply-templates select="Keys" mode="SILANGSESSION2IMDISESSION"/>
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
                <xsl:apply-templates select="Contact" mode="SILANGSESSION2IMDISESSION"/>
            </Contact>
            <Keys>
                <xsl:apply-templates select="Keys" mode="SILANGSESSION2IMDISESSION"/>
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
        <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
        <Language>
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


    <xsl:template match="Access" mode="SILANGSESSION2IMDISESSION">
        <Access>
            <Availability>
                <xsl:value-of select="Availability"/>
            </Availability>
            <Date>
                <xsl:value-of select="Date"/>
            </Date>
            <Owner>
                <xsl:value-of select="Owner"/>
            </Owner>
            <Publisher>
                <xsl:value-of select="Publisher"/>
            </Publisher>
            <Contact>
                <xsl:apply-templates select="Contact" mode="SILANGSESSION2IMDISESSION"/>
            </Contact>
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
        </Access>
    </xsl:template>

    <xsl:template match="Contact" mode="SILANGSESSION2IMDISESSION">
        <xsl:if test="normalize-space(Name)!=''">
            <Name>
                <xsl:value-of select="Name"/>
            </Name>
        </xsl:if>
        <xsl:if test="normalize-space(Address)!=''">
            <Address>
                <xsl:value-of select="Address"/>
            </Address>
        </xsl:if>
        <xsl:if test="normalize-space(Email)!=''">
            <Email>
                <xsl:value-of select="Email"/>
            </Email>
        </xsl:if>
        <xsl:if test="normalize-space(Organisation)!=''">
            <Organisation>
                <xsl:value-of select="Organisation"/>
            </Organisation>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ResourceProxyList" mode="SILANGSESSION2IMDISESSION">
        <Resources>
            <xsl:apply-templates mode="SILANGSESSION2IMDISESSION-SKIPPED"/>
            <xsl:apply-templates mode="SILANGSESSION2IMDISESSION-MEDIAFILE"/>
            <xsl:apply-templates mode="SILANGSESSION2IMDISESSION-WRITTENRESOURCE"/>
            <xsl:apply-templates select="//Resources/Source" mode="SILANGSESSION2IMDISESSION"/>
        </Resources>
    </xsl:template>

    <xsl:template match="ResourceProxy" mode="SILANGSESSION2IMDISESSION-SKIPPED">
        <!-- ResourceProxies without a reference or mimetype get skipped -->
        <xsl:if
            test="
            not(matches(ResourceType/@mimetype, $sl-mediaFileMimeTypes) 
                or matches(ResourceType/@mimetype, $sl-writtenResourceMimeTypes)) 
            and not(//Resources/*[@ref=current()/@id])">
            <xsl:message>ResourceProxy with id '<xsl:value-of select="@id"/>' will be skipped.
                Reason: no referencing element or recognised mimetype.</xsl:message>
            <xsl:comment>
                <xsl:text>NOTE: CMDI2IMDI - ResourceProxy skipped because no reference or recognised mimetype present:</xsl:text>
                <xsl:value-of select="concat(' [', @id, '] ')"/>
                <xsl:value-of select="ResourceRef"/>
            </xsl:comment>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ResourceProxy[ResourceType = 'LandingPage']"
        mode="SILANGSESSION2IMDISESSION-MEDIAFILE"> </xsl:template>

    <xsl:template match="ResourceProxy[ResourceType = 'Resource']"
        mode="SILANGSESSION2IMDISESSION-MEDIAFILE">
        <xsl:variable name="mediaFile" select="//Resources/MediaFile[@ref=current()/@id]"/>
        <xsl:variable name="mimetype" select="ResourceType/@mimetype"/>
        <xsl:choose>
            <xsl:when test="$mediaFile">
                <!-- A matching MediaFile element exists, transform from this -->
                <xsl:apply-templates select="$mediaFile" mode="SILANGSESSION2IMDISESSION"/>
            </xsl:when>
            <xsl:when test="matches($mimetype, $sl-mediaFileMimeTypes)">
                <!-- No matching MediaFile, generate on basis of proxy alone -->
                <xsl:message>A MediaFile element for ResourceProxy with id '<xsl:value-of
                        select="@id"/>' is generated on basis of mimetype <xsl:value-of
                        select="$mimetype"/></xsl:message>
                <MediaFile>
                    <xsl:comment>NOTE: CMDI2IMDI - No MediaFile element was found for this resource, minimal information was generated on basis of ResourceProxy only</xsl:comment>
                    <ResourceLink>
                        <xsl:apply-templates select="." mode="create-resource-link-content"/>
                    </ResourceLink>
                    <Type>
                        <!-- Strip everything after the forward slash in the mimetype -->
                        <xsl:variable name="mimeTypeStart" select="replace($mimetype,'/.*$','')"/>
                        <!-- Capitalise first -->
                        <xsl:value-of
                            select="concat(upper-case(substring($mimeTypeStart, 1, 1)), lower-case(substring($mimeTypeStart, 2)))"
                        />
                    </Type>
                    <Format>
                        <xsl:value-of select="$mimetype"/>
                    </Format>
                    <Size/>
                    <Quality>Unspecified</Quality>
                    <RecordingConditions>Unspecified</RecordingConditions>
                    <TimePosition>
                        <Start>Unspecified</Start>
                        <End>Unspecified</End>
                    </TimePosition>
                    <Access>
                        <Availability/>
                        <Date>Unspecified</Date>
                        <Owner/>
                        <Publisher/>
                        <Contact/>
                    </Access>
                    <Keys/>
                </MediaFile>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="MediaFile" mode="SILANGSESSION2IMDISESSION">
        <xsl:call-template name="sl-generate-ResourceId"/>
        <MediaFile>
            <ResourceLink>
                <xsl:apply-templates select="//ResourceProxy[@id eq current()/@ref]"
                    mode="create-resource-link-content"/>
            </ResourceLink>
            <Type>
                <xsl:value-of select="Type"/>
            </Type>
            <Format>
                <xsl:value-of select="Format"/>
            </Format>
            <Size>
                <xsl:value-of select="Size"/>
            </Size>
            <Quality>
                <xsl:value-of select="Quality"/>
            </Quality>
            <RecordingConditions>
                <xsl:value-of select="RecordingConditions"/>
            </RecordingConditions>
            <xsl:apply-templates select="TimePosition" mode="SILANGSESSION2IMDISESSION"/>
            <xsl:apply-templates select="Access" mode="SILANGSESSION2IMDISESSION"/>
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
            <Keys>
                <xsl:apply-templates select="Keys" mode="SILANGSESSION2IMDISESSION"/>
            </Keys>
        </MediaFile>
    </xsl:template>

    <xsl:template match="ResourceProxy" mode="SILANGSESSION2IMDISESSION-WRITTENRESOURCE">
        <xsl:variable name="writtenResource"
            select="//Resources/WrittenResource[@ref=current()/@id]"/>
        <xsl:choose>
            <xsl:when test="$writtenResource">
                <!-- A matching MediaFile element exists, transform from this -->
                <xsl:apply-templates select="$writtenResource" mode="SILANGSESSION2IMDISESSION"/>
            </xsl:when>
            <xsl:when test="matches(ResourceType/@mimetype, $sl-writtenResourceMimeTypes)">
                <!-- No matching MediaFile, generate on basis of proxy alone -->
                <xsl:message>A WrittenResource element for ResourceProxy with id '<xsl:value-of
                        select="@id"/>' is generated on basis of mimetype <xsl:value-of
                        select="ResourceType/@mimetype"/></xsl:message>
                <WrittenResource>
                    <xsl:comment>NOTE: CMDI2IMDI - No WrittenResource element was found for this resource, minimal information was generated on basis of ResourceProxy only</xsl:comment>
                    <xsl:call-template name="sl-generate-ResourceId"/>
                    <ResourceLink>
                        <xsl:apply-templates select="." mode="create-resource-link-content"/>
                    </ResourceLink>
                    <MediaResourceLink/>
                    <Date>Unspecified</Date>
                    <Type>Unspecified</Type>
                    <SubType>Unspecified</SubType>
                    <Format>
                        <xsl:value-of select="ResourceType/@mimetype"/>
                    </Format>
                    <Size>Unspecified</Size>
                    <Validation>
                        <Type>Unspecified</Type>
                        <Methodology>Unspecified</Methodology>
                        <Level>Unspecified</Level>
                    </Validation>
                    <Derivation>Unspecified</Derivation>
                    <CharacterEncoding/>
                    <ContentEncoding/>
                    <LanguageId>Unspecified</LanguageId>
                    <Anonymized>Unspecified</Anonymized>
                    <Access>
                        <Availability/>
                        <Date>Unspecified</Date>
                        <Owner/>
                        <Publisher/>
                        <Contact/>
                    </Access>
                    <Keys/>
                </WrittenResource>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="WrittenResource" mode="SILANGSESSION2IMDISESSION">
        <WrittenResource>
            <xsl:call-template name="sl-generate-ResourceId"/>
            <ResourceLink>
                <xsl:apply-templates select="//ResourceProxy[@id eq current()/@ref]"
                    mode="create-resource-link-content"/>
            </ResourceLink>
            <MediaResourceLink>
                <xsl:if test="@mediaRef">
                    <xsl:apply-templates select="//ResourceProxy[@id eq current()/@mediaRef]"
                        mode="create-resource-link-content"/>
                </xsl:if>
            </MediaResourceLink>
            <Date>
                <xsl:value-of select="Date"/>
            </Date>
            <Type>
                <xsl:value-of select="Type"/>
            </Type>
            <SubType>
                <xsl:value-of select="SubType"/>
            </SubType>
            <Format>
                <xsl:value-of select="Format"/>
            </Format>
            <Size>
                <xsl:value-of select="Size"/>
            </Size>
            <Validation>
                <Type>
                    <xsl:value-of select="Validation/Type"/>
                </Type>
                <Methodology>
                    <xsl:value-of select="Validation/Methodology"/>
                </Methodology>
                <xsl:choose>
                    <xsl:when test="normalize-space(Validation/Level)!=''">
                        <Level>
                            <xsl:value-of select="Validation/Level"/>
                        </Level>
                    </xsl:when>
                    <xsl:otherwise>
                        <Level>Unspecified</Level>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
            </Validation>
            <Derivation>
                <xsl:value-of select="Derivation"/>
            </Derivation>
            <CharacterEncoding>
                <xsl:value-of select="CharacterEncoding"/>
            </CharacterEncoding>
            <ContentEncoding>
                <xsl:value-of select="ContentEncoding"/>
            </ContentEncoding>
            <LanguageId>
                <xsl:value-of select="LanguageId"/>
            </LanguageId>
            <Anonymized>
                <xsl:value-of select="Anonymized"/>
            </Anonymized>
            <xsl:apply-templates select="Access" mode="SILANGSESSION2IMDISESSION"/>
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
            <Keys>
                <xsl:apply-templates select="Keys" mode="SILANGSESSION2IMDISESSION"/>
            </Keys>
        </WrittenResource>
    </xsl:template>

    <xsl:template match="Source" mode="SILANGSESSION2IMDISESSION">
        <Source>
            <Id>
                <xsl:value-of select="Id"/>
            </Id>
            <Format>
                <xsl:value-of select="Format"/>
            </Format>
            <Quality>
                <xsl:value-of select="Quality"/>
            </Quality>
            <xsl:apply-templates select="CounterPosition" mode="SILANGSESSION2IMDISESSION"/>
            <xsl:apply-templates select="TimePosition" mode="SILANGSESSION2IMDISESSION"/>
            <xsl:apply-templates select="Access" mode="SILANGSESSION2IMDISESSION"/>
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
            <Keys>
                <xsl:apply-templates select="Keys" mode="SILANGSESSION2IMDISESSION"/>
            </Keys>
        </Source>
    </xsl:template>

    <xsl:template match="CounterPosition|TimePosition" mode="SILANGSESSION2IMDISESSION">
        <xsl:element name="{name()}">
            <Start>
                <xsl:value-of select="Start"/>
            </Start>
            <End>
                <xsl:value-of select="End"/>
            </End>
        </xsl:element>
    </xsl:template>

    <xsl:template name="sl-generate-ResourceId">
        <xsl:if test="//Actor[@ref=current()/@ref]">
            <xsl:attribute name="ResourceId" select="@ref"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Keys" mode="SILANGSESSION2IMDISESSION">
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
