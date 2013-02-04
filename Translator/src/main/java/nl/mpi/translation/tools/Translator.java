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
package nl.mpi.translation.tools;

import java.io.IOException;
import java.net.URL;
import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerException;

/**
 * Interface for rest translation library to convert CMDI into IMDI and vice-versa.
 * <br/><br/>
 *
 * @author andmor <andre.moreira@mpi.nl>
 * @author Twan Goosen <twan.goosen@mpi.nl>
 */
public interface Translator {

    /**
     * This method reads an IMDI XML document form the supplied URL and returns it converted
     * to CMDI. If the input document specified by <b>imdiFileURL</b> has <i>.cmdi</i> extension,
     * the original file is returned.
     *
     * @param imdiFileURL - The URL pointing to the IMDI file to convert.
     * @return CMDI file converted from IMDI.
     * @throws TransformerException
     * @throws XMLStreamException
     * @throws IOException
     */
    String getCMDI(URL imdiFileURL, String serviceURI) throws TransformerException, XMLStreamException, IOException;

    /**
     * This method reads an CMDI XML document form the supplied URL and returns it converted
     * to IMDI. If the input document specified by <b>cmdiFileURL</b> has <i>.imdi</i> extension,
     * the original file is returned.
     *
     * @param cmdiFileURL - The URL pointing to the CMDI file to convert.
     * @return IMDI file converted from CMDI.
     * @throws TransformerException
     * @throws XMLStreamException
     * @throws IOException
     */
    String getIMDI(URL cmdiFileURL, String serviceURI) throws TransformerException, XMLStreamException, IOException;
}
