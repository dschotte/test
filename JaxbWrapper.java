package com.proximus.cds.wrapper;

import java.io.StringReader;
import java.io.StringWriter;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.validation.Schema;

public class JaxbWrapper {

    private static final ConcurrentMap<Class<?>, JAXBContext> CONTEXT_MAP = new ConcurrentHashMap<>();

	public static <T> String marshal(Object jaxbElement, Class<T> clazz) throws JaxbWrapperException {
		try {
			StringWriter w = new StringWriter();
			reuseContext(clazz).createMarshaller().marshal(jaxbElement, w);
			return w.toString();
		} catch (Exception e) {
			throw new JaxbWrapperException(e);
		}   
	}

    public static <T> void marshalToResult(Object jaxbElement, Class<T> clazz, Result result) throws JaxbWrapperException {
        try {
			reuseContext(clazz).createMarshaller().marshal(jaxbElement, result);
		} catch (Exception e) {
			throw new JaxbWrapperException(e);
		}
    }
	
	public static <T> T unmarshal(Source source, Class<T> clazz) throws JaxbWrapperException {
		try {
			Object obj = reuseContext(clazz).createUnmarshaller().unmarshal(source);
            return clazz.cast(obj);
		} catch (Exception e) {
			throw new JaxbWrapperException(e);
		}
	}

	public static <T> T unmarshal(String xml, Class<T> clazz) throws JaxbWrapperException {
		try {
			Object obj = reuseContext(clazz).createUnmarshaller().unmarshal(new StringReader(xml));
			return clazz.cast(obj);
		} catch (Exception e) {
			throw new JaxbWrapperException(e);
		}
	}

	public static <T> T unmarshalAndValidatePimV2(String xml, Class<T> clazz) throws XmlValidatorWrapperException {
		try {
			Unmarshaller unmarshaller = reuseContext(clazz).createUnmarshaller();
            Schema pimV2Schema = XmlValidatorWrapper.getPimV2Schema();
            unmarshaller.setSchema(pimV2Schema);
            Object obj = unmarshaller.unmarshal(new StringReader(xml));
			return clazz.cast(obj);
		} catch (Exception e) {
			throw new XmlValidatorWrapperException(e);
		}
	}

	private static <T> JAXBContext reuseContext(Class<T> clazz) throws JAXBException {
        JAXBContext context = CONTEXT_MAP.get(clazz);
        if (context == null) {
            context = JAXBContext.newInstance(clazz);
            CONTEXT_MAP.putIfAbsent(clazz, context); // concurrent safe put
        }
        return context;
	}

}
