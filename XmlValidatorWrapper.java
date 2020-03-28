package com.proximus.cds.wrapper;

import java.io.IOException;
import java.io.StringReader;
import java.net.URL;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import javax.xml.XMLConstants;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.xml.sax.SAXException;

import com.proximus.cds.ws.ResourcePathName;

public class XmlValidatorWrapper {
	
    private static final ConcurrentMap<String, Schema> SCHEMA_MAP = new ConcurrentHashMap<>();

	public static void validateBusinessCommunicationV2(String msgRequestXml) throws XmlValidatorWrapperException {
		try {
			getPimV2Schema().newValidator().validate(new StreamSource(new StringReader(msgRequestXml)));
		} catch (SAXException | IOException e) {
			throw new XmlValidatorWrapperException(e);
		}
	}

	private static Schema reuseSchema(String schemaPathName) throws SAXException, IOException {
        Schema schema = SCHEMA_MAP.get(schemaPathName);
        if (schema == null) {
			SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
		    URL url = XmlValidatorWrapper.class.getClassLoader().getResource(schemaPathName);
		    if (url == null) throw new IOException(String.format("Schema file %s not found", schemaPathName));
			schema = factory.newSchema(url);
			SCHEMA_MAP.putIfAbsent(schemaPathName, schema); // concurrent safe put
        }
        return schema;
	}

	public static Schema getPimV2Schema() throws IOException, SAXException {
		String schemaPathName = ResourcePathName.XSD_PIM_V2;
		return reuseSchema(schemaPathName);
	}
	
}
