package com.proximus.cds.provider.service.transformer;

import bc.b170.cbu.objects.reqcreatebc.v2.NameType;
import com.proximus.cds.common.CdsConstants;
import com.proximus.cds.model.DataRequestScope;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.builder.ReflectionToStringBuilder;
import org.dozer.DozerConverter;
import org.dozer.MappingException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Created by id815622 on 02/12/2017.
 */
@Component
public class CodeValueTypeCreateGetConverter extends DozerConverter<
        bc.b170.cbu.objects.reqcreatebc.v2.CodeValueType,
        bc.b170.cbu.objects.resgetbc.v2.CodeValueType> {

    private static final Logger LOGGER = LoggerFactory.getLogger(CodeValueTypeCreateGetConverter.class);

    @Autowired
    private ConverterHelper helper;

    @Autowired
    private DataRequestScope dataRequestScope;

    public CodeValueTypeCreateGetConverter() {
        super(bc.b170.cbu.objects.reqcreatebc.v2.CodeValueType.class,
                bc.b170.cbu.objects.resgetbc.v2.CodeValueType.class);

    }

    @Override
    public bc.b170.cbu.objects.resgetbc.v2.CodeValueType convertTo(
            bc.b170.cbu.objects.reqcreatebc.v2.CodeValueType source,
            bc.b170.cbu.objects.resgetbc.v2.CodeValueType dest) {
        if (source == null || StringUtils.isBlank(source.getValue())) {
            return dest;
        }
        if (dest == null) {
            dest = new bc.b170.cbu.objects.resgetbc.v2.CodeValueType();
        }
        try {
            String value = StringUtils.defaultString(source == null ? StringUtils.EMPTY : source.getValue());
            dest.setValue(value);
            dest.setCodeDescription(source.getCodeDescription());
            dest.setCodeSystem(source.getCodeSystem());
            dest.setCodeSystemVersion(source.getCodeSystemVersion());
            // for the contactReason CR999999 - don't translate, keep the original values
            if (CdsConstants.CR999999.equals(value) || !dataRequestScope.isTranslations()) {
                NameType sourceNameType = source.getValueDescription();
                bc.b170.cbu.objects.resgetbc.v2.NameType destNameType = helper.convertNameTypeFromCreateToGet(sourceNameType);
                dest.setValueDescription(destNameType);
            } else {
                dest.setValueDescription(helper.buildNameTypeGet(value));
            }
        } catch (Exception e) {
            LOGGER.error("CodeValueTypeCreateGetConverter error.", e);
            LOGGER.error("source:\n " + ReflectionToStringBuilder.toString(source));
            LOGGER.error("dest:\n " + ReflectionToStringBuilder.toString(source));
        }
        return dest;
    }

    @Override
    public bc.b170.cbu.objects.reqcreatebc.v2.CodeValueType convertFrom(
            bc.b170.cbu.objects.resgetbc.v2.CodeValueType source,
            bc.b170.cbu.objects.reqcreatebc.v2.CodeValueType dest) {
        throw new MappingException("Converter CodeValueTypeCreateGetConverter "
                + "can be used only one way, from requestCreate to responseGet. Arguments passed in were:"
                + ReflectionToStringBuilder.toString(dest) + " and " + ReflectionToStringBuilder.toString(source));
    }
}
