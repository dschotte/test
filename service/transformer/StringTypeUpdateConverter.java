package com.proximus.cds.provider.service.transformer;

import org.dozer.DozerConverter;
import org.dozer.MappingException;

/**
 * Created by id815622 on 02/12/2017.
 */
public class StringTypeUpdateConverter
        extends DozerConverter<bc.b170.cbu.objects.requpdatebc.v2.UpdateStringType, java.lang.String> {

    public StringTypeUpdateConverter() {
        super(bc.b170.cbu.objects.requpdatebc.v2.UpdateStringType.class, java.lang.String.class);
    }

    @Override
    public String convertTo(bc.b170.cbu.objects.requpdatebc.v2.UpdateStringType source, String dest) {
        return source == null ? null : source.getValue();
    }

    @Override
    public bc.b170.cbu.objects.requpdatebc.v2.UpdateStringType convertFrom(
            String source,
            bc.b170.cbu.objects.requpdatebc.v2.UpdateStringType dest) {
        throw new MappingException("Converter StringTypeUpdateConverter "
                + "can be used only one way, from UpdateStringType to String. Arguments passed in were:"
                + dest + " and " + source);

    }
}
