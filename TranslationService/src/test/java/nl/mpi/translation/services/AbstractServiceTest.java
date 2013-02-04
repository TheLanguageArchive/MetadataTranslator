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

import com.sun.jersey.test.framework.AppDescriptor;
import com.sun.jersey.test.framework.JerseyTest;
import com.sun.jersey.test.framework.spi.container.TestContainerException;
import nl.mpi.translation.tools.Translator;
import org.jmock.Mockery;
import org.junit.Before;
import org.springframework.web.context.ContextLoaderListener;
import org.springframework.web.context.WebApplicationContext;

/**
 * Abstract test class for the translator REST service.
 *
 * <p>This class works as follows:
 * <ol>In the constructor a web application descriptor is created that uses an alternative Spring application context specified in an XML
 * file in the test resources</ol>
 * <ol>This application context has beans that are JMock objects implementing the Translator and HandleResolver interfaces, which get
 * injected into the {@link Service}</ol>
 * <ol>The method {@link #obtainBeansFromWebAppContext() } gets the mockery context and mock objects from the web application context
 * instantiated in the test (Grizzly) servlet container</ol>
 * <ol>In the test methods expectations can be specified on the mock objects, then calls on the service can be made through the {@link #resource()
 * } object</ol>
 * </p>
 *
 * @author Twan Goosen <twan.goosen@mpi.nl>
 */
public abstract class AbstractServiceTest extends JerseyTest {

    private Mockery mockery;
    private Translator translator;
    private HandleResolver handleResolver;

    public AbstractServiceTest(AppDescriptor ad) throws TestContainerException {
	super(ad);
    }

    /**
     * Gets beans needed for mocking from application context
     */
    @Before
    public void obtainBeansFromWebAppContext() {
	// Get the web application context that has been instantiated in the Grizzly container
	final WebApplicationContext webAppContext = ContextLoaderListener.getCurrentWebApplicationContext();

	// Get the context and mock objects from the context by their type
	mockery = webAppContext.getBean(Mockery.class);
	translator = webAppContext.getBean(Translator.class);
	handleResolver = webAppContext.getBean(HandleResolver.class);
    }

    /**
     * @return the mockery
     */
    protected Mockery getMockery() {
	return mockery;
    }

    /**
     * @return the translator
     */
    protected Translator getTranslator() {
	return translator;
    }

    /**
     * @return the handleResolver
     */
    protected HandleResolver getHandleResolver() {
	return handleResolver;
    }
}
