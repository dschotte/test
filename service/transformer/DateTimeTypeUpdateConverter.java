package com.proximus.cds.provider.service.transformer;

import org.dozer.DozerConverter;
import org.dozer.MappingException;

import javax.xml.datatype.XMLGregorianCalendar;

/**
 * Created by id815622 on 02/12/2017.
 */
public class DateTimeTypeUpdateConverter
        extends DozerConverter<bc.b170.cbu.objects.requpdatebc.v2.UpdateDateTimeType, XMLGregorianCalendar> {

    public DateTimeTypeUpdateConverter() {
        super(bc.b170.cbu.objects.requpdatebc.v2.UpdateDateTimeType.class, XMLGregorianCalendar.class);
    }

    @Override
    public XMLGregorianCalendar convertTo(bc.b170.cbu.objects.requpdatebc.v2.UpdateDateTimeType source, XMLGregorianCalendar dest) {
        return source == null ? null : source.getValue();
    }

    @Override
    public bc.b170.cbu.objects.requpdatebc.v2.UpdateDateTimeType convertFrom(
            XMLGregorianCalendar source,
            bc.b170.cbu.objects.requpdatebc.v2.UpdateDateTimeType dest) {
        throw new MappingException("Converter UpdateDateTimeTypeUpdateConverter "
                + "can be used only one way, from UpdateDateTimeType to XMLGregorianCalendar. Arguments passed in were:"
                + dest + " and " + source);

    }
}
