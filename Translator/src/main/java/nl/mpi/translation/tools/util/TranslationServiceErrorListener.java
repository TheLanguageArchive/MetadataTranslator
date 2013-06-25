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
package nl.mpi.translation.tools.util;

import javax.xml.transform.ErrorListener;
import javax.xml.transform.TransformerException;
import org.slf4j.Logger;

/**
 * Error listener for the XML transformer to replace default which outputs to the console
 *
 * @author Twan Goosen <twan.goosen@mpi.nl>
 */
public class TranslationServiceErrorListener implements ErrorListener {

    private final Logger logger;

    public TranslationServiceErrorListener(Logger logger) {
	this.logger = logger;
	logger.debug("Redirecting XSLT warnings and errors to this logger");
    }

    @Override
    public void warning(TransformerException te) throws TransformerException {
	logger.warn("Transformer warning: {}", te.getMessageAndLocation());
	logger.debug("Transformation warning stacktrace", te);
    }

    @Override
    public void error(TransformerException te) throws TransformerException {
	// errors will be caught by the service, so swallow here except in debug
	logger.debug("Transformation error", te);
    }

    @Override
    public void fatalError(TransformerException te) throws TransformerException {
	// errors will be caught by the service, so swallow here  except in debug
	logger.debug("Transformation fatal error", te);
    }
}
