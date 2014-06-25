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

import java.net.URL;
import org.junit.Test;

import static org.junit.Assert.*;

/**
 *
 * @author Twan Goosen <twan.goosen@mpi.nl>
 */
public class HttpHandleResolverTest {

    // Handle to the "Route to Kleve" resource
    public static final String HANDLE_URI = "http://hdl.handle.net/1839/00-0000-0000-0009-3C7E-F";
    public static final String HANDLE_RESOLVED_URI = "https://corpus1.mpi.nl/media-archive/demo/pewi/Media/route_to_kleve.jpg";

    /**
     * Test of resolveHandle method, of class HttpHandleResolver.
     */
    @Test
    public void testResolveHandle() throws Exception {
	URL inputFileURL = new URL(HANDLE_URI);
	HttpHandleResolver instance = new HttpHandleResolver();
	URL expResult = new URL(HANDLE_RESOLVED_URI);
	URL result = instance.resolveHandle(inputFileURL);
	assertEquals("Handle did not resolve to expected URL. This might also mean that the handle server may be down or the resource has moved.", expResult, result);
    }
}
