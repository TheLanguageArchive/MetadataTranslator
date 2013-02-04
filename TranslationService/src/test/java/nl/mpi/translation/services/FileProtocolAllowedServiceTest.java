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
 * Extension of the AbstractServiceTest that tests the service with the file protocol ENABLED.
 *
 * @see AbstractServiceTest for a description how the mock services get injected and are used here
 * @author Twan Goosen <twan.goosen@mpi.nl>
 */
public class FileProtocolAllowedServiceTest extends AbstractServiceTest {

    public FileProtocolAllowedServiceTest() {
	// Build app descriptor allowing file protocol
	super(new WebAppDescriptor.Builder(Service.class.getPackage().getName())
		.servletClass(SpringServlet.class)
		.contextParam("contextConfigLocation", "classpath:testApplicationContext.xml")
		.contextListenerClass(ContextLoaderListener.class)
		.contextParam("allowFileProtocol", "true")
		.build());
    }

    @Test
    public void testFileLinkAllowed() throws Exception {
	//Set up alternative fixture that has allow file protocol context parameter true
	final WebResource resource = resource().path("/translate");
	getMockery().checking(new Expectations() {
	    {
		oneOf(getTranslator()).getIMDI(new URL("file:///local/file"), resource.getURI().toString());
		will(returnValue("Resulting IMDI"));
	    }
	});
	// By default file protocol is not allowed
	String response = resource
		.queryParam("in", URLEncoder.encode("file:///local/file", "UTF-8"))
		.queryParam("outFormat", "imdi")
		.get(String.class);
	assertEquals("Resulting IMDI", response);
    }
}
