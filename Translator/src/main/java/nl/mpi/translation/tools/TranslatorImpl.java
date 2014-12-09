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

import com.google.common.base.Strings;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.regex.Pattern;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.stax.StAXSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import nl.mpi.translation.tools.util.TranslationServiceErrorListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Implemenation of Rest translation library to convert CMDI into IMDI and
 * vice-versa.
 * <br/><br/>
 * This class uses STAx for parsing the input document and Saxon as XSLT
 * processor. The transformer for the underlying XSLT stylesheet is cached in a
 * Template object.<br/>
 * Saxon is used to provide an XSLT 2.0 implementation.
 *
 * @author andmor <andre.moreira@mpi.nl>
 * @author Twan Goosen <twan.goosen@mpi.nl>
 *
 */
public class TranslatorImpl implements Translator {

    private final static Logger logger = LoggerFactory.getLogger(TranslatorImpl.class);
    private final static String SAXON_TRANSFORMER_IMPL_CLASS_NAME = "net.sf.saxon.TransformerFactoryImpl";

    private final static URL DEFAULT_CMDI2IMDI_XSLT = TranslatorImpl.class.getClassLoader().getResource("templates/cmdi2imdi/cmdi2imdiMaster.xslt");
    private final static URL DEFAULT_IMDI2CMDI_XSLT = TranslatorImpl.class.getClassLoader().getResource("templates/imdi2cmdi/imdi2cmdi.xslt");

    private final static Pattern CMDI_URL_PATTERN = Pattern.compile("^.*\\.cmdi(\\?.*)?$", Pattern.CASE_INSENSITIVE);
    private final static Pattern IMDI_URL_PATTERN = Pattern.compile("^.*\\.imdi(\\?.*)?$", Pattern.CASE_INSENSITIVE);

    private final TransformerFactory transfFactory;
    private final XMLInputFactory xmlInputFactory;
    private final Templates cmdi2imdiCachedXSLT;
    private final Templates imdi2cmdiCachedXSLT;

    public TranslatorImpl() throws TransformerConfigurationException, IOException {
        this(DEFAULT_IMDI2CMDI_XSLT, DEFAULT_CMDI2IMDI_XSLT);
    }

    /**
     *
     * @param imdi2cmdiXsltPath path to local file location of the IMDI to CMDI
     * transformation stylesheet (null to use default)
     * @param cmdi2imdiXsltPath path to local file location of the CMDI to IMDI
     * transformation stylesheet (null to use default)
     * @throws MalformedURLException
     * @throws TransformerConfigurationException
     * @throws IOException
     */
    public TranslatorImpl(String imdi2cmdiXsltPath, String cmdi2imdiXsltPath) throws MalformedURLException, TransformerConfigurationException, IOException {
        this(
                (Strings.isNullOrEmpty(imdi2cmdiXsltPath) ? DEFAULT_IMDI2CMDI_XSLT : new File(imdi2cmdiXsltPath).toURI().toURL()),
                (Strings.isNullOrEmpty(cmdi2imdiXsltPath) ? DEFAULT_CMDI2IMDI_XSLT : new File(cmdi2imdiXsltPath).toURI().toURL()));
    }

    /**
     * Initializes the translator with the specified stylesheets
     *
     * @param imdi2CmdiXsltLocation location of the IMDI to CMDI transformation
     * stylesheet (cannot be null)
     * @param cmdi2ImdiXsltLocation location of the CMDI to IMDI transformation
     * stylesheet (cannot be null)
     * @throws TransformerConfigurationException
     * @throws IOException
     */
    public TranslatorImpl(final URL imdi2CmdiXsltLocation, final URL cmdi2ImdiXsltLocation) throws TransformerConfigurationException, IOException {
        transfFactory = createTransformerFactory();
        transfFactory.setErrorListener(new TranslationServiceErrorListener(logger));
        logger.debug("Instantiated XML transformer factory of type {}", transfFactory.getClass());

        xmlInputFactory = XMLInputFactory.newInstance();
        logger.debug("Instantiated XML input factory of type {}", xmlInputFactory.getClass());

        cmdi2imdiCachedXSLT = initTemplates(cmdi2ImdiXsltLocation);
        imdi2cmdiCachedXSLT = initTemplates(imdi2CmdiXsltLocation);

        logger.info("Translator initialized");
        logger.debug("Using XSLT Transformer: '{}'", cmdi2imdiCachedXSLT.getClass());
        logger.info("Using CMDI2IMDI stylesheet: '{}'", cmdi2ImdiXsltLocation);
        logger.info("Using IMDI2CMDI stylesheet: '{}'", imdi2CmdiXsltLocation);
    }

    private Templates initTemplates(URL xsltURL) throws FileNotFoundException, TransformerConfigurationException, IOException {
        if (xsltURL == null) {
            throw new FileNotFoundException("CMDI2IMDI stylesheet: '" + xsltURL
                    + "' (no such file or directory)");
        }
        //Create a source with the stylesheet
        final Source sourceXSLT = new StreamSource(xsltURL.openStream(), xsltURL.toExternalForm());
        //Create a cached transformer
        return transfFactory.newTemplates(sourceXSLT);
    }

    /**
     * Creates a new transformer factory, using Saxon as the preferred
     * implementation. Falls back to the default procedure through
     * {@link TransformerFactory#newInstance()}.
     *
     * @return an implementation instance of TransformerFactory, never null
     * @throws TransformerFactoryConfigurationError as thrown by {@link TransformerFactory#newInstance()
     * } in case the Saxon implementation cannot be instantiated
     */
    private TransformerFactory createTransformerFactory() throws TransformerFactoryConfigurationError {
        try {
            // Try Saxon first:
            logger.debug("Trying to get instance of '{}' transformer implementation", SAXON_TRANSFORMER_IMPL_CLASS_NAME);
            return TransformerFactory.newInstance(SAXON_TRANSFORMER_IMPL_CLASS_NAME, null);
        } catch (TransformerFactoryConfigurationError tfc) {
            // Backup plan: use whatever is available to Java through the default procedure 
            logger.warn("Could not load class for Saxon transformer, trying default as backup. This will probably lead to runtime errors!");
            logger.debug("javax.xml.transform.TransformerFactory={}", System.getProperty("javax.xml.transform.TransformerFactory"));
            logger.debug("Exception thrown by TransformerFactory.newInstance()", tfc);
            return TransformerFactory.newInstance();
        }
    }

    /**
     * This method reads an CMDI XML document form the supplied URL and returns
     * it converted to IMDI. If the input document specified by
     * <b>cmdiFileURL</b> has <i>.imdi</i> extension, the original file is
     * returned.
     *
     * @param cmdiFileURL - The URL pointing to the CMDI file to convert.
     * @param serviceURI
     * @return IMDI file converted from CMDI.
     * @throws TransformerException
     * @throws XMLStreamException
     * @throws IOException
     */
    @Override
    public String getIMDI(URL cmdiFileURL, String serviceURI) throws TransformerException, XMLStreamException, IOException {

        //set up input
        final InputStream input = cmdiFileURL.openStream();
        try {
            final XMLStreamReader xmlStreamReader = xmlInputFactory.createXMLStreamReader(input, "UTF-8");
            try {
                final Source source = new StAXSource(xmlStreamReader);

                //set up output
                final StringWriter sw = new StringWriter();
                final Result result = new StreamResult(sw);
                final String inputUrl = cmdiFileURL.toString();

                //return the original document for documents already with imdi extension. 
                if (isImdiURl(inputUrl)) {
                    logger.warn("Input document seems to be already IMDI! Returning original document.");
                    writeURLContentsToStream(cmdiFileURL, sw);
                } else {
                    if (!isCmdiUrl(inputUrl)) {
                        logger.info("Input document language could not be confirmed! CMDI assumed.");
                    }
                    //translate document
                    final Transformer transformer = cmdi2imdiCachedXSLT.newTransformer();
                    transformer.setParameter("service-base-uri", serviceURI);
                    transformer.setParameter("source-location", inputUrl);
                    transformer.transform(source, result);
                }

                sw.flush();
                return sw.toString();
            } finally {
                xmlStreamReader.close();
            }
        } finally {
            input.close();
        }
    }

    /**
     * This method reads an IMDI XML document form the supplied URL and returns
     * it converted to CMDI. If the input document specified by
     * <b>imdiFileURL</b> has <i>.cmdi</i> extension, the original file is
     * returned.
     *
     * @param imdiFileURL - The URL pointing to the IMDI file to convert.
     * @param serviceURI
     * @return CMDI file converted from IMDI.
     * @throws TransformerException
     * @throws XMLStreamException
     * @throws IOException
     */
    @Override
    public String getCMDI(URL imdiFileURL, String serviceURI) throws TransformerException, XMLStreamException, IOException {

        //set up input
        final InputStream input = imdiFileURL.openStream();
        try {
            XMLStreamReader xmlStreamReader = xmlInputFactory.createXMLStreamReader(input, "UTF-8");
            try {
                final Source source = new StAXSource(xmlStreamReader);

                //set up output
                final StringWriter sw = new StringWriter();
                final Result result = new StreamResult(sw);
                final String inputUrl = imdiFileURL.toString();

                //return the original document for documents already with cmdi extension. 
                if (isCmdiUrl(inputUrl)) {
                    logger.warn("Input document seems to be already CMDI! Returning original document.");
                    writeURLContentsToStream(imdiFileURL, sw);
                } else {
                    if (!isImdiURl(inputUrl)) {
                        logger.info("Input document language could not be confirmed! IMDI assumed.");
                    }
                    //translate document
                    Transformer transformer = imdi2cmdiCachedXSLT.newTransformer();
                    transformer.setParameter("service-base-uri", serviceURI);
                    transformer.setParameter("source-location", inputUrl);
                    transformer.transform(source, result);
                }

                sw.flush();
                return sw.toString();
            } finally {
                xmlStreamReader.close();
            }
        } finally {
            input.close();
        }
    }

    private void writeURLContentsToStream(URL cmdiFileURL, StringWriter sw) throws IOException {
        final InputStream urlInputStream = cmdiFileURL.openConnection().getInputStream();
        try {
            final BufferedReader rd = new BufferedReader(new InputStreamReader(urlInputStream, "UTF-8"));
            try {
                String line;
                while ((line = rd.readLine()) != null) {
                    sw.write(line);
                }
            } finally {
                rd.close();
            }
        } finally {
            urlInputStream.close();
        }
    }

    private static boolean isCmdiUrl(String cmdiFileURL) {
        return CMDI_URL_PATTERN.matcher(cmdiFileURL).matches();
    }

    private static boolean isImdiURl(String imdiFileURL) {
        return IMDI_URL_PATTERN.matcher(imdiFileURL).matches();
    }
}
