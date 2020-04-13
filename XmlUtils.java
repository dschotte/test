/*
 * Created on 30-Jan-2018
 */
package com.proximus.cds.utils;

import java.io.StringReader;
import java.io.StringWriter;
import java.util.GregorianCalendar;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Collection of utility methods to work with XML. 
 * 
 * @author id073566
 */
public class XmlUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger(XmlUtils.class);
	
	/**
	 * Returns (un)formatted XML (when error)
	 * 
	 * @param xml The XML to format
	 */
	public static String formatXml(String xml) {
		try {
			TransformerFactory factory = TransformerFactory.newInstance();
			factory.setAttribute("indent-number", 4);             
			Transformer transformer = factory.newTransformer();
			transformer.setOutputProperty(OutputKeys.INDENT, "yes");
			transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
			StreamSource source = new StreamSource(new StringReader(xml.replaceAll(">\\s+<", "><").trim()));
			StreamResult result = new StreamResult(new StringWriter());
			
			transformer.transform(source, result);
			
			return result.getWriter().toString();
		} catch (Exception e) {
			LOGGER.error(String.format("Could not format %s", xml), e);
			return xml;
		}
	}

	public static String toString(Source source) throws TransformerException {
		TransformerFactory factory = TransformerFactory.newInstance();
		Transformer transformer = factory.newTransformer();
		StreamResult result = new StreamResult(new StringWriter());
		
		transformer.transform(source, result);
		
		return result.getWriter().toString().replaceAll(">\\s+<", "><").trim();
	}
	
    public static XMLGregorianCalendar createXMLGregorianCalendar() throws DatatypeConfigurationException {
        GregorianCalendar cal = new GregorianCalendar();
        return DatatypeFactory.newInstance().newXMLGregorianCalendar(cal);
    }

}
