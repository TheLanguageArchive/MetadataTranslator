package nl.mpi.translation.services;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.ServletContext;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.CacheControl;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriInfo;
import javax.ws.rs.core.Response.Status;
import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerException;

import javax.ws.rs.WebApplicationException;

import nl.mpi.translation.tools.Translator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * JAX-RS translation service for CMDI <-> IMDI conversion.
 * <br/><br/>
 * This class is a singleton so it instantiates one CMDI <-> IMDI
 * TranslatorImpl upon servlet startup.
 *
 * @author andmor
 *
 */
@Component
@Path("/translate")
public class Service {
    
    private final static Logger logger = LoggerFactory.getLogger(Service.class);
    @Context
    private UriInfo uriInfo;
    @Context
    private ServletContext servletContext;
    @Autowired // Gets injected by spring, see applicationContext.xml
    private Translator translator;
    @Autowired
    private HandleResolver handleResolver;

    /**
     * Handles the 'translate' (GET) requests.
     *
     * @param location - The location of the document to translate. Can be and handle
     * or a full featured URL string.
     * @param outFormat - The desired output format for the supplied document: <i>IMDI</i>
     * or <i>CMDI</i>.
     * @return The translated document in the requested format.
     */
    @GET
    @Produces(MediaType.TEXT_XML + " ;charset=UTF-8")
    public Response translate(@QueryParam("in") String location, @QueryParam("outFormat") String outFormat) {
	String output;
	
	if (location == null || location.equals("")) {
	    logger.warn("Invalid request: '{}'", uriInfo.getRequestUri());
	    return Response.status(Status.BAD_REQUEST).build();
	}
	
	try {
	    final long initTime = System.currentTimeMillis();

	    //get location of file to translate
	    URL inputFileURL = this.resolveLocation(location);
	    location = inputFileURL.toString();

	    //translate file based on specified output format/language
	    if (translator == null) {
		logger.error("Could not process request: Translator instance is null");
		return Response.serverError().build();
	    }
	    
	    if (outFormat != null && (outFormat.toLowerCase().equals("imdi"))) {
		logger.info("Requested IMDI translation for file: '{}'", location);
		output = translator.getIMDI(inputFileURL, uriInfo.getAbsolutePath().toString());
		logger.info("IMDI file returned in: {} ms", (System.currentTimeMillis() - initTime));
	    } else if (outFormat != null && (outFormat.toLowerCase().equals("cmdi"))) {
		logger.info("Requested CMDI translation for file: '{}'", location);
		output = translator.getCMDI(inputFileURL, uriInfo.getAbsolutePath().toString());
		logger.info("CMDI file returned in: {} ms", (System.currentTimeMillis() - initTime));
	    } else {
		//default is CMDI to IMDI
		logger.warn("Unknown output format requested: '{}'. IMDI assumed.\nGenerating IMDI translation for file: '{}'", outFormat, location);
		output = translator.getIMDI(inputFileURL, uriInfo.getAbsolutePath().toString());
		logger.info("IMDI file returned in: {} ms", (System.currentTimeMillis() - initTime));
	    }
	    
	} catch (TransformerException e) {
	    logger.error("Error running transformation: ", e);
	    return Response.serverError().build();
	} catch (XMLStreamException e) {
	    logger.error("Error running transformation: ", e);
	    return Response.serverError().build();
	} catch (IOException e) {
	    logger.error("Error reading input file: ", e);
	    return Response.status(Status.NOT_FOUND).build();
	}
	
	Response.ResponseBuilder response = Response.ok(output);

	// Expires 30 seconds from now.
	//TODO: tune or remove!
	CacheControl cc = new CacheControl();
	cc.setMaxAge(30);
	cc.setNoCache(false);
	response.cacheControl(cc);
	
	return response.build();
	
    }

    /**
     * Determines the final URL pointing to the document specified by <b>locationStr</b>.
     * <br/>This method assumes that <b>locationStr</b>'s starting by a valid protocol
     * other than: 'http://hdl.handle.net/' are already final URL strings. All other
     * forms of <b>locationStr</b>'s are resolved as handles.
     *
     * @param locationStr - The location of the document to translate. Can be and handle
     * or a full featured URL string.
     * @return The resolved URL pointing to the document to translate.
     * @throws IOException
     */
    private URL resolveLocation(String locationStr) throws IOException {
	
	if (!fileProtocolAllowed() && locationStr.startsWith("file://")) {
	    throw new WebApplicationException(Response.Status.FORBIDDEN);
	}

	//assume that location strings that do not start by a valid protocol
	//are a handle codes.
	if (!(locationStr.startsWith("http://")
		|| locationStr.startsWith("https://")
		|| locationStr.startsWith("file://")
		|| locationStr.startsWith("ftp://")
		|| locationStr.startsWith("jar://"))) {
	    locationStr = "http://hdl.handle.net/" + locationStr;
	}
	
	URL inputFileURL;
	try {
	    inputFileURL = new URL(locationStr);
	} catch (MalformedURLException e) {
	    logger.error("Could generate proper URL for input document!");
	    throw e;
	}

	//if locationStr is an handle, resolve it				
	if (locationStr.startsWith("http://hdl.handle.net/")) {
	    return handleResolver.resolveHandle(inputFileURL);
	} else {
	    return inputFileURL;
	}
    }
    
    private boolean fileProtocolAllowed() {
	final String paramValue = servletContext.getInitParameter("allowFileProtocol");
	return paramValue != null && Boolean.valueOf(paramValue);
    }
}
