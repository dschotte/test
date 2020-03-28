package com.proximus.cds.provider.service;

import bc.b170.cbu.objects.reqfindbc.v2.CustomerIdentifierType;
import bc.b170.cbu.objects.reqfindbc.v2.RequestIdentifierType;
import bc.b170.cbu.services.bc.v2.*;
import com.proximus.cds.model.DataRequestScope;
import com.proximus.cds.wrapper.JaxbWrapperException;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.xml.datatype.XMLGregorianCalendar;
import java.sql.SQLException;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import static com.proximus.cds.hotline.service.CsvConstants.EMPTY;
import static com.proximus.cds.hotline.service.CsvConstants.resolve;

/**
 * Created by id815622 on 23/11/2017.
 */
@Component
public class FindBCService {

    private static final Logger LOGGER = LoggerFactory.getLogger(FindBCService.class);
    public static final String FULL = "FULL";

    @Autowired
    private HistoryService historyService;

    @Autowired
    private FindBcUtils findBcUtils;

    @Autowired
    private DataRequestScope dataRequestScope;

    /**
     * Called from APIM
     */
    public ResponseDataFindBusinessCommunication retrieveResponseFind(final RequestDataFindBusinessCommunication request) throws SQLException, JaxbWrapperException {
        FindCriteria criteria = extractFindCriteria(request);
        setTranslationsFlag(request);

        List<BcDto> bcDtoList = historyService.retrieveBcDtoList(criteria);

        return findBcUtils.buildFindResponse(bcDtoList);
    }

    /**
     * Called from APIM
     */
    public ResponseDataGetBusinessCommunication retrieveResponseGet(final RequestDataGetBusinessCommunication request) throws SQLException, JaxbWrapperException {
        String uuid = extractUUID(request);
        setTranslationsFlag(request);
        List<BcDto> bcDtoList = historyService.retrieveBcDto(uuid);

        return findBcUtils.buildGetResponse(bcDtoList);
    }

    /**
     * Called from hotline page
     */
    public ResponseDataFindBusinessCommunication retrieveResponseFind(final Optional<Long> customerId,
                                                                      final Optional<String> customerCtx,
                                                                      final Optional<Date> startDate,
                                                                      final Optional<Date> endDate,
                                                                      final Optional<String> requestId,
                                                                      final Optional<String> requestCtx) {
        try {
            FindCriteria criteria = new FindCriteria(customerId, customerCtx, startDate, endDate, requestId, requestCtx);

            List<BcDto> bcDtoList = historyService.retrieveBcDtoList(criteria);

            return findBcUtils.buildFindResponse(bcDtoList);
        } catch (Exception e) {
            LOGGER.error("Could not do find via hotline page", e); //we can throw a runtime exception as this find is called from hotline page
            throw new RuntimeException("Could not do find", e);
        }
    }

    /**
     * Called from hotline page
     */
    public ResponseDataFindBusinessCommunication retrieveResponseFindByUUID(final Optional<String> uuid) {
        try {
            List<BcDto> bcDtoList = uuid.isPresent()
                    ? historyService.retrieveBcDto(uuid.get())
                    : Collections.EMPTY_LIST;

            return findBcUtils.buildFindResponse(bcDtoList);
        } catch (Exception e) {
            LOGGER.error("Could not do find via hotline page", e); //we can throw a runtime exception as this find is called from hotline page
            throw new RuntimeException("Could not do find", e);
        }
    }

    /**
     * Called from hotline page
     */
    public ResponseDataGetBusinessCommunication retrieveResponseGet(final Optional<String> uuid) {
        try {
            List<BcDto> bcDtoList = uuid.isPresent() ? historyService.retrieveBcDto(uuid.get()) : Collections.emptyList();

            return findBcUtils.buildGetResponse(bcDtoList);
        } catch (Exception e) {
            LOGGER.error("Could not do GET via hotline page", e); //we can throw a runtime exception as this is is called from hotline page
            throw new RuntimeException("Could not perform GET", e);
        }
    }

    private FindCriteria extractFindCriteria(final RequestDataFindBusinessCommunication request) {
        if (request == null) {
            return null;
        }

        FindCriteria result = new FindCriteria();
        FindBusinessCommunicationCriteriaSequenceRequestAndType criteria = request.getServiceData().getCriteria();
        if (criteria != null) {

            CustomerIdentifierType customerIdentifier = criteria.getCustomerIdentifier();
            if (customerIdentifier != null) {
                String customerIdString = customerIdentifier.getId();
                if (StringUtils.isNumeric(customerIdString)) {
                    result.setCustomerId(Long.valueOf(customerIdString));
                }
                if (customerIdentifier.getIdContext() != null) {
                    result.setCustomerCtx(customerIdentifier.getIdContext().getValue());
                }
            }
            if (criteria.getTimeInterval() != null) {
                XMLGregorianCalendar startTimeStamp = criteria.getTimeInterval().getStartTimeStamp();
                XMLGregorianCalendar endTimeStamp = criteria.getTimeInterval().getEndTimeStamp();
                if (startTimeStamp != null) {
                    result.setStartDate(startTimeStamp.toGregorianCalendar().getTime());
                }
                if (endTimeStamp != null) {
                    result.setEndDate(endTimeStamp.toGregorianCalendar().getTime());
                }
            }
            RequestIdentifierType requestIdentifier = criteria.getRequestIdentifier();
            if (requestIdentifier != null) {
                String requestId = requestIdentifier.getId();
                result.setRequestId(requestId);
                if (requestIdentifier.getIdContext() != null) {
                    result.setRequestCtx(requestIdentifier.getIdContext().getValue());
                }
            }
        }
        return result;
    }

    private void setTranslationsFlag(final RequestDataFindBusinessCommunication request) {
        Optional<String> scope = resolve(() -> request.getServiceContext().getScoping().getDataScope().getValue());
        LOGGER.info("requestFind, translations: " + scope.orElse("empty"));
        dataRequestScope.setTranslations(!FULL.equalsIgnoreCase(scope.orElse(EMPTY)));
    }

    private void setTranslationsFlag(final RequestDataGetBusinessCommunication request) {
        Optional<String> scope = resolve(() -> request.getServiceContext().getScoping().getDataScope().getValue());
        LOGGER.info("requestGet, translations: " + scope.orElse("empty"));
        dataRequestScope.setTranslations(!FULL.equalsIgnoreCase(scope.orElse(EMPTY)));
    }

    private String extractUUID(final RequestDataGetBusinessCommunication request) {
        return resolve(() -> request.getServiceData().getBusinessCommunicationIdentifier().getId()).orElse(null);
    }

}
