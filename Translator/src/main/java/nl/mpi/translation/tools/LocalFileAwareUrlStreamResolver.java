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

import com.google.common.base.Strings;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A URL stream resolver that uses a provided mapping between a base URL and a
 * base file path to read files from the local filesystem even if they are
 * requested through their public URL.
 *
 * @author Twan Goosen <twan.goosen@mpi.nl>
 */
public class LocalFileAwareUrlStreamResolver implements UrlStreamResolver {
    
    private final static Logger logger = LoggerFactory.getLogger(LocalFileAwareUrlStreamResolver.class);
    
    private final UrlStreamResolver baseResolver;
    
    private final String baseUrl;
    private final File basePath;

    /**
     * Constructs the file aware resolver with a new instance of
     * {@link UrlStreamResolverImpl} as base resolver. If either baseUrl or
     * basePath is empty or null, the behaviour of this resolver will fall back
     * to the base resolver.
     *
     * @param baseResolver resolver to use if no corresponding file can be found
     * @param baseUrl base URL
     * @param basePath the base path on the local file system that corresponds
     * with the base URL
     */
    public LocalFileAwareUrlStreamResolver(UrlStreamResolver baseResolver, String baseUrl, String basePath) {
        this.baseResolver = baseResolver;
        this.baseUrl = Strings.emptyToNull(baseUrl);
        if (Strings.isNullOrEmpty(basePath)) {
            this.basePath = null;
        } else {
            this.basePath = new File(basePath);
        }
    }

    /**
     * Constructs the file aware resolver with a new instance of
     * {@link UrlStreamResolverImpl} as base resolver. If this object was
     * constructed
     *
     * @param baseUrl base URL
     * @param basePath the base path on the local file system that corresponds
     * with the base URL
     */
    public LocalFileAwareUrlStreamResolver(String baseUrl, String basePath) {
        this(new UrlStreamResolverImpl(), baseUrl, basePath);
    }
    
    @Override
    public InputStream getStream(URL url) throws IOException {
        if (baseUrl != null && basePath != null) {
            final String urlString = url.toString();
            if (urlString.startsWith(baseUrl)) {
                final String child = urlString.substring(baseUrl.length());
                final File localFile = new File(basePath, child);
                if (localFile.exists()) {
                    logger.debug("Resolved {} to {}", url, localFile);
                    return new FileInputStream(localFile);
                } else {
                    logger.warn("Requested resource '{}' was not found at expected location '{}'. Falling back to requested external URL.", url, localFile.getAbsolutePath());
                    // fall back to base resolver
                }
            }
        }

        // no match on base URL or file does not exist
        logger.debug("Falling back to base resolver for {}", url);
        return baseResolver.getStream(url);
    }
    
}
