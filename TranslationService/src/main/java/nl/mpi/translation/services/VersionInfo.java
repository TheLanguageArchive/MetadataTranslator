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
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Properties;
import javax.servlet.ServletContext;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Resource that provides the version number of the service in plain text
 *
 * @author Twan Goosen <twan.goosen@mpi.nl>
 */
@Path("/version")
public class VersionInfo {

    private final static Logger logger = LoggerFactory.getLogger(VersionInfo.class);
    public static final String VERSION_PROPERTY_NAME = "Service-Version";
    public static final String BUILDNUMBER_PROPERTY_NAME = "Service-BuildNumber";
    public static final String MANIFEST_FILE = "/META-INF/MANIFEST.MF";
    @Context
    private ServletContext servletContext;

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String version() {
        try {
            final String version = readManifestProperties().getProperty(VERSION_PROPERTY_NAME);
            logger.debug("Read version property from manifest: {} = {}", VERSION_PROPERTY_NAME, version);
            final String buildNumber = readManifestProperties().getProperty(BUILDNUMBER_PROPERTY_NAME);
            logger.debug("Read build number property from manifest: {} = {}", BUILDNUMBER_PROPERTY_NAME, buildNumber);

            if (version == null) {
                logger.warn("Version property not present in manifest. Returning 'UNKNWON'.");
                return "UNKNOWN";
            } else {
                return String.format("%s-%s", version, buildNumber);
            }
        } catch (IOException ioEx) {
            logger.warn("Could not read version info from manifest", ioEx);
            return ioEx.getMessage();
        }
    }

    /**
     *
     * @return properties read from MANIFEST.MF file
     * @throws IOException
     */
    private Properties readManifestProperties() throws IOException {
        logger.debug("Reading manifest from {}", MANIFEST_FILE);
        final InputStream resourceAsStream = servletContext.getResourceAsStream(MANIFEST_FILE);

        final Properties properties = new Properties();
        properties.load(new InputStreamReader(resourceAsStream));
        return properties;
    }
}
