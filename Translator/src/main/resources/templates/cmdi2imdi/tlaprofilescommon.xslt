<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.mpi.nl/IMDI/Schema/IMDI"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tla="http://tla.mpi.nl"
    xmlns:lat="http://lat.mpi.nl/" version="2.0" xpath-default-namespace="http://www.clarin.eu/cmd/">

    <!-- DESCRIPTIONS AND INFO LINKS -->

    <xsl:template match="descriptions|Descriptions" mode="COMMONTLA2IMDISESSION">
        <xsl:for-each select="Description">
            <xsl:choose>
                <xsl:when test="normalize-space(.)!=''">
                    <Description>
                        <xsl:call-template name="create-description-language-attribute"/>
                        <xsl:value-of select="."/>
                    </Description>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="create-description-language-attribute">
        <xsl:if test="normalize-space(@xml:lang)!=''">
            <xsl:choose>
                <xsl:when test="@xml:lang = 'nl'">
                    <xsl:attribute name="LanguageId">ISO639-3:nld</xsl:attribute>
                </xsl:when>
                <xsl:when test="@xml:lang = 'en'">
                    <xsl:attribute name="LanguageId">ISO639-3:eng</xsl:attribute>
                </xsl:when>
                <xsl:when test="string-length(@xml:lang)=3">
                    <xsl:attribute name="LanguageId" select="concat('ISO639-3:',@xml:lang)"/>
                    <!-- this probably needs to be more sophisticated to cover all cases -->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>WARN: encountered xml:lang attribute with a length != 3,
                        skipped.</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- InfoLink to Description with @ArchiveHandle and @Link -->
    <xsl:template match="InfoLink" mode="create-info-link-description">
        <xsl:variable name="proxy" select="//ResourceProxy[@id eq current()/@ref]"/>
        <xsl:choose>
            <xsl:when test="Description">
                <xsl:for-each select="Description">
                    <xsl:call-template name="create-info-link-description-element">
                        <xsl:with-param name="proxy" select="$proxy"/>
                        <xsl:with-param name="description" select="text()"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="create-info-link-description-element">
                    <xsl:with-param name="proxy" select="$proxy"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="create-info-link-description-element">
        <xsl:param name="proxy"/>
        <xsl:param name="description" required="no"/>
        <Description>
            <xsl:call-template name="create-description-language-attribute"/>

            <xsl:choose>
                <xsl:when test="$proxy">
                    <xsl:variable name="handle" select="tla:getBaseHandle($proxy/ResourceRef)"/>
                    <xsl:if test="$handle">
                        <xsl:attribute name="ArchiveHandle">
                            <xsl:value-of select="concat('hdl:',$handle)"/>
                        </xsl:attribute>
                    </xsl:if>

                    <xsl:variable name="localUri" select="$proxy/ResourceRef/@lat:localURI"/>
                    <xsl:if test="normalize-space($localUri) != ''">
                        <xsl:attribute name="Link">
                            <xsl:value-of select="resolve-uri($localUri, $source-location)"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>Warning: InfoLink without matching resource proxy! Description
                        content: [<xsl:value-of select="Description"/>]</xsl:message>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="$description">
                <xsl:value-of select="$description"/>
            </xsl:if>
        </Description>
    </xsl:template>
    
    <!-- RESOURCES -->
    
    
    <xsl:template match="ResourceProxyList" mode="COMMONTLA2IMDISESSION">
        <Resources>
            <xsl:apply-templates mode="COMMONTLA2IMDISESSION-SKIPPED" select="ResourceProxy"/>
            
            <!-- MediaFiles: first from proxies, then remaining unreferenced resources -->
            <xsl:apply-templates mode="COMMONTLA2IMDISESSION-MEDIAFILE" select="ResourceProxy"/>
            <xsl:apply-templates mode="COMMONTLA2IMDISESSION" select="//MediaFile[normalize-space(@ref)='']"/>
            
            <!-- WrittenResources: first from proxies, then remaining unreferenced resources -->
            <xsl:apply-templates mode="COMMONTLA2IMDISESSION-WRITTENRESOURCE" select="ResourceProxy"/>
            <xsl:apply-templates mode="COMMONTLA2IMDISESSION" select="//WrittenResource[normalize-space(@ref)='']"/>
            
            <!-- Sources -->
            <xsl:apply-templates select="/CMD/Components/lat-session/Resources/Source" mode="COMMONTLA2IMDISESSION" />
            
            <!-- TODO: Anonyms? -->
        </Resources>
    </xsl:template>
    
    
    <xsl:template match="ResourceProxy" mode="COMMONTLA2IMDISESSION-SKIPPED">
        <!-- ResourceProxies without a reference or mimetype get skipped -->
        <xsl:if test="
            not(matches(ResourceType/@mimetype, $mediaFileMimeTypes) 
            or matches(ResourceType/@mimetype, $writtenResourceMimeTypes)
            or ResourceType/text() = 'LandingPage')
            and not(//Resources/*[@ref=current()/@id])">
            <xsl:message>ResourceProxy with id '<xsl:value-of select="@id" />' will be skipped. Reason: no referencing element or recognised mimetype.</xsl:message>
            <xsl:text>
            </xsl:text>
            <xsl:comment>
                <xsl:text>NOTE: CMDI2IMDI - ResourceProxy skipped because no reference or recognised mimetype present:</xsl:text>
                <xsl:value-of select="concat(' [', @id, '] ')" />
                <xsl:value-of select="ResourceRef"/>
            </xsl:comment>
            <xsl:text>
            </xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="ResourceProxy" mode="COMMONTLA2IMDISESSION-MEDIAFILE">
        <xsl:if test="normalize-space(ResourceType) = 'Resource'">
            <xsl:variable name="mediaFile" select="//Resources/MediaFile[@ref=current()/@id]" />
            <xsl:variable name="mimetype" select="ResourceType/@mimetype"/>
            <xsl:choose>
                <xsl:when test="$mediaFile">
                    <!-- A matching MediaFile element exists, transform from this -->
                    <xsl:apply-templates select="$mediaFile" mode="COMMONTLA2IMDISESSION"/>
                </xsl:when>
                <xsl:when test="//InfoLink[@ref=current()/@id]">
                    <!-- info link exist, processed elsewhere, skip -->
                </xsl:when>
                <xsl:when test="matches($mimetype, $mediaFileMimeTypes)">
                    <!-- No matching MediaFile, generate on basis of proxy alone -->
                    <xsl:message>A MediaFile element for ResourceProxy with id '<xsl:value-of select="@id" />' is generated on basis of mimetype <xsl:value-of select="$mimetype" /></xsl:message>
                    <MediaFile>
                        <xsl:comment>NOTE: CMDI2IMDI - No MediaFile element was found for this resource, minimal information was generated on basis of ResourceProxy only</xsl:comment>
                        <ResourceLink><xsl:apply-templates select="." mode="create-resource-link-content"/></ResourceLink>
                        <Type>
                            <!-- Strip everything after the forward slash in the mimetype -->
                            <xsl:variable name="mimeTypeStart" select="replace($mimetype,'/.*$','')" />
                            <!-- Capitalise first -->
                            <xsl:value-of select="concat(upper-case(substring($mimeTypeStart, 1, 1)), lower-case(substring($mimeTypeStart, 2)))" />
                        </Type>
                        <Format><xsl:value-of select="$mimetype"/></Format>
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
        </xsl:if>        
    </xsl:template>
    
    <xsl:template match="MediaFile" mode="COMMONTLA2IMDISESSION">
        <xsl:if test="normalize-space(@ref) = ''">
            <xsl:message>MediaFile found without a resource reference, could not generate resource link value</xsl:message>
        </xsl:if>
        
        <MediaFile>
            <xsl:call-template name="generate-ResourceId"></xsl:call-template>
            <ResourceLink><xsl:apply-templates select="//ResourceProxy[@id eq current()/@ref]" mode="create-resource-link-content"/></ResourceLink>
            <Type><xsl:value-of select="Type"/></Type>
            <Format><xsl:value-of select="Format"/></Format>
            <Size><xsl:value-of select="Size"/></Size>
            <Quality><xsl:value-of select="Quality"/></Quality>
            <RecordingConditions><xsl:value-of select="RecordingConditions"/></RecordingConditions>
            <xsl:apply-templates select="TimePosition" mode="COMMONTLA2IMDISESSION" />
            <xsl:apply-templates select="Access" mode="COMMONTLA2IMDISESSION" />  
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
            <Keys>
                <xsl:apply-templates select="Keys" mode="COMMONTLA2IMDISESSION"/>
            </Keys>
        </MediaFile>
    </xsl:template>
    
    <xsl:template match="ResourceProxy" mode="COMMONTLA2IMDISESSION-WRITTENRESOURCE">
        <xsl:if test="normalize-space(ResourceType) = 'Resource'">
            <xsl:variable name="writtenResource" select="//Resources/WrittenResource[@ref=current()/@id]"/>
            <xsl:choose>
                <xsl:when test="$writtenResource">
                    <!-- A matching MediaFile element exists, transform from this -->
                    <xsl:apply-templates select="$writtenResource" mode="COMMONTLA2IMDISESSION"/>
                </xsl:when>
                <xsl:when test="//InfoLink[@ref=current()/@id]">
                    <!-- info link exist, processed elsewhere, skip -->
                </xsl:when>
                <xsl:when test="matches(ResourceType/@mimetype, $writtenResourceMimeTypes)">
                    <!-- No matching MediaFile, generate on basis of proxy alone -->
                    <xsl:message>A WrittenResource element for ResourceProxy with id '<xsl:value-of select="@id" />' is generated on basis of mimetype <xsl:value-of select="ResourceType/@mimetype" /></xsl:message>
                    <WrittenResource>
                        <xsl:comment>NOTE: CMDI2IMDI - No WrittenResource element was found for this resource, minimal information was generated on basis of ResourceProxy only</xsl:comment>
                        <xsl:call-template name="generate-ResourceId"></xsl:call-template>
                        <ResourceLink><xsl:apply-templates select="." mode="create-resource-link-content"/></ResourceLink>
                        <MediaResourceLink />
                        <Date>Unspecified</Date>
                        <Type>Unspecified</Type>
                        <SubType>Unspecified</SubType>
                        <Format><xsl:value-of select="ResourceType/@mimetype"/></Format>
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
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="WrittenResource" mode="COMMONTLA2IMDISESSION">
        <xsl:if test="normalize-space(@ref) = ''">
            <xsl:message>WrittenResource found without a resource reference, could not generate resource link value</xsl:message>
        </xsl:if>
        
        <WrittenResource>
            <xsl:call-template name="generate-ResourceId"></xsl:call-template>
            <ResourceLink><xsl:apply-templates select="//ResourceProxy[@id eq current()/@ref]" mode="create-resource-link-content"/></ResourceLink>
            <MediaResourceLink>
                <xsl:if test="@mediaRef">
                    <xsl:apply-templates select="//ResourceProxy[@id eq current()/@mediaRef]" mode="create-resource-link-content"/>
                </xsl:if>
            </MediaResourceLink>     
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
                <xsl:apply-templates select="Validation/descriptions" mode="COMMONTLA2IMDISESSION"/>
            </Validation>
            <Derivation><xsl:value-of select="Derivation"/></Derivation>
            <CharacterEncoding><xsl:value-of select="CharacterEncoding"/></CharacterEncoding>
            <ContentEncoding><xsl:value-of select="ContentEncoding"/></ContentEncoding>
            <LanguageId><xsl:value-of select="LanguageId"/></LanguageId>
            <Anonymized><xsl:value-of select="Anonymized"/></Anonymized>
            <xsl:apply-templates select="Access" mode="COMMONTLA2IMDISESSION" /> 
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
            <Keys>
                <xsl:apply-templates select="Keys" mode="COMMONTLA2IMDISESSION"/>
            </Keys>
        </WrittenResource>
    </xsl:template>
    
    <xsl:template match="Source" mode="COMMONTLA2IMDISESSION">
        <Source>
            <Id><xsl:value-of select="Id" /></Id>
            <Format><xsl:value-of select="Format" /></Format>
            <Quality><xsl:value-of select="Quality" /></Quality>
            <xsl:apply-templates select="CounterPosition" mode="COMMONTLA2IMDISESSION" />
            <xsl:apply-templates select="TimePosition" mode="COMMONTLA2IMDISESSION" />
            <xsl:apply-templates select="Access" mode="COMMONTLA2IMDISESSION" />            
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>
            <Keys>
                <xsl:apply-templates select="Keys" mode="COMMONTLA2IMDISESSION"/>
            </Keys>
        </Source>
    </xsl:template>
    
    <xsl:template match="CounterPosition|TimePosition" mode="COMMONTLA2IMDISESSION">
        <xsl:element name="{name()}">
            <Start><xsl:value-of select="Start" /></Start>
            <End><xsl:value-of select="End" /></End>
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template match="Access" mode="COMMONTLA2IMDISESSION">
        <Access>
            <Availability><xsl:value-of select="Availability"/></Availability>
            <Date><xsl:value-of select="Date"/></Date>
            <Owner><xsl:value-of select="Owner"/></Owner>
            <Publisher><xsl:value-of select="Publisher"/></Publisher>
            <Contact><xsl:apply-templates select="Contact" mode="COMMONTLA2IMDISESSION"/></Contact>
            <xsl:apply-templates select="descriptions" mode="COMMONTLA2IMDISESSION"/>                
        </Access>
    </xsl:template>
    
    <xsl:template match="Contact" mode="COMMONTLA2IMDISESSION">
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
    
    <xsl:template match="Keys" mode="COMMONTLA2IMDISESSION">
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
    
    <xsl:template name="generate-ResourceId">
        <xsl:if test="//Actor[@ref=current()/@ref]">
            <xsl:attribute name="ResourceId" select="@ref" />
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>