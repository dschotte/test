package com.proximus.cds.provider.service.transformer;

import bc.b170.cbu.objects.requpdatebc.v2.NameType;
import bc.b170.cbu.objects.requpdatebc.v2.UpdateStringType;
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
public class CodeValueTypeUpdateConverter extends DozerConverter<
        bc.b170.cbu.objects.requpdatebc.v2.CodeValueType,
        bc.b170.cbu.objects.resfindbc.v2.CodeValueType> {

    private static final Logger LOGGER = LoggerFactory.getLogger(CodeValueTypeUpdateConverter.class);

    @Autowired
    private ConverterHelper helper;

    @Autowired
    private DataRequestScope dataRequestScope;

    public CodeValueTypeUpdateConverter() {
        super(bc.b170.cbu.objects.requpdatebc.v2.CodeValueType.class,
                bc.b170.cbu.objects.resfindbc.v2.CodeValueType.class);

    }

    private String buildFindString(final UpdateStringType value) {
        return value == null ? null : value.getValue();
    }

    @Override
    public bc.b170.cbu.objects.resfindbc.v2.CodeValueType convertTo(
            bc.b170.cbu.objects.requpdatebc.v2.CodeValueType source,
            bc.b170.cbu.objects.resfindbc.v2.CodeValueType dest) {
        if (source == null || source.getValue() == null || StringUtils.isBlank(source.getValue().getValue())) {
            return dest;
        }
        if (dest == null) {
            dest = new bc.b170.cbu.objects.resfindbc.v2.CodeValueType();
        }
        try {
            String value = StringUtils.defaultString(buildFindString(source.getValue()));
            dest.setValue(value);
            dest.setCodeDescription(buildFindString(source.getCodeDescription()));
            dest.setCodeSystem(buildFindString(source.getCodeSystem()));
            dest.setCodeSystemVersion(buildFindString(source.getCodeSystemVersion()));
            dest.setContext(buildFindString(source.getContext()));
            // for the contactReason CR999999 - don't translate, keep the original values
            if (CdsConstants.CR999999.equals(value) || !dataRequestScope.isTranslations()) {
                NameType sourceNameType = source.getValueDescription();
                bc.b170.cbu.objects.resfindbc.v2.NameType destNameType = helper.convertNameTypeFromUpdateToFind(sourceNameType);
                dest.setValueDescription(destNameType);
            } else {
                dest.setValueDescription(helper.buildNameType(value));
            }
        } catch (Exception e) {
            LOGGER.error("CodeValueTypeUpdateConverter error.", e);
            LOGGER.error("source:\n " + ReflectionToStringBuilder.toString(source));
            LOGGER.error("dest:\n " + ReflectionToStringBuilder.toString(source));
        }
        return dest;
    }

    @Override
    public bc.b170.cbu.objects.requpdatebc.v2.CodeValueType convertFrom(
            bc.b170.cbu.objects.resfindbc.v2.CodeValueType source,
            bc.b170.cbu.objects.requpdatebc.v2.CodeValueType dest) {
        throw new MappingException("Converter CodeValueTypeUpdateConverter "
                + "can be used only one way, from requestUpdate to responseFind. Arguments passed in were:"
                + ReflectionToStringBuilder.toString(dest) + " and " + ReflectionToStringBuilder.toString(source));
    }
}
