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
package nl.mpi.translation.services;

import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.spi.spring.container.servlet.SpringServlet;
import com.sun.jersey.test.framework.WebAppDescriptor;
import java.net.URL;
import java.net.URLEncoder;
import org.jmock.Expectations;
import org.junit.Test;
import org.springframework.web.context.ContextLoaderListener;

import static org.junit.Assert.*;

/**
 * Extension of the AbstractServiceTest that tests the service with the file protocol DISABLED (default).
 *
 * @see AbstractServiceTest for a description how the mock services get injected and are used here
 * @author Twan Goosen <twan.goosen@mpi.nl>
 */
public class ServiceTest extends AbstractServiceTest {

    public ServiceTest() {
	// Build app descriptor without context parameters
	super(new WebAppDescriptor.Builder(Service.class.getPackage().getName())
	    .servletClass(SpringServlet.class)
	    .contextParam("contextConfigLocation", "classpath:testApplicationContext.xml")
	    .contextListenerClass(ContextLoaderListener.class).build());
    }
    
    /**
     * Test of translate method, of class Service.
     */
    @Test
    public void testTranslateNoInput() throws Exception {
	ClientResponse response = resource().path("/translate").get(ClientResponse.class);
	assertEquals(400, response.getStatus());
    }

    /**
     * No output format specified, should result in transform to IMDI
     */
    @Test
    public void testTranslateCMDItoIMDI() throws Exception {
	final WebResource resource = resource().path("/translate");
	getMockery().checking(new Expectations() {
	    {
		oneOf(getTranslator()).getIMDI(new URL("http://myURL/test.cmdi"), resource.getURI().toString());
		will(returnValue("Resulting IMDI"));
	    }
	});
	String response = resource
		.queryParam("in", URLEncoder.encode("http://myURL/test.cmdi", "UTF-8"))
		.queryParam("outFormat", "imdi")
		.get(String.class);
	assertEquals("Resulting IMDI", response);
    }

    /**
     * No output format specified, should result in transform to IMDI
     */
    @Test
    public void testTranslateIMDItoCMDI() throws Exception {
	final WebResource resource = resource().path("/translate");
	getMockery().checking(new Expectations() {
	    {
		oneOf(getTranslator()).getCMDI(new URL("http://myURL/test.imdi"), resource.getURI().toString());
		will(returnValue("Resulting CMDI"));
	    }
	});
	String response = resource
		.queryParam("in", URLEncoder.encode("http://myURL/test.imdi", "UTF-8"))
		.queryParam("outFormat", "cmdi")
		.get(String.class);
	assertEquals("Resulting CMDI", response);
    }

    /**
     * No output format specified, should result in transform to IMDI
     */
    @Test
    public void testTranslateNoOutputFormat() throws Exception {
	final WebResource resource = resource().path("/translate");
	getMockery().checking(new Expectations() {
	    {
		oneOf(getTranslator()).getIMDI(new URL("http://myURL"), resource.getURI().toString());
		will(returnValue("Resulting IMDI"));
	    }
	});
	String response = resource
		.queryParam("in", URLEncoder.encode("http://myUrl", "UTF-8"))
		.get(String.class);
	assertEquals("Resulting IMDI", response);
    }

    /**
     * No output format specified, should result in transform to IMDI
     */
    @Test
    public void testTranslateHandle() throws Exception {

	final String handle = "1234/00-0000-0000-0000-0000-0";
	final String handleResolvedUri = "http://my-resolved-uri";

	final WebResource resource = resource().path("/translate");
	getMockery().checking(new Expectations() {
	    {
		// Resolver will get handle
		oneOf(getHandleResolver()).resolveHandle(new URL("http://hdl.handle.net/" + handle));
		// and returns resolved URI
		will(returnValue(new URL(handleResolvedUri)));

		// Translator should retrieve resolved URI
		oneOf(getTranslator()).getIMDI(new URL(handleResolvedUri), resource.getURI().toString());
		will(returnValue("Resulting IMDI"));
	    }
	});
	String response = resource
		.queryParam("in", URLEncoder.encode(handle, "UTF-8"))
		.queryParam("outFormat", "imdi")
		.get(String.class);
	assertEquals("Resulting IMDI", response);
    }

    @Test
    public void testFileLinkDisallowed() throws Exception {
	// By default file protocol is not allowed
	ClientResponse response = resource().path("/translate")
		.queryParam("in", URLEncoder.encode("file:///local/file", "UTF-8"))
		.get(ClientResponse.class);
	assertEquals(403, response.getStatus());
    }
}
