/*
 * Copyright (C) 2015 Max Planck Institute for Psycholinguistics
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

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import static org.hamcrest.Matchers.instanceOf;
import org.jmock.Expectations;
import static org.jmock.Expectations.any;
import static org.jmock.Expectations.returnValue;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;
import org.junit.AssumptionViolatedException;
import org.junit.Rule;
import org.junit.rules.TemporaryFolder;

/**
 *
 * @author Twan Goosen <twan.goosen@mpi.nl>
 */
public class LocalFileAwareUrlStreamResolverTest {

    private final static String BASE_URL = "http://my/server/files";

    @Rule
    public TemporaryFolder folder = new TemporaryFolder();

    private final Mockery context = new JUnit4Mockery();
    private UrlStreamResolver baseResolver;
    private LocalFileAwareUrlStreamResolver instance;
    private File basePath;

    @Before
    public void setUp() throws IOException {
        baseResolver = context.mock(UrlStreamResolver.class);
        basePath = folder.newFolder();
        instance = new LocalFileAwareUrlStreamResolver(baseResolver, BASE_URL, basePath.getAbsolutePath());
    }

    /**
     * Test of getStream method, of class LocalFileAwareUrlStreamResolver.
     * @throws java.lang.Exception
     */
    @Test
    public void testGetStreamMatch() throws Exception {
        // create the file to be requested
        final File file = new File(basePath, "existingFile");
        if(!file.createNewFile()) {
            throw new AssumptionViolatedException("Could not create temporary file required for test!");
        }
        // public URL for this file
        final URL url = new URL(BASE_URL + "/existingfile");

        // should never consult base resolver
        context.checking(new Expectations() {
            {
                never(baseResolver).getStream(with(any(URL.class)));
            }
        });

        // request stream
        final InputStream result = instance.getStream(url);
        assertThat("Input stream should come from file system",
                result, instanceOf(FileInputStream.class));
    }

    /**
     * Test of getStream method, of class LocalFileAwareUrlStreamResolver.
     * @throws java.lang.Exception
     */
    @Test
    public void testGetStreamNoMatch() throws Exception {
        final URL url = new URL("http://somewhere/else");
        // mock an input stream to be returned by mock resolver
        final InputStream resultStream = new ByteArrayInputStream(new byte[0]);
        // base resolver should be triggered
        context.checking(new Expectations() {
            {
                oneOf(baseResolver).getStream(url);
                will(returnValue(resultStream));
            }
        });

        // request stream
        final InputStream result = instance.getStream(url);
        assertSame("Stream should be provided by base resolver", resultStream, result);
    }

    /**
     * Test of getStream method, of class LocalFileAwareUrlStreamResolver.
     * @throws java.lang.Exception
     */
    @Test
    public void testGetStreamNonExistingMatch() throws Exception {
        // public URL for a non-existing file
        final URL url = new URL(BASE_URL + "/existingfile");
        // mock an input stream to be returned by mock resolver
        final InputStream resultStream = new ByteArrayInputStream(new byte[0]);

        // base resolver should be triggered
        context.checking(new Expectations() {
            {
                oneOf(baseResolver).getStream(url);
                will(returnValue(resultStream));
            }
        });

        // request stream
        final InputStream result = instance.getStream(url);
        assertSame("Stream should be provided by base resolver", resultStream, result);
    }

}
