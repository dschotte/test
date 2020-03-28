package com.proximus.cds.provider.service.transformer;

import bc.b170.cbu.objects.resfindbc.v2.LabelType;
import bc.b170.cbu.objects.resfindbc.v2.LanguageCodeISOAlpha2Type;
import bc.b170.cbu.objects.resfindbc.v2.NameType;
import com.proximus.cds.model.PimCode;
import com.proximus.cds.refdata.RefDataHolder;
import org.apache.commons.lang3.StringUtils;
import org.dozer.Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Contains utility methods to build refData valueDescription tags.
 * <p>
 * Created by id815622 on 05/12/2017.
 */
@Component
public class ConverterHelper {

    @Autowired
    private RefDataHolder refDataHolder;

    @Autowired
    private Mapper mapper;

    public bc.b170.cbu.objects.resfindbc.v2.NameType buildNameType(
            final String value
    ) {
        PimCode cd = refDataHolder.getRefDataMap().get(value);
        if (cd == null) {
            return null;
        }
        bc.b170.cbu.objects.resfindbc.v2.NameType nameType = new bc.b170.cbu.objects.resfindbc.v2.NameType();
        nameType.setDefaultName(cd.getLabelEn());
        List<LabelType> labelTypes = new ArrayList<>();
        LabelType labelEn = buildLabelType("EN", cd.getLabelEn());
        LabelType labelNL = buildLabelType("NL", cd.getLabelNl());
        LabelType labelFR = buildLabelType("FR", cd.getLabelFr());
        Arrays.asList(labelEn, labelNL, labelFR)
                .stream()
                .filter(lang -> lang != null)
                .forEach(lang -> labelTypes.add(lang));
        nameType.setLanguageNames(labelTypes);
        return nameType;
    }

    private LabelType buildLabelType(final String lang, final String text) {
        if (StringUtils.isBlank(text)) {
            return null;
        }
        LabelType labelType = new LabelType();
        LanguageCodeISOAlpha2Type codeType = new LanguageCodeISOAlpha2Type();
        codeType.setAlpha2Code(lang);
        labelType.setLanguage(codeType);
        labelType.setText(text);
        return labelType;
    }

    public NameType convertNameTypeFromUpdateToFind(final bc.b170.cbu.objects.requpdatebc.v2.NameType source) {
        if (source == null) {
            return null;
        }
        NameType dest = new NameType();
        mapper.map(source, dest);
        return dest;
    }

    public bc.b170.cbu.objects.resgetbc.v2.NameType convertNameTypeFromUpdateToGet(final bc.b170.cbu.objects.requpdatebc.v2.NameType source) {
        if (source == null) {
            return null;
        }
        bc.b170.cbu.objects.resgetbc.v2.NameType dest = new bc.b170.cbu.objects.resgetbc.v2.NameType();
        mapper.map(source, dest);
        return dest;
    }

    public bc.b170.cbu.objects.resfindbc.v2.NameType convertNameTypeFromCreateToFind(final bc.b170.cbu.objects.reqcreatebc.v2.NameType source) {
        if (source == null) {
            return null;
        }
        bc.b170.cbu.objects.resfindbc.v2.NameType dest = new bc.b170.cbu.objects.resfindbc.v2.NameType();
        mapper.map(source, dest);
        return dest;
    }

    public bc.b170.cbu.objects.resgetbc.v2.NameType convertNameTypeFromCreateToGet(final bc.b170.cbu.objects.reqcreatebc.v2.NameType source) {
        if (source == null) {
            return null;
        }
        bc.b170.cbu.objects.resgetbc.v2.NameType dest = new bc.b170.cbu.objects.resgetbc.v2.NameType();
        mapper.map(source, dest);
        return dest;
    }

    public bc.b170.cbu.objects.resgetbc.v2.NameType buildNameTypeGet(
            final String value
    ) {
        PimCode cd = refDataHolder.getRefDataMap().get(value);
        if (cd == null) {
            return null;
        }
        bc.b170.cbu.objects.resgetbc.v2.NameType nameType = new bc.b170.cbu.objects.resgetbc.v2.NameType();
        nameType.setDefaultName(cd.getLabelEn());
        List<bc.b170.cbu.objects.resgetbc.v2.LabelType> labelTypes = new ArrayList<>();
        bc.b170.cbu.objects.resgetbc.v2.LabelType labelEn = buildLabelTypeGet("EN", cd.getLabelEn());
        bc.b170.cbu.objects.resgetbc.v2.LabelType labelNL = buildLabelTypeGet("NL", cd.getLabelNl());
        bc.b170.cbu.objects.resgetbc.v2.LabelType labelFR = buildLabelTypeGet("FR", cd.getLabelFr());
        Arrays.asList(labelEn, labelNL, labelFR)
                .stream()
                .filter(lang -> lang != null)
                .forEach(lang -> labelTypes.add(lang));
        nameType.setLanguageNames(labelTypes);
        return nameType;
    }

    private bc.b170.cbu.objects.resgetbc.v2.LabelType buildLabelTypeGet(final String lang, final String text) {
        if (StringUtils.isBlank(text)) {
            return null;
        }
        bc.b170.cbu.objects.resgetbc.v2.LabelType labelType = new bc.b170.cbu.objects.resgetbc.v2.LabelType();
        bc.b170.cbu.objects.resgetbc.v2.LanguageCodeISOAlpha2Type codeType
                = new bc.b170.cbu.objects.resgetbc.v2.LanguageCodeISOAlpha2Type();
        codeType.setAlpha2Code(lang);
        labelType.setLanguage(codeType);
        labelType.setText(text);
        return labelType;
    }
}
