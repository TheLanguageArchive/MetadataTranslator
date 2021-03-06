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

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import nl.mpi.archiving.corpusstructure.core.URLConnections;

/**
 *
 * @author Twan Goosen <twan.goosen@mpi.nl>
 */
public class UrlStreamResolverImpl implements UrlStreamResolver {

    /**
     * URLConnections service object that follows redirects (allowing safe
     * scheme switches such as http -> https)
     */
    private final URLConnections connections = new URLConnections();

    @Override
    public InputStream getStream(URL url) throws IOException {
        final URLConnection connection = url.openConnection();
        // get the stream, following redirects if encountered
        return connections.openStreamCheckRedirects(connection);
    }

}
