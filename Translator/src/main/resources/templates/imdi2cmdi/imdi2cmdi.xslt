<?xml version="1.0" encoding="UTF-8"?>
<!--
$Rev: 3378 $
$LastChangedDate: 2013-08-14 11:25:31 +0200 (Wed, 14 Aug 2013) $
-->
<xsl:stylesheet xmlns="http://www.clarin.eu/cmd/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0" xpath-default-namespace="http://www.mpi.nl/IMDI/Schema/IMDI" xmlns:imdi="http://www.mpi.nl/IMDI/Schema/IMDI" xmlns:lat="http://lat.mpi.nl/" xmlns:iso="http://www.iso.org/" xmlns:sil="http://www.sil.org/">
    <!-- this is a version of imdi2clarin.xsl that batch processes a whole directory structure of imdi files, call it from the command line like this:
        java -jar saxon8.jar -it main batch-imdi2clarin.xsl
        the last template in this file has to be modified to reflect the actual directory name
    -->
    <xsl:output method="xml" indent="yes"/>

    <!-- A collection name can be specified for each record. This
    information is extrinsic to the IMDI file, so it is given as an
    external parameter. Omit this if you are unsure. -->
    <xsl:param name="collection"/>

    <!-- If this optional parameter is defined, the behaviour of this
    stylesheet changes in the following ways: If no archive handle is
    available for MdSelfLink, the base URI is inserted there
    instead. All links (ResourceProxy elements) that contain relative
    paths are resolved into absolute URIs in the context of the base
    URI. Omit this if you are unsure. -->
	<xsl:param name="uri-base" select="base-uri()"/>
	
	<xsl:param name="localURI" select="true()"/>
	
	<xsl:param name="formatCMDI" select="true()"/>
	
	<!--<xsl:param name="base" select="base-uri(document(''))"/>-->
	<xsl:param name="base" select="static-base-uri()"/>
	
	<xsl:variable name="sil-lang-top" select="document(resolve-uri('sil_to_iso6393.xml',$base))/sil:languages"/>
	<xsl:key name="sil-lookup" match="sil:lang" use="sil:sil"/>
	
	<xsl:variable name="iso-lang-uri" select="resolve-uri('iso2iso.xml',$base)"/>
	<xsl:variable name="iso-lang-doc" select="document($iso-lang-uri)"/>
	<xsl:variable name="iso-lang-top" select="$iso-lang-doc/iso:m"/>
	<xsl:key name="iso639_1-lookup" match="iso:e" use="iso:o"/>
	<xsl:key name="iso639_2-lookup" match="iso:e" use="iso:b|iso:t"/>
	
	<!-- definition of the SRU-searchable collections at TLA (for use later on) -->
    <xsl:variable name="SruSearchable">childes,ESF corpus,IFA corpus,MPI CGN,talkbank</xsl:variable>
    

	<!-- fix the closed vocabularies -->
	<xsl:template match="@*|node()" mode="fixVocab">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*[@Type='ClosedVocabulary'][exists(@Link)][normalize-space()='']" mode="fixVocab">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
			<xsl:text>Unspecified</xsl:text>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="/">
		<xsl:variable name="fixVocab">
			<xsl:apply-templates mode="fixVocab"/>
		</xsl:variable>
		<xsl:apply-templates select="$fixVocab/*"/>
	</xsl:template>
	
	<!-- do the IMDI to CMDI conversion -->
    <xsl:template name="metatranscriptDelegate">
        <xsl:param name="profile"/>
        <xsl:param name="type"/>
        <Header>
            <MdCreator>
            	<xsl:choose>
            		<xsl:when test="normalize-space(@Originator)!=''">
            			<xsl:value-of select="@Originator"/>
            		</xsl:when>
            		<xsl:otherwise>
            			<xsl:text>imdi2cmdi.xsl</xsl:text>
            		</xsl:otherwise>
            	</xsl:choose>
            </MdCreator>
            <MdCreationDate>
            	<xsl:choose>
            		<xsl:when test="normalize-space(@Date)!=''">
            			<xsl:value-of select="@Date"/>
            		</xsl:when>
            		<xsl:otherwise>
            			<xsl:value-of select="format-date(current-date(), '[Y]-[M01]-[D01]')"/>
            		</xsl:otherwise>
            	</xsl:choose>
            </MdCreationDate>
            <MdSelfLink>
                <xsl:choose>
                    <!-- MPI handle prefix? Use handle + @format=cmdi suffix -->
                    <xsl:when test="starts-with(normalize-space(@ArchiveHandle), 'hdl:1839/')"><xsl:value-of select="@ArchiveHandle"/>@format=cmdi</xsl:when>
                    <!-- No handle? Then just use the URL -->
                    <xsl:when test="not($uri-base='') and normalize-space(@ArchiveHandle)=''"><xsl:value-of select="$uri-base"/></xsl:when>
                    <!-- Other handle prefix? Use handle (e.g. Lund) -->
                    <xsl:otherwise><xsl:value-of select="@ArchiveHandle"/></xsl:otherwise>
                </xsl:choose>
            </MdSelfLink>
            <MdProfile>
                <xsl:value-of select="$profile"/>
            </MdProfile>
            <xsl:if test="$collection">
                <MdCollectionDisplayName>
                    <xsl:value-of select="$collection"/>
                </MdCollectionDisplayName>
            </xsl:if>
        </Header>
        <Resources>
            <ResourceProxyList>
                <xsl:apply-templates select="//Resources" mode="linking"/>
                <xsl:apply-templates select="//Description[not(normalize-space(./@ArchiveHandle)='') or not(normalize-space(./@Link)='')]" mode="linking"/>
                <xsl:apply-templates select="//Corpus" mode="linking"/>
                <!-- If this collection name is indicated to be SRU-searchable, add a link to the TLA SRU endpoint -->
                <xsl:if test="$collection and contains($SruSearchable,$collection)">
                <ResourceProxy id="sru">
                    <ResourceType>SearchService</ResourceType>
                    <ResourceRef>http://cqlservlet.mpi.nl/</ResourceRef>
                </ResourceProxy>
                </xsl:if>
                <xsl:if test="$type='corpus' and starts-with(normalize-space(@ArchiveHandle), 'hdl:1839/')">
                    <ResourceProxy id="searchpage">
                        <ResourceType>SearchPage</ResourceType>
                        <ResourceRef>
                            <xsl:text>http://corpus1.mpi.nl/ds/trova/search.jsp?handle=</xsl:text>
                            <xsl:value-of select="@ArchiveHandle"/></ResourceRef>
                    </ResourceProxy>
                </xsl:if>
            </ResourceProxyList>
            <JournalFileProxyList> </JournalFileProxyList>
            <ResourceRelationList> </ResourceRelationList>
        </Resources>
        <Components>
            <xsl:apply-templates select="Session"/>
            <xsl:apply-templates select="Corpus"/>
        </Components>
    </xsl:template>

    <xsl:template match="METATRANSCRIPT">
        <xsl:choose>
            <xsl:when test=".[@Type='SESSION'] or .[@Type='SESSION.Profile']">
            	<xsl:variable name="profile" select="'clarin.eu:cr1:p_1407745712035'"/>
                <CMD CMDVersion="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://www.clarin.eu/cmd/ http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/{$profile}/xsd">
                    <xsl:call-template name="metatranscriptDelegate">
                        <xsl:with-param name="type" select="'session'"/>
                        <xsl:with-param name="profile" select="$profile"/>
                    </xsl:call-template>
                </CMD>
            </xsl:when>
            <xsl:when test=".[@Type='CORPUS'] or .[@Type='CORPUS.Profile']">
            	<xsl:variable name="profile" select="'clarin.eu:cr1:p_1407745712064'"/>
                <CMD CMDVersion="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://www.clarin.eu/cmd/ http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/{$profile}/xsd">
                    <xsl:call-template name="metatranscriptDelegate">
                        <xsl:with-param name="type" select="'corpus'"/>
                        <xsl:with-param name="profile" select="$profile"/>
                    </xsl:call-template>
                </CMD>
            </xsl:when>
            <xsl:otherwise>
                <!-- Currently we are only processing 'SESSION' and 'CORPUS' types. The error displayed can be used to filter out erroneous files after processing-->
            	<xsl:message terminate="yes">ERROR: Invalid METATRANSCRIPT Type!</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="Corpus">
        <lat-corpus>
        	<xsl:apply-templates select="preceding-sibling::History"/>
            <xsl:apply-templates select="child::Name"/>
            <xsl:apply-templates select="child::Title"/>
            <xsl:variable name="descriptions" select="Description[normalize-space(@ArchiveHandle)='' and normalize-space(@Link)=''][normalize-space(.)!='']"/>
            <xsl:variable name="infoLinks" select="Description[normalize-space(@ArchiveHandle)!='' or normalize-space(@Link)!='']"/>
            <xsl:if test="exists($descriptions)">
                <descriptions>
                    <xsl:for-each select="$descriptions">
                    	<Description>
                    		<xsl:call-template name="xmlLang"/>
                    		<xsl:value-of select="."/>
                    	</Description>
                    </xsl:for-each>
                </descriptions>
            </xsl:if>
            <xsl:for-each select="$infoLinks">
            	<InfoLink ref="{generate-id(.)}">
            		<xsl:if test="normalize-space(.)!=''">
            			<Description>
            				<xsl:call-template name="xmlLang"/>
            				<xsl:value-of select="."/>
            			</Description>
            		</xsl:if>
            	</InfoLink>
            </xsl:for-each>
            <xsl:if test="exists(child::CorpusLink)">
                <xsl:for-each select="CorpusLink">
                    <CorpusLink ref="{generate-id(.)}">
						<Name>
							<xsl:value-of select="@Name"/>
						</Name>
                    </CorpusLink>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="normalize-space(@CatalogueLink)!=''">
            	<!--<xsl:variable name="cat" select="resolve-uri(@CatalogueLink,$uri-base)"/>-->
            	<xsl:variable name="cat" select="replace(@CatalogueHandle,'hdl:','http://hdl.handle.net/')"/>
            	<xsl:choose>
            		<xsl:when test="doc-available($cat)">
            			<xsl:variable name="catalogue" select="doc($cat)"/>
            			<xsl:for-each select="$catalogue/METATRANSCRIPT/Catalogue">
            				<Catalogue>
            					<!-- CMD Elements -->
            					<xsl:for-each select="ContentType[normalize-space()!='']">
            						<ContentType>
            							<xsl:value-of select="."/>
            						</ContentType>
            					</xsl:for-each>
            					<xsl:if test="normalize-space(SmallestAnnotationUnit)!=''">
            						<SmallestAnnotationUnit>
            							<xsl:call-template name="orUnspecified">
            								<xsl:with-param name="value" select="SmallestAnnotationUnit"/>
            							</xsl:call-template>
            						</SmallestAnnotationUnit>
            					</xsl:if>
            					<xsl:if test="normalize-space(Date)!=''">
            						<Date>
            							<xsl:call-template name="orUnspecified">
            								<xsl:with-param name="value" select="Date"/>
            							</xsl:call-template>
            						</Date>
            					</xsl:if>
            					<xsl:for-each select="Publisher[normalize-space()!='']">
            						<Publisher>
            							<xsl:value-of select="."/>
            						</Publisher>
            					</xsl:for-each>
            					<xsl:for-each select="Author[normalize-space()!='']">
            						<Author>
            							<xsl:value-of select="."/>
            						</Author>
            					</xsl:for-each>
            					<xsl:if test="normalize-space(Size)!=''">
            						<Size>
            							<xsl:value-of select="Size"/>
            						</Size>
            					</xsl:if>
            					<xsl:if test="normalize-space(DistributionForm)!=''">
            						<DistributionForm>
            							<xsl:call-template name="orUnspecified">
            								<xsl:with-param name="value" select="DistributionForm"/>
            							</xsl:call-template>
            						</DistributionForm>
            					</xsl:if>
            					<xsl:if test="normalize-space(Pricing)!=''">
            						<Pricing>
            							<xsl:value-of select="Pricing"/>
            						</Pricing>
            					</xsl:if>
            					<xsl:if test="normalize-space(ContactPerson)!=''">
            						<ContactPerson>
            							<xsl:value-of select="ContactPerson"/>
            						</ContactPerson>
            					</xsl:if>
            					<xsl:if test="normalize-space(Publications)!=''">
            						<Publications>
            							<xsl:value-of select="Publications"/>
            						</Publications>
            					</xsl:if>
            					<!-- CMD Components -->
            					<xsl:if test="exists(Description[normalize-space()!=''])">
            						<descriptions>
            							<xsl:for-each select="Description[normalize-space()!='']">
            								<Description>
            									<xsl:call-template name="xmlLang"/>
            									<xsl:value-of select="."/>
            								</Description>
            							</xsl:for-each>
            						</descriptions>
            					</xsl:if>
            					<xsl:variable name="doclangs" select="DocumentLanguages/Language[normalize-space()!='']"/>
            					<xsl:if test="exists($doclangs)">
            						<Document_Languages>
            							<xsl:for-each select="$doclangs">
            								<Document_Language>
            									<Id>
            										<xsl:call-template name="orUnspecified">
            											<xsl:with-param name="value" select="Id"/>
            										</xsl:call-template>
            									</Id>
            									<Name>
            										<xsl:value-of select=" ./Name"/>
            									</Name>
            								</Document_Language>
            							</xsl:for-each>
            						</Document_Languages>
            					</xsl:if>
            					<xsl:variable name="sublangs" select="SubjectLanguages/Language[normalize-space()!='']"/>
            					<xsl:if test="exists($sublangs)">
            						<Subject_Languages>
            							<xsl:for-each select="$sublangs">
            								<Subject_Language>
            									<Id>
            										<xsl:call-template name="orUnspecified">
            											<xsl:with-param name="value" select="Id"/>
            										</xsl:call-template>
            									</Id>
            									<Name>
            										<xsl:value-of select=" ./Name"/>
            									</Name>
            									<Dominant>
            										<xsl:call-template name="orUnspecified">
            											<xsl:with-param name="value" select="Dominant"/>
            										</xsl:call-template>
            									</Dominant>
            									<SourceLanguage>
            										<xsl:call-template name="orUnspecified">
            											<xsl:with-param name="value" select="SourceLanguage"/>
            										</xsl:call-template>
            									</SourceLanguage>
            									<TargetLanguage>
            										<xsl:call-template name="orUnspecified">
            											<xsl:with-param name="value" select="TargetLanguage"/>
            										</xsl:call-template>
            									</TargetLanguage>
            									<xsl:if test="exists(Description[normalize-space()!=''])">
            										<descriptions>
            											<xsl:for-each select="Description[normalize-space()!='']">
            												<Description>
            													<xsl:call-template name="xmlLang"/>
            													<xsl:value-of select="."/>
            												</Description>
            											</xsl:for-each>
            										</descriptions>
            									</xsl:if>
            								</Subject_Language>
            							</xsl:for-each>
            						</Subject_Languages>
            					</xsl:if>
            					<xsl:apply-templates select="Location"/>
            					<xsl:if test="exists(Format/*[normalize-space()!=''])">
            						<Format>
            							<xsl:for-each select="Format/*[normalize-space()!='']">
            								<xsl:variable name="name" select="local-name()"/>
            								<xsl:for-each select="tokenize(.,',')">
            									<xsl:element name="{$name}">
            										<xsl:value-of select="normalize-space(.)"/>
            									</xsl:element>
            								</xsl:for-each>
            							</xsl:for-each>
            						</Format>
            					</xsl:if>
            					<xsl:if test="exists(Quality/*[normalize-space()!=''])">
            						<Quality>
            							<xsl:for-each select="Quality/*[normalize-space()!='']">
            								<xsl:variable name="name" select="local-name()"/>
            								<xsl:for-each select="tokenize(.,',')">
            									<xsl:element name="{$name}">
            										<xsl:call-template name="orUnspecified">
            											<xsl:with-param name="value" select="."/>
            										</xsl:call-template>
            									</xsl:element>
            								</xsl:for-each>
            							</xsl:for-each>
            						</Quality>
            					</xsl:if>
            					<!-- TODO -->
            					<xsl:apply-templates select="Project"/>
            					<xsl:apply-templates select="Access"/>
            					<xsl:apply-templates select="Keys"/>
            				</Catalogue>
            			</xsl:for-each>
            		</xsl:when>
            		<xsl:otherwise>
            			<xsl:message>WRN: IMDI catalogue file[<xsl:value-of select="$cat"/>] couldn't be loaded!</xsl:message>
            		</xsl:otherwise>
            	</xsl:choose>
            </xsl:if>
        </lat-corpus>
    </xsl:template>

    <xsl:template match="Corpus" mode="linking">
        <xsl:for-each select="CorpusLink">
            <ResourceProxy id="{generate-id(.)}">
                <!-- Do we have both archive handle and link (text content)? -->
                <xsl:if test="not($localURI) and (not(normalize-space(./@ArchiveHandle)='' or normalize-space(.)=''))">
                    <!-- Archive handle is kept, but original link is lost in CMDI. Keep content in a comment. -->
                    <xsl:comment>
                        <xsl:value-of select="."/>
                    </xsl:comment>
                </xsl:if>
                <ResourceType>Metadata</ResourceType>
            	<ResourceRef>
            		<xsl:if test="$localURI">
            			<xsl:attribute name="lat:localURI" select="replace(.,'\.imdi','.cmdi')"/>
            		</xsl:if>
            		<xsl:choose>
                        <!-- Check for archive handle attribute -->
                        <xsl:when test="not(normalize-space(./@ArchiveHandle)='')">
                            <xsl:choose>
                                <!-- MPI handle prefix? Use handle + @format=cmdi suffix -->
                                <xsl:when test="starts-with(normalize-space(@ArchiveHandle), 'hdl:1839/')">
                                	<xsl:value-of select="@ArchiveHandle"/>
                                	<xsl:if test="$formatCMDI">
                                		<xsl:text>@format=cmdi</xsl:text>
                                	</xsl:if>
                                </xsl:when>
                                <!-- Other handle prefix? Use handle (e.g. Lund) -->
                                <xsl:otherwise>
                                	<xsl:value-of select="@ArchiveHandle"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <!-- Is link a handle? -->
                        <xsl:when test="starts-with(., 'hdl:')">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <!-- Fallback: use original link, append .cmdi. Resolve from base URI if available. -->
                        <xsl:when test="$uri-base=''">
                        	<xsl:value-of select="replace(.,'\.imdi','.cmdi')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="replace(resolve-uri(normalize-space(.), $uri-base),'\.imdi','.cmdi')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </ResourceRef>
            </ResourceProxy>
        </xsl:for-each>
    </xsl:template>

    <!-- Create ResourceProxy for MediaFile and WrittenResource -->
    <xsl:template match="Resources" mode="linking">
    	<xsl:for-each select="MediaFile">
            <xsl:call-template name="CreateResourceProxyTypeResource"/>
        </xsl:for-each>
    	<xsl:for-each select="WrittenResource">
            <xsl:call-template name="CreateResourceProxyTypeResource"/>
        </xsl:for-each>
    	<xsl:for-each select="Anonyms">
    		<xsl:call-template name="CreateResourceProxyTypeResource"/>
    	</xsl:for-each>
    </xsl:template>
    
    <!-- to be called during the creation of the ResourceProxyList (in linking mode) -->
    <xsl:template name="CreateResourceProxyTypeResource">
    	<xsl:if test="normalize-space(ResourceLink)!=''">
    		<ResourceProxy id="{generate-id(ResourceLink)}">
    			<ResourceType>
    				<xsl:if test="exists(Format) and not(empty(Format))">
    					<xsl:attribute name="mimetype">
    						<xsl:value-of select="./Format"/>
    					</xsl:attribute>
    				</xsl:if>Resource</ResourceType>
    			<ResourceRef>
    				<xsl:if test="$localURI">
    					<xsl:attribute name="lat:localURI" select="ResourceLink"/>
    				</xsl:if>
    				<xsl:choose>
    					<xsl:when test="not(normalize-space(ResourceLink/@ArchiveHandle)='')">
    						<xsl:value-of select="ResourceLink/@ArchiveHandle"/>
    					</xsl:when>
    					<xsl:when test="not($uri-base='')">
    						<xsl:value-of
    							select="resolve-uri(normalize-space(ResourceLink/.), $uri-base)"/>
    					</xsl:when>
    				</xsl:choose>
    			</ResourceRef>
    		</ResourceProxy>
    	</xsl:if>
    </xsl:template>

	<!-- Create ResourceProxy for Info files -->
	<xsl:template match="//Description[@ArchiveHandle or @Link]" mode="linking">
		<xsl:variable name="res">
			<xsl:choose>
				<xsl:when test="normalize-space(@ArchiveHandle)!=''">
					<xsl:value-of select="@ArchiveHandle"/>
				</xsl:when>
				<xsl:when test="normalize-space(@Link)!=''">
					<xsl:value-of select="@Link"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space($res)!=''">
			<ResourceProxy id="{generate-id(.)}">
				<ResourceType>
					<xsl:choose>
						<xsl:when test="ends-with(@Link,'.html') or ends-with($res,'.htm')">
							<xsl:attribute name="mimetype" select="'text/html'"/>
						</xsl:when>
						<xsl:when test="ends-with(@Link,'.pdf')">
							<xsl:attribute name="mimetype" select="'application/pdf'"/>
						</xsl:when>
					</xsl:choose>
					<xsl:text>Resource</xsl:text>
				</ResourceType>
				<ResourceRef>
					<xsl:if test="$localURI and normalize-space(@Link)!=''">
						<xsl:attribute name="lat:localURI" select="@Link"/>
					</xsl:if>
					<xsl:value-of select="$res"/>
				</ResourceRef>
			</ResourceProxy>
		</xsl:if>
	</xsl:template> 
	
	

    <xsl:template match="Session">
        <lat-session>
        	<xsl:apply-templates select="preceding-sibling::History"/>
            <xsl:apply-templates select="child::Name"/>
            <xsl:apply-templates select="child::Title"/>
            <xsl:apply-templates select="child::Date"/>
        	<xsl:variable name="descriptions" select="Description[normalize-space(@ArchiveHandle)='' and normalize-space(@Link)=''][normalize-space(.)!='']"/>
        	<xsl:variable name="infoLinks" select="Description[normalize-space(@ArchiveHandle)!='' or normalize-space(@Link)!='']"/>
        	<xsl:if test="exists($descriptions)">
        		<descriptions>
        			<xsl:for-each select="$descriptions">
        				<Description>
        					<xsl:call-template name="xmlLang"/>
        					<xsl:value-of select="."/>
        				</Description>
        			</xsl:for-each>
        		</descriptions>
        	</xsl:if>
        	<xsl:for-each select="$infoLinks">
        		<InfoLink ref="{generate-id(.)}">
        			<Description>
        				<xsl:call-template name="xmlLang"/>
        				<xsl:value-of select="."/>
        			</Description>
        		</InfoLink>
        	</xsl:for-each>
        	<xsl:apply-templates select="child::MDGroup"/>
            <xsl:apply-templates select="child::Resources" mode="regular"/>
            <xsl:apply-templates select="child::References"/>
        </lat-session>
    </xsl:template>

	<xsl:template match="child::History">
		<History>
			<xsl:value-of select="."/>
			<!--<xsl:value-of select="system-property('line.separator')"/>-->
			<xsl:text> NAME:imdi2cmdi.xslt DATE:</xsl:text>
			<xsl:value-of select="current-dateTime()"/>
			<xsl:text>.</xsl:text>
		</History>
	</xsl:template>
	
	<xsl:template match="child::Name">
        <Name>
            <xsl:value-of select="."/>
        </Name>
    </xsl:template>

    <xsl:template match="child::Title">
        <Title>
            <xsl:value-of select="."/>
        </Title>
    </xsl:template>

    <xsl:template match="child::Date">
        <Date>
        	<xsl:call-template name="orUnspecified">
        		<xsl:with-param name="value" select="."/>
        	</xsl:call-template>
        </Date>
    </xsl:template>

    <xsl:template match="child::MDGroup">
        <xsl:apply-templates select="child::Location"/>
        <xsl:apply-templates select="child::Project"/>
        <xsl:apply-templates select="child::Keys"/>
        <xsl:apply-templates select="child::Content"/>
        <xsl:apply-templates select="child::Actors"/>
    </xsl:template>

    <xsl:template match="Location">
        <Location>
            <Continent>
            	<xsl:call-template name="orUnspecified">
            		<xsl:with-param name="value" select="Continent"/>
            	</xsl:call-template>
            </Continent>
            <Country>
                <xsl:value-of select="child::Country"/>
            </Country>
            <xsl:if test="exists(child::Region)">
                <Region>
                    <xsl:value-of select="child::Region"/>
                </Region>
            </xsl:if>
            <xsl:if test="exists(child::Address)">
                <Address>
                    <xsl:value-of select="child::Address"/>
                </Address>
            </xsl:if>
        </Location>
    </xsl:template>

    <xsl:template match="Project">
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
            <xsl:apply-templates select="Contact"/>
            <xsl:if test="exists(Description[normalize-space(.)!=''])">
                <descriptions>
                	<xsl:for-each select="Description[normalize-space(.)!='']">
                        <Description>
                        	<xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="."/>
                        </Description>
                    </xsl:for-each>
                </descriptions>
            </xsl:if>
        </Project>
    </xsl:template>

	<xsl:template match="Contact">
		<Contact>
			<xsl:if test="normalize-space(Name)!=''">
				<Name>
					<xsl:value-of select="child::Name"/>
				</Name>
			</xsl:if>
			<xsl:if test="normalize-space(Address)!=''">
				<Address>
					<xsl:value-of select="child::Address"/>
				</Address>
			</xsl:if>
			<xsl:if test="normalize-space(Email)!=''">
				<Email>
					<xsl:value-of select="child::Email"/>
				</Email>
			</xsl:if>
			<xsl:if test="normalize-space(Organisation)!=''">
				<Organisation>
					<xsl:value-of select="child::Organisation"/>
				</Organisation>
			</xsl:if>
		</Contact>
	</xsl:template>

    <xsl:template match="Keys">
    	<xsl:if test="exists(Key[normalize-space(@Name)!='' or normalize-space(.)!=''])">
    		<Keys>
    			<xsl:for-each select="Key[normalize-space(@Name)!='' or normalize-space(.)!='']">
    				<Key>
    					<xsl:attribute name="Name">
    						<xsl:value-of select="@Name"/>
    					</xsl:attribute>
    					<xsl:value-of select="."/>
    				</Key>
    			</xsl:for-each>
    		</Keys>
    	</xsl:if>
    </xsl:template>

    <xsl:template match="Content">
        <Content>
            <Genre>
                <xsl:value-of select="child::Genre"/>
            </Genre>
            <xsl:if test="exists(child::SubGenre)">
                <SubGenre>
                    <xsl:value-of select="child::SubGenre"/>
                </SubGenre>
            </xsl:if>
            <xsl:if test="exists(child::Task)">
                <Task>
                    <xsl:value-of select="child::Task"/>
                </Task>
            </xsl:if>
            <xsl:if test="exists(child::Modalities)">
                <Modalities>
                    <xsl:value-of select="child::Modalities"/>
                </Modalities>
            </xsl:if>
            <xsl:if test="exists(child::Subject)">
                <Subject>
                    <xsl:value-of select="child::Subject"/>
                </Subject>
            </xsl:if>
            <xsl:apply-templates select="child::CommunicationContext"/>
            <xsl:apply-templates select="child::Languages" mode="content"/>
            <xsl:apply-templates select="child::Keys"/>
        	<xsl:if test="exists(child::Description[normalize-space()!=''])">
                <descriptions>
                	<xsl:for-each select="Description[normalize-space()!='']">
                        <Description>
                        	<xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="."/>
                        </Description>
                    </xsl:for-each>
                </descriptions>
            </xsl:if>
        </Content>

    </xsl:template>

    <xsl:template match="CommunicationContext">
        <CommunicationContext>
            <xsl:if test="exists(child::Interactivity)">
                <Interactivity>
                	<xsl:call-template name="orUnspecified">
                		<xsl:with-param name="value" select="Interactivity"/>
                	</xsl:call-template>
                </Interactivity>
            </xsl:if>
            <xsl:if test="exists(child::PlanningType)">
                <PlanningType>
                	<xsl:call-template name="orUnspecified">
                		<xsl:with-param name="value" select="PlanningType"/>
                	</xsl:call-template>
                </PlanningType>
            </xsl:if>
            <xsl:if test="exists(child::Involvement)">
                <Involvement>
                	<xsl:call-template name="orUnspecified">
                		<xsl:with-param name="value" select="Involvement"/>
                	</xsl:call-template>
                </Involvement>
            </xsl:if>
            <xsl:if test="exists(child::SocialContext)">
                <SocialContext>
                	<xsl:call-template name="orUnspecified">
                		<xsl:with-param name="value" select="SocialContext"/>
                	</xsl:call-template>
                </SocialContext>
            </xsl:if>
            <xsl:if test="exists(child::EventStructure)">
                <EventStructure>
                	<xsl:call-template name="orUnspecified">
                		<xsl:with-param name="value" select="EventStructure"/>
                	</xsl:call-template>
                </EventStructure>
            </xsl:if>
            <xsl:if test="exists(child::Channel)">
                <Channel>
                	<xsl:call-template name="orUnspecified">
                		<xsl:with-param name="value" select="Channel"/>
                	</xsl:call-template>
                </Channel>
            </xsl:if>
        </CommunicationContext>
    </xsl:template>

    <xsl:template match="Languages" mode="content">
    	<xsl:if test="exists(Description[normalize-space(.)!='']|Language)">
    		<Content_Languages>
    			<xsl:if test="exists(child::Description[normalize-space(.)!=''])">
    				<descriptions>
    					<xsl:for-each select="Description[normalize-space(.)!='']">
    						<Description>
    							<xsl:call-template name="xmlLang"/>
    							<xsl:value-of select="."/>
    						</Description>
    					</xsl:for-each>
    				</descriptions>
    			</xsl:if>
    			<xsl:for-each select="Language">
    				<Content_Language>
    					<Id>
    						<xsl:call-template name="orUnspecified">
    							<xsl:with-param name="value" select="Id"/>
    						</xsl:call-template>
    					</Id>
    					<Name>
    						<xsl:value-of select=" ./Name"/>
    					</Name>
    					<Dominant>
    						<xsl:call-template name="orUnspecified">
    							<xsl:with-param name="value" select="Dominant"/>
    						</xsl:call-template>
    					</Dominant>
    					<SourceLanguage>
    						<xsl:call-template name="orUnspecified">
    							<xsl:with-param name="value" select="SourceLanguage"/>
    						</xsl:call-template>
    					</SourceLanguage>
    					<TargetLanguage>
    						<xsl:call-template name="orUnspecified">
    							<xsl:with-param name="value" select="TargetLanguage"/>
    						</xsl:call-template>
    					</TargetLanguage>
    					<xsl:if test="exists(child::Description[normalize-space(.)!=''])">
    						<descriptions>
    							<xsl:for-each select="Description[normalize-space(.)!='']">
    								<Description>
    									<xsl:call-template name="xmlLang"/>
    									<xsl:value-of select="."/>
    								</Description>
    							</xsl:for-each>
    						</descriptions>
    					</xsl:if>
    				</Content_Language>
    			</xsl:for-each>
    		</Content_Languages>
    	</xsl:if>
    </xsl:template>

    <xsl:template match="Actors">
        <Actors>
            <xsl:if test="exists(child::Description[normalize-space(.)!=''])">
                <descriptions>
                	<xsl:for-each select="Description[normalize-space(.)!='']">
                        <Description>
                        	<xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="."/>
                        </Description>
                    </xsl:for-each>
                </descriptions>
            </xsl:if>
            <xsl:for-each select="Actor">
                <Actor>
                    <Role>
                        <xsl:value-of select=" ./Role"/>
                    </Role>
                    <Name>
                        <xsl:value-of select=" ./Name"/>
                    </Name>
                    <FullName>
                        <xsl:value-of select=" ./FullName"/>
                    </FullName>
                    <Code>
                        <xsl:value-of select=" ./Code"/>
                    </Code>
                    <FamilySocialRole>
                        <xsl:value-of select=" ./FamilySocialRole"/>
                    </FamilySocialRole>
                    <EthnicGroup>
                        <xsl:value-of select=" ./EthnicGroup"/>
                    </EthnicGroup>
                    <Age>
                    	<xsl:call-template name="orUnspecified">
                    		<xsl:with-param name="value" select="Age"/>
                    	</xsl:call-template>
                    </Age>
                    <BirthDate>
                    	<xsl:call-template name="orUnspecified">
                    		<xsl:with-param name="value" select="BirthDate"/>
                    	</xsl:call-template>
                    </BirthDate>
                    <Sex>
                    	<xsl:call-template name="orUnspecified">
                    		<xsl:with-param name="value" select="Sex"/>
                    	</xsl:call-template>
                    </Sex>
                    <Education>
                        <xsl:value-of select=" ./Education"/>
                    </Education>
                    <Anonymized>
                    	<xsl:call-template name="orUnspecified">
                    		<xsl:with-param name="value" select="Anonymized"/>
                    	</xsl:call-template>
                    </Anonymized>
                    <xsl:apply-templates select="Contact"/>
                    <xsl:apply-templates select="child::Keys"/>
                    <xsl:if test="exists(child::Description[normalize-space(.)!=''])">
                        <descriptions>
                            <xsl:for-each select="Description[normalize-space(.)!='']">
                                <Description>
                                	<xsl:call-template name="xmlLang"/>
                                    <xsl:value-of select="."/>
                                </Description>
                            </xsl:for-each>
                        </descriptions>
                    </xsl:if>
                    <xsl:apply-templates select="child::Languages" mode="actor"/>
                </Actor>
            </xsl:for-each>
        </Actors>
    </xsl:template>

    <xsl:template match="Languages" mode="actor">
        <Actor_Languages>
            <xsl:if test="exists(child::Description[normalize-space(.)!=''])">
                <descriptions>
                	<xsl:for-each select="Description[normalize-space(.)!='']">
                        <Description>
                        	<xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="."/>
                        </Description>
                    </xsl:for-each>
                </descriptions>
            </xsl:if>
            <xsl:for-each select="Language">
                <Actor_Language>
                    <Id>
                    	<xsl:call-template name="orUnspecified">
                    		<xsl:with-param name="value" select="Id"/>
                    	</xsl:call-template>
                    </Id>
                    <Name>
                        <xsl:value-of select=" ./Name"/>
                    </Name>
                    <MotherTongue>
                    	<xsl:call-template name="orUnspecified">
                    		<xsl:with-param name="value" select="MotherTongue"/>
                    	</xsl:call-template>
                    </MotherTongue>
                    <PrimaryLanguage>
                    	<xsl:call-template name="orUnspecified">
                    		<xsl:with-param name="value" select="PrimaryLanguage"/>
                    	</xsl:call-template>
                    </PrimaryLanguage>
                	<xsl:if test="exists(child::Description[normalize-space(.)!=''])">
                        <descriptions>
                        	<xsl:for-each select="Description[normalize-space(.)!='']">
                                <Description>
                                	<xsl:call-template name="xmlLang"/>
                                    <xsl:value-of select="."/>
                                </Description>
                            </xsl:for-each>
                        </descriptions>
                    </xsl:if>
                </Actor_Language>
            </xsl:for-each>
        </Actor_Languages>
    </xsl:template>

    <xsl:template match="child::Resources" mode="regular">
        <Resources>
            <xsl:apply-templates select="MediaFile"/>
            <xsl:apply-templates select="WrittenResource"/>
            <xsl:apply-templates select="Source"/>
            <xsl:apply-templates select="Anonyms"/>
        </Resources>
    </xsl:template>

    <xsl:template match="MediaFile">
        <MediaFile>
        	<xsl:if test="exists(ResourceLink[normalize-space(.)!=''])">
        		<xsl:attribute name="ref" select="generate-id(ResourceLink)"/>
        	</xsl:if>
        	<Type>
        		<xsl:call-template name="orUnspecified">
        			<xsl:with-param name="value" select="Type"/>
        		</xsl:call-template>
            </Type>
            <Format>
                <xsl:value-of select=" ./Format"/>
            </Format>
            <Size>
                <xsl:value-of select=" ./Size"/>
            </Size>
            <Quality>
            	<xsl:call-template name="orUnspecified">
            		<xsl:with-param name="value" select="Quality"/>
            	</xsl:call-template>
            </Quality>
            <RecordingConditions>
                <xsl:value-of select=" ./RecordingConditions"/>
            </RecordingConditions>
            <TimePosition>
                <Start>
                	<xsl:call-template name="orUnspecified">
                		<xsl:with-param name="value" select="TimePosition/Start"/>
                	</xsl:call-template>
                </Start>
                <xsl:if test="exists(descendant::End)">
                    <End>
                    	<xsl:call-template name="orUnspecified">
                    		<xsl:with-param name="value" select="TimePosition/End"/>
                    	</xsl:call-template>
                    </End>
                </xsl:if>
            </TimePosition>
            <xsl:apply-templates select="Access"/>
            <xsl:if test="exists(child::Description[normalize-space(.)!=''])">
                <descriptions>
                	<xsl:for-each select="Description[normalize-space(.)!='']">
                        <Description>
                        	<xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="."/>
                        </Description>
                    </xsl:for-each>
                </descriptions>
            </xsl:if>
            <xsl:apply-templates select="child::Keys"/>
        </MediaFile>
    </xsl:template>

    <xsl:template match="Access">
    	<xsl:if test="normalize-space(.)">
    		<Access>
    			<Availability>
    				<xsl:value-of select=" ./Availability"/>
    			</Availability>
    			<Date>
    				<xsl:call-template name="orUnspecified">
    					<xsl:with-param name="value" select="Date"/>
    				</xsl:call-template>
    			</Date>
    			<Owner>
    				<xsl:value-of select=" ./Owner"/>
    			</Owner>
    			<Publisher>
    				<xsl:value-of select=" ./Publisher"/>
    			</Publisher>
    			<xsl:apply-templates select="Contact"/>
    			<xsl:if test="exists(child::Description[normalize-space(.)!=''])">
    				<descriptions>
    					<xsl:for-each select="Description[normalize-space(.)!='']">
    						<Description>
    							<xsl:call-template name="xmlLang"/>
    							<xsl:value-of select="."/>
    						</Description>
    					</xsl:for-each>
    				</descriptions>
    			</xsl:if>
    		</Access>
    	</xsl:if>
    </xsl:template>

    <xsl:template match="WrittenResource">
        <WrittenResource>
        	<xsl:if test="exists(ResourceLink[normalize-space(.)!=''])">
        		<xsl:attribute name="ref" select="generate-id(ResourceLink)"/>
        	</xsl:if>
        	<xsl:if test="exists(MediaResourceLink[normalize-space(.)!=''])">
        		<xsl:variable name="loc" select="MediaResourceLink"/>
        		<xsl:variable name="res" select="//ResourceLink[.=$loc]"/>
        		<xsl:if test="exists($res)">
        			<xsl:attribute name="mediaRef" select="generate-id($res)"/>
        		</xsl:if>
        	</xsl:if>
        	<Date>
        		<xsl:call-template name="orUnspecified">
        			<xsl:with-param name="value" select="Date"/>
        		</xsl:call-template>
        	</Date>
            <Type>
                <xsl:value-of select=" ./Type"/>
            </Type>
            <SubType>
                <xsl:value-of select=" ./SubType"/>
            </SubType>
            <Format>
                <xsl:value-of select=" ./Format"/>
            </Format>
            <Size>
                <xsl:value-of select=" ./Size"/>
            </Size>
            <Derivation>
            	<xsl:call-template name="orUnspecified">
            		<xsl:with-param name="value" select="Derivation"/>
            	</xsl:call-template>
            </Derivation>
            <CharacterEncoding>
                <xsl:value-of select=" ./CharacterEncoding"/>
            </CharacterEncoding>
            <ContentEncoding>
                <xsl:value-of select=" ./ContentEncoding"/>
            </ContentEncoding>
            <LanguageId>
            	<xsl:call-template name="orUnspecified">
            		<xsl:with-param name="value" select="LanguageId"/>
            	</xsl:call-template>
            </LanguageId>
            <Anonymized>
            	<xsl:call-template name="orUnspecified">
            		<xsl:with-param name="value" select="Anonymized"/>
            	</xsl:call-template>
            </Anonymized>
            <xsl:apply-templates select="Validation"/>
            <xsl:apply-templates select="Access"/>
        	<xsl:if test="exists(child::Description[normalize-space(.)!=''])">
                <descriptions>
                	<xsl:for-each select="Description[normalize-space(.)!='']">
                        <Description>
                        	<xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="."/>
                        </Description>
                    </xsl:for-each>
                </descriptions>
            </xsl:if>
            <xsl:apply-templates select="Keys"/>
        </WrittenResource>
    </xsl:template>

    <xsl:template match="Validation">
        <Validation>
            <Type>
            	<xsl:call-template name="orUnspecified">
            		<xsl:with-param name="value" select="Type"/>
            	</xsl:call-template>
            </Type>
            <Methodology>
            	<xsl:call-template name="orUnspecified">
            		<xsl:with-param name="value" select="Methodology"/>
            	</xsl:call-template>
            </Methodology>
            <Level>
                <xsl:value-of select=" ./Level"/>
            </Level>
        	<xsl:if test="exists(child::Description[normalize-space(.)!=''])">
                <descriptions>
                	<xsl:for-each select="Description[normalize-space(.)!='']">
                        <Description>
                        	<xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="."/>
                        </Description>
                    </xsl:for-each>
                </descriptions>
            </xsl:if>
        </Validation>
    </xsl:template>

    <xsl:template match="Source">
        <Source>
            <Id>
                <xsl:value-of select=" ./Id"/>
            </Id>
            <Format>
                <xsl:value-of select=" ./Format"/>
            </Format>
            <Quality>
            	<xsl:call-template name="orUnspecified">
            		<xsl:with-param name="value" select="Quality"/>
            	</xsl:call-template>
            </Quality>
            <xsl:if test="exists(child::CounterPosition)">
                <CounterPosition>
                    <Start>
                    	<xsl:call-template name="orUnspecified">
                    		<xsl:with-param name="value" select="CounterPosition/Start"/>
                    	</xsl:call-template>
                    </Start>
                    <xsl:if test="exists(descendant::End)">
                        <End>
                        	<xsl:call-template name="orUnspecified">
                        		<xsl:with-param name="value" select="CounterPosition/End"/>
                        	</xsl:call-template>
                        </End>
                    </xsl:if>
                </CounterPosition>
            </xsl:if>
            <xsl:if test="exists(child::TimePosition)">
                <TimePosition>
                    <Start>
                    	<xsl:call-template name="orUnspecified">
                    		<xsl:with-param name="value" select="TimePosition/Start"/>
                    	</xsl:call-template>
                    </Start>
                    <xsl:if test="exists(descendant::End)">
                        <End>
                        	<xsl:call-template name="orUnspecified">
                        		<xsl:with-param name="value" select="TimePosition/End"/>
                        	</xsl:call-template>
                        </End>
                    </xsl:if>
                </TimePosition>
            </xsl:if>
            <xsl:apply-templates select="Access"/>
        	<xsl:if test="exists(child::Description[normalize-space(.)!=''])">
                <descriptions>
                	<xsl:for-each select="Description[normalize-space(.)!='']">
                        <Description>
                        	<xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="."/>
                        </Description>
                    </xsl:for-each>
                </descriptions>
            </xsl:if>
            <xsl:apply-templates select="child::Keys"/>
        </Source>
    </xsl:template>

    <xsl:template match="Anonyms">
        <Anonyms>
        	<xsl:if test="exists(ResourceLink[normalize-space(.)!=''])">
        		<xsl:attribute name="ref" select="generate-id(ResourceLink)"/>
        	</xsl:if>
            <xsl:apply-templates select="Access"/>
        </Anonyms>
    </xsl:template>

    <xsl:template match="child::References">
        <References>
        	<xsl:if test="exists(child::Description[normalize-space(.)!=''])">
                <descriptions>
                	<xsl:for-each select="Description[normalize-space(.)!='']">
                        <Description>
                        	<xsl:call-template name="xmlLang"/>
                            <xsl:value-of select="."/>
                        </Description>
                    </xsl:for-each>
                </descriptions>
            </xsl:if>
        </References>
    </xsl:template>
	
	<xsl:function name="imdi:lang2iso">
		<xsl:param name="language"/>
		<xsl:variable name="codeset" select="replace(substring-before($language,':'),' ','')"/>
		<xsl:variable name="codestr" select="substring-after($language,':')"/>
		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="$codeset='ISO639-1'">
					<xsl:choose>
						<xsl:when test="$codestr='xxx'">
							<xsl:value-of select="'und'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="iso" select="key('iso639_1-lookup', $codestr, $iso-lang-top)/iso:i"/>
							<xsl:choose>
								<xsl:when test="$iso!='xxx'">
									<xsl:value-of select="$iso"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'und'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$codeset='ISO639-2'">
					<xsl:choose>
						<xsl:when test="$codestr='xxx'">
							<xsl:value-of select="'und'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="iso" select="key('iso639_2-lookup', $codestr, $iso-lang-top)/iso:i"/>
							<xsl:choose>
								<xsl:when test="$iso!='xxx'">
									<xsl:value-of select="$iso"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'und'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$codeset='ISO639-3'">
					<xsl:choose>
						<xsl:when test="$codestr='xxx'">
							<xsl:value-of select="'und'"/>
						</xsl:when>
						<xsl:when test="matches($codestr,'^[a-z]{3}$')">
							<xsl:value-of select="$codestr"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'und'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$codeset='ISO639'">
					<xsl:choose>
						<xsl:when test="$codestr='xxx'">
							<xsl:value-of select="'und'"/>
						</xsl:when>
						<xsl:when test="exists(key('iso639_2-lookup', $codestr, $iso-lang-top))">
							<xsl:variable name="iso" select="key('iso639_2-lookup', $codestr, $iso-lang-top)/iso:i"/>
							<xsl:choose>
								<xsl:when test="$iso!='xxx'">
									<xsl:value-of select="$iso"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'und'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="exists(key('iso639_1-lookup', $codestr, $iso-lang-top))">
							<xsl:variable name="iso" select="key('iso639_1-lookup', $codestr, $iso-lang-top)/iso:i"/>
							<xsl:choose>
								<xsl:when test="$iso!='xxx'">
									<xsl:value-of select="$iso"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'und'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="matches($codestr,'^[a-z]{3}$')">
							<xsl:value-of select="$codestr"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'und'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$codeset='RFC1766'">
					<xsl:choose>
						<xsl:when test="starts-with($codestr,'x-sil-')">
							<xsl:variable name="iso" select="key('sil-lookup', lower-case(replace($codestr, 'x-sil-', '')), $sil-lang-top)/sil:iso"/>
							<xsl:choose>
								<xsl:when test="$iso!='xxx'">
									<xsl:value-of select="$iso"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'und'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'und'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'und'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:sequence select="$code"/>
	</xsl:function>
	
	<xsl:template name="xmlLang">
		<xsl:if test="normalize-space(@LanguageId)!=''">
			<xsl:variable name="code" select="imdi:lang2iso(normalize-space(@LanguageId))"/>
			<xsl:if test="$code!='und'">
				<xsl:attribute name="xml:lang" select="$code"/>
			</xsl:if>
		</xsl:if>
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

    <xsl:template name="main">
        <xsl:for-each
            select="collection('file:///home/paucas/corpus_copy/corpus_copy/data/corpora?select=*.imdi;recurse=yes;on-error=ignore')">
            <xsl:result-document href="{document-uri(.)}.cmdi">
                <xsl:apply-templates select="."/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
