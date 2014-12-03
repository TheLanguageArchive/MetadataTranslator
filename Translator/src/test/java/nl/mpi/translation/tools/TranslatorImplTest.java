/*
 * Copyright (C) 2013 Max Planck Institute for Psycholinguistics
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
package nl.mpi.translation.tools;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLEncoder;
import org.custommonkey.xmlunit.XMLUnit;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import static org.custommonkey.xmlunit.XMLAssert.*;

/**
 *
 * @author Twan Goosen <twan.goosen@mpi.nl>
 */
public class TranslatorImplTest {

    private final static Logger logger = LoggerFactory.getLogger(TranslatorImplTest.class);
    // CMDI Sample locations
    public static final String CMDI_SAMPLES_LOCATION = "/nl/mpi/translation/tools/cmdi-sample";
    public static final String COLLECTION_CMDI = CMDI_SAMPLES_LOCATION + "/collection_sample.cmdi";
    public static final String COLLECTION_XML = CMDI_SAMPLES_LOCATION + "/collection_sample_cmdi.xml"; // Same contents as COLLECTION_CMDI
    public static final String COLLECTION_TO_CORPUS_IMDI = CMDI_SAMPLES_LOCATION + "/collection_sample_to_corpus.imdi";
    public static final String IPROSLA_CMDI = CMDI_SAMPLES_LOCATION + "/iprosla_sample.cmdi";
    public static final String IPROSLA_TO_SESSION_IMDI = CMDI_SAMPLES_LOCATION + "/iprosla_sample_to_session.imdi";
    public static final String IPROSLA_NO_SELFLINK_CMDI = CMDI_SAMPLES_LOCATION + "/iprosla_sample_no_selflink.cmdi";
    public static final String IPROSLA_NO_SELFLINK_TO_SESSION_IMDI = CMDI_SAMPLES_LOCATION + "/iprosla_sample_no_selflink_to_session.imdi";
    public static final String OTHER_CMDI = CMDI_SAMPLES_LOCATION + "/other_sample.cmdi";
    public static final String DISCAN_CASE_CMDI = CMDI_SAMPLES_LOCATION + "/discan_case_sample.cmdi";
    public static final String DISCAN_CASE__TO_SESSION_IMDI = CMDI_SAMPLES_LOCATION + "/discan_case_sample_to_session.imdi";
    public static final String SOUNDBITES_CMDI = CMDI_SAMPLES_LOCATION + "/soundbites_sample.cmdi";
    public static final String SOUNDBITES_TO_SESSION_IMDI = CMDI_SAMPLES_LOCATION + "/soundbites_sample_to_session.imdi";
    public static final String LAT_SESSION = CMDI_SAMPLES_LOCATION + "/imdi_session_sample.cmdi";
    public static final String LAT_SESSION_TO_IMDI = CMDI_SAMPLES_LOCATION + "/imdi_session_sample.imdi";
    // IMDI Sample locations
    public static final String IMDI_SAMPLES_LOCATION = "/nl/mpi/translation/tools/imdi-sample";
    public static final String IMDI_SAMPLE = IMDI_SAMPLES_LOCATION + "/kleve_route.imdi";
    public static final String IMDI_SAMPLE_XML = IMDI_SAMPLES_LOCATION + "/kleve_route_imdi.xml"; // Same contents as IMDI_SAMPLE
    public static final String IMDI_TO_CMDI = IMDI_SAMPLES_LOCATION + "/kleve_route.cmdi";
    // URIs used in sample expectations
    public static final String SERVICE_URI = "http://my-service/translate";
    public static final String COLLECTION_BASE_URI = "http://my-collection";
    public static final String ORIGINAL_LOCATION_PLACEHOLDER = "{ORIGINAL_LOCATION}";
    /**
     * Instance to test on (new instance gets created for each test in {@link #setUp() })
     */
    private TranslatorImpl instance;

    @BeforeClass
    public static void setUpClass() {
	XMLUnit.setIgnoreWhitespace(true);
    }

    @Before
    public void setUp() throws Exception {
	instance = new TranslatorImpl();
    }

    /**
     * Requests translation of a collection (profile clarin.eu:cr1:p_1345561703620) instance
     */
    @Test
    public void testGetIMDIForCollection() throws Exception {
	logger.info("Testing translation of collection file to IMDI");
	testGetIMDI(COLLECTION_CMDI, COLLECTION_TO_CORPUS_IMDI);
    }

    /**
     * Requests translation of a CMDI instance that has .xml suffix
     */
    @Test
    public void testGetIMDIForCollectionAsXML() throws Exception {
	logger.info("Testing translation of .xml CMDI file to IMDI");
	testGetIMDI(COLLECTION_XML, COLLECTION_TO_CORPUS_IMDI);
    }

    /**
     * Requests translation of an DiscAn instance
     */
    @Test
    public void testGetIMDIForDiscAn() throws Exception {
	logger.info("Testing translation of DiscAn case instance to IMDI");
	testGetIMDI(DISCAN_CASE_CMDI, DISCAN_CASE__TO_SESSION_IMDI);
    }
    
    /**
     * Requests translation of an DiscAn instance
     */
    @Test
    public void testGetIMDIForSoundBites() throws Exception {
	logger.info("Testing translation of DiscAn case instance to IMDI");
	testGetIMDI(SOUNDBITES_CMDI, SOUNDBITES_TO_SESSION_IMDI);
    }    

    /**
     * Requests translation of an IPROSLA (profile clarin.eu:cr1:p_1331113992512) instance with a self link.
     * Self link should be used as reference to original document.
     */
    @Test
    public void testGetIMDIForIPROSLA() throws Exception {
	logger.info("Testing translation of IPROSLA instance to IMDI");
	testGetIMDI(IPROSLA_CMDI, IPROSLA_TO_SESSION_IMDI);
    }

    /**
     * Requests translation of an IPROSLA (profile clarin.eu:cr1:p_1331113992512) instance without a self link.
     * Source location should be used as reference to original document instead and IMDI archive handle should be empty
     */
    @Test
    public void testGetIMDIForIPROSLANoSelflink() throws Exception {
	logger.info("Testing translation of IPROSLA instance to IMDI");
	testGetIMDI(IPROSLA_NO_SELFLINK_CMDI, IPROSLA_NO_SELFLINK_TO_SESSION_IMDI);
    }

    /**
     * Requests translation of a CMDI of an unsupported profile, should do identity transform so output should be equivalent to input
     */
    @Test
    public void testGetIMDIForOther() throws Exception {
	URL cmdiFileURL = getClass().getResource(OTHER_CMDI);
	logger.info("Testing translation of instance of unsupported profile to IMDI");
	logger.debug(cmdiFileURL.toString());
	// Request translation
	String result = instance.getIMDI(cmdiFileURL, SERVICE_URI);
	// Expecting output to be identical to input
	assertTranslationResult(OTHER_CMDI, result);
    }

    /**
     * Requests translation of a CMDI of an unsupported profile, should do identity transform so output should be equivalent to input
     */
    @Test
    public void testGetIMDIFromIMDI() throws Exception {
	URL inputFileURL = getClass().getResource(IMDI_SAMPLE);
	logger.info("Testing translation of IMDI to IMDI");
	logger.debug(inputFileURL.toString());
	// Request translation
	String result = instance.getIMDI(inputFileURL, SERVICE_URI);
	// Expecting output to be identical to input
	assertTranslationResult(IMDI_SAMPLE, result);
    }

    /**
     * Requests translation of an IMDI session, output should be CMDI instance of 'imdi-session' (profile clarin.eu:cr1:p_1271859438204)
     */
    @Test
    public void testGetCMDIForSession() throws Exception {
	URL imdiFileURL = getClass().getResource(IMDI_SAMPLE);
	logger.info("Testing translation of IMDI file to CMDI");
	logger.debug(imdiFileURL.toString());
	// Request translation
	String result = instance.getCMDI(imdiFileURL, SERVICE_URI);
	// Expecting output to be identical to input
	assertTranslationResult(IMDI_TO_CMDI, normalizeDate(normalizeIds(result)));
    }

    /**
     * Requests translation of an IMDI session that has .xml suffix
     */
    @Test
    public void testGetCMDIForSessionAsXML() throws Exception {
	URL imdiFileURL = getClass().getResource(IMDI_SAMPLE_XML);
	logger.info("Testing translation of IMDI .xml file to CMDI");
	logger.debug(imdiFileURL.toString());
	// Request translation
	String result = instance.getCMDI(imdiFileURL, SERVICE_URI);
	// Expecting output to be identical to input
	assertTranslationResult(IMDI_TO_CMDI, normalizeDate(normalizeIds(result)));
    }

    /**
     * Requests translation of a CMDI of an unsupported profile, should do identity transform so output should be equivalent to input
     */
    @Test
    public void testGetCMDIFromCMDI() throws Exception {
	URL inputFileURL = getClass().getResource(COLLECTION_CMDI);
	logger.info("Testing translation of IMDI to IMDI");
	logger.debug(inputFileURL.toString());
	// Request translation
	String result = instance.getCMDI(inputFileURL, SERVICE_URI);
	// Expecting output to be identical to input
	assertTranslationResult(COLLECTION_CMDI, result);
    }

    /**
     * Requests translation from IMDI to CMDI
     *
     * @param cmdiResource resource location of cmdi to translate
     * @param targetImdiResource resource location of normalized target result
     */
    private void testGetIMDI(String cmdiResource, String targetImdiResource) throws Exception {
	final URL cmdiFileURL = getClass().getResource(cmdiResource);
	logger.debug(cmdiFileURL.toString());
	// Request translation
	final String result = instance.getIMDI(cmdiFileURL, SERVICE_URI);
	// Compare to expectation (loaded from resource)
	assertTranslationResult(targetImdiResource, normalizeImdiOutput(result, cmdiFileURL));
    }

    /**
     * Asserts that the content of result is XML-equal to the content of the resource at the specified location
     *
     * @param expectedResourceName location of the resource that holds the expected result
     * @param result string representation of the actual result of the translation to validate
     * @see #assertXMLEqual(java.io.Reader, java.io.Reader)
     * @throws IOException
     * @throws SAXException
     */
    private static void assertTranslationResult(String expectedResourceName, String result) throws IOException, SAXException {
	final InputStream expectedInputStream = TranslatorImplTest.class.getResourceAsStream(expectedResourceName);
	final Reader expectedResultReader = new InputStreamReader(expectedInputStream, "UTF-8");
	try {
	    assertXMLEqual(expectedResultReader, new StringReader(result));
	} finally {
	    expectedResultReader.close();
	}
    }

    /**
     * Wrapper for {@link #normalizeSourceLocation(java.lang.String) } and {@link #normalizeOriginator(java.lang.String, java.lang.String) }
     *
     * @param xml xml to normalize
     * @param cmdiFileUrl url of transformed CMDI
     * @return normalized xml
     * @throws UnsupportedEncodingException
     */
    private String normalizeImdiOutput(String xml, URL cmdiFileUrl) throws UnsupportedEncodingException {
	return normalizeSourceLocation(normalizeOriginator(xml, cmdiFileUrl.toString()));
    }

    /**
     * Replaces the resource locations with a generic placeholder (http://my-collection) used in the examples
     *
     * @param xml xml to normalize
     * @return normalized xml
     * @throws UnsupportedEncodingException
     */
    private String normalizeSourceLocation(String xml) throws UnsupportedEncodingException {
	return xml.replace(
		URLEncoder.encode(getClass().getResource(CMDI_SAMPLES_LOCATION).toString(), "UTF-8"),
		URLEncoder.encode(COLLECTION_BASE_URI, "UTF-8"));
    }

    /**
     * Replaces the original location with a generic placeholder
     *
     * @param xml xml to normalize
     * @param originalLocation original location of the transformed file
     * @return normalized XML
     */
    private String normalizeOriginator(String xml, String originalLocation) {
	return xml.replace(originalLocation, ORIGINAL_LOCATION_PLACEHOLDER);
    }

    /**
     * Replaces all values of 'id' and 'ref' attributes by 'xx', as should also be the case in the expected XML. This is needed
     * because id's may be generated in a non-deterministic manner.
     *
     * @param xml xml to normalize
     * @return normalized xml
     */
    private String normalizeIds(String xml) {
	return xml
                .replaceAll("id=\"(.*)\"", "id=\"xx\"")
                .replaceAll("ref=\"(.*)\"", "ref=\"xx\"");
    }

    /**
     * Replaces the value of MdCreationDate by 'xx', as should also be the case in the expected XML. This is needed
     * because the current date gets inserted.
     *
     * @param xml xml to normalize
     * @return normalized xml
     */
    private String normalizeDate(String xml) {
	return xml
                .replaceAll("<MdCreationDate>.*</MdCreationDate>", "<MdCreationDate>xx</MdCreationDate>")
                .replaceAll("DATE:\\S+\\.", "DATE:xx.");
    }
}
