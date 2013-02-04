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

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Handle resolver that simple connects to the handle URL and picks up the Location from the 303 response from {@link http://hdl.handle.net}
 *
 * @author Twan Goosen <twan.goosen@mpi.nl>
 * @author Andre Moreira <andre.moreira@mpi.nl>
 */
public class HttpHandleResolver implements HandleResolver {

    private final static Logger logger = LoggerFactory.getLogger(HttpHandleResolver.class);

    @Override
    public URL resolveHandle(URL inputFileURL) throws IOException {
	final HttpURLConnection httpURLconnection = (HttpURLConnection) inputFileURL.openConnection();
	httpURLconnection.setInstanceFollowRedirects(false);
	if (httpURLconnection.getResponseCode() == 303) {
	    final String resolvedHandleURL = httpURLconnection.getHeaderField("Location");
	    httpURLconnection.setInstanceFollowRedirects(true);
	    inputFileURL = new URL(resolvedHandleURL);
	    logger.debug("Handle resolves to: '{}'", resolvedHandleURL);
	} else {
	    logger.error("Cannot resolve handle '{}'", inputFileURL);
	    throw new IOException();
	}
	return inputFileURL;
    }
}
