MetadataTranslator ${project.artifactId}-${project.version}-r${buildNumber}

 What is it?
 -----------
The MetadataTranstator is a converter from CMDI to IMDI and vice-versa.
It is composed by 2 modules:
1 - A translation library (Translator) providing methods to translate metadata
documents from CMDI to IMDI and vice-versa.
2 - A Jersey JAX-RS service, exposing the library functionality via http.


 The Latest Version
 ------------------
MetadataTranslator-${project.artifactId}-${project.version}-r${buildNumber}


 Changes
--------
Please see the file called CHANGES.TXT 


 Documentation
 -------------
The documentation available as of the date of this release:

Context parameter configuration:
There is just one context configuration parameter for the translation service, 
specifying whether or not to allow the service to be called using as input, 
file path pointing to a file in the server file system.

Parameter: "allowFileProtocol" | Possible values: "true" or "false"
By default this is set to false. See and change it in: META-INF/context.xml


How to call the service:
The service answers on the "/translate" path of the of the servlet URL.
i.e.
	given the translation service servlet is mapped in the URL:
		https://<server name>/<servlet path>
	the service will answer to translation requests for URLs in the form:
		https://<server name>/<servlet path>/translate?<URL parameters>
	
	
URL parameters:		
- in:
	This parameter points to the input file to translate (imdi or cmdi).			
	Possible value forms:
		1. Handle without "hdl:" prefix. 
			e.g. 1839/00-0000-0000-0009-294C-9
		2. Full HTTP URL (escaped or not). 
			e.g. http://lux16.mpi.nl/cmdi_test/leslla/Discourse/Turkish/Hilal/Cycle3/d_t_hi_3.cmdi
		3. File path in the server file system if the context variable "allowFileProtocol" is set to "true". e.g.
			e.g. file:///lat/corpora/cmdi/iprosla/IPROSLA_Corpora/IPROSLA_Nijmegen.cmdi
		
- outFormat:
	This parameter specifies the desired output format of the translation.
	Possible values:
		"cmdi" or "imdi"

Assumptions:
(1). If "outFormat" is not specified, imdi is assumed.
(2). If the file extension of the input file (after resolving the "in" parameter) turns out to be the same as the 
requested "outFormat", the original document is returned.
(3). If the file extension of the input file (after resolving the "in" parameter) is neither "cmdi" nor "imdi",
the input file is assumed to be "imdi" or "cmdi" if the "outFormat" parameter is "cmdi" or "imdi" respectively.
Taking into account the assumption made in (1).

See INTALL.TXT for usage examples.

User manual and documentation:
See above.

Project wiki:
Not available!


 Installation
 ------------
Please see the file called INSTALL.TXT 


 Upgrade
 ------------
Please see the file called UPGRADE.TXT


 License
 ---------
See the file called LICENSES.TXT
