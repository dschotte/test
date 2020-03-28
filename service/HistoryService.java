package com.proximus.cds.provider.service;

import bc.b170.cbu.objects.reqcreatebc.v2.BusinessCommunicationCharValType;
import bc.b170.cbu.services.bc.v2.*;
import com.proximus.cds.common.Common;
import com.proximus.cds.dao.HistoryDao;
import com.proximus.cds.dao.ParamDao;
import com.proximus.cds.model.History;
import com.proximus.cds.utils.JdbcUtils;
import com.proximus.cds.wrapper.JaxbWrapper;
import com.proximus.cds.wrapper.JaxbWrapperException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Created by id815622 on 14/12/2017.
 */
@Component
public class HistoryService {

    private static final Logger LOGGER = LoggerFactory.getLogger(HistoryService.class);
    public static final String TRANSACTION_ID = "TRANSACTION_ID";
    public static final String TRANSACTION_TS = "TRANSACTION_TS";

    @Value("${cds.api.read-param-name}")
    private String readParamName;

    @Autowired
    private Common common;

    @Autowired
    RecontextService recontextService;

    public List<BcDto> retrieveBcDtoList(final FindCriteria criteria) throws SQLException, JaxbWrapperException {
        Connection conn = null;
        try {
            conn = common.getConnection();

            LOGGER.info("Retrieve by customerId: " + criteria.getCustomerId()
                    + " ; customerCtx: " + criteria.getCustomerCtx()
                    + " ; startDate: " + criteria.getStartDate()
                    + " ; endDate: " + criteria.getEndDate()
                    + " ; requestId: " + criteria.getRequestId()
                    + " ; requestCtx: " + criteria.getRequestCtx());

            ParamDao paramDao = new ParamDao(conn);

            if (!paramDao.isTrue(readParamName)) {
                LOGGER.info(String.format("Read parameter %s not enabled", readParamName));
                return Collections.EMPTY_LIST;
            }

            HistoryDao historyDao = new HistoryDao(conn);

            List<History> historyList = historyDao.retrieveByCustomerIdAndDateInterval(
                    null,
                    criteria.getCustomerId() == null ? null : String.valueOf(criteria.getCustomerId()),
                    criteria.getCustomerCtx(),
                    criteria.getStartDate(),
                    criteria.getEndDate(),
                    criteria.getRequestId(),
                    criteria.getRequestCtx());

            return transformHistoryToDto(historyList);
        } finally {
            JdbcUtils.closeQuietly(conn);
        }
    }

    private List<BcDto> transformHistoryToDto(final List<History> historyList) throws JaxbWrapperException {
        LOGGER.info("Number of retrieved BC history XML: " + historyList.size());
        Map<String, List<History>> historyMap = historyList.stream()
                .collect(Collectors.groupingBy(History::getBcUuid));
        LOGGER.info("Number of BC groups: " + historyMap.size());

        List<BcDto> result = new ArrayList<>();

        for (Map.Entry<String, List<History>> entry : historyMap.entrySet()) {
            List<History> list = entry.getValue();
            // sort updates by txDate;
            // we will sort creates later, just before return
            Collections.sort(list, Comparator.comparing(History::getTxDate));
            BcDto bcDto = new BcDto();
            for (History history : list) {
                if (history.getTxType().equalsIgnoreCase("C")) {
                    bcDto.setStartDate(history.getStartDate());
                    String xml = history.getMsgRequestXml();
                    RequestDataCreateBusinessCommunication requestCreate
                            = JaxbWrapper.unmarshal(xml, RequestDataCreateBusinessCommunication.class);
                    CreateBusinessCommunicationServiceDataRequestType serviceData = requestCreate.getServiceData();
                    bcDto.setBcCreate(serviceData.getBusinessCommunication());

                    ReferenceObjectsCreateRequestType roCreate = serviceData.getReferenceObjects();
                    bcDto.setRoCreate(roCreate == null ? new ReferenceObjectsCreateRequestType() : roCreate);

                    //IVR recontextualization - set customerId to the value from the database
                    recontextService.resetCustomerId(bcDto.getBcCreate(), history);

                } else {
                    String xml = history.getMsgRequestXml();
                    RequestDataUpdateBusinessCommunication requestUpdate
                            = JaxbWrapper.unmarshal(xml, RequestDataUpdateBusinessCommunication.class);

                    UpdateBusinessCommunicationServiceDataRequestType serviceData = requestUpdate.getServiceData();
                    ReferenceObjectsUpdateRequestType referenceObjects = serviceData.getReferenceObjects();
                    bcDto.getBcUpdateList().add(serviceData.getBusinessCommunication());
                    bcDto.getRoUpdateList().add(referenceObjects);
                }
            }

            // if there is no bcCreate (update before create), then we neglect this bcDto
            if (bcDto.getBcCreate() != null && bcDto.getStartDate() != null) {
                removeTransactionIdFromCharVals(bcDto);
                result.add(bcDto);
            }
        }
        Collections.sort(result, Comparator.comparing(BcDto::getStartDate).reversed());
        return result;
    }

    public List<BcDto> retrieveBcDto(final String uuid) throws SQLException, JaxbWrapperException {
        // test uuid format
        try {
            UUID.fromString(uuid);
        } catch (IllegalArgumentException exception) {
            //handle the case where string is not valid UUID
            return Collections.EMPTY_LIST;
        }
        Connection conn = null;
        try {
            conn = common.getConnection();

            LOGGER.info("Retrieve by uuid: " + uuid);

            ParamDao paramDao = new ParamDao(conn);

            if (!paramDao.isTrue(readParamName)) {
                LOGGER.info(String.format("Read parameter %s not enabled", readParamName));
                return Collections.EMPTY_LIST;
            }

            HistoryDao historyDao = new HistoryDao(conn);

            List<History> historyList = historyDao.retrieveByUuid(
                    null,
                    uuid);
            return transformHistoryToDto(historyList);
        } finally {
            JdbcUtils.closeQuietly(conn);
        }
    }

    private void removeTransactionIdFromCharVals(final BcDto bcDto) {
        List<BusinessCommunicationCharValType> createCharVals = bcDto.getBcCreate().getCharVals();
        List<BusinessCommunicationCharValType> cleanedCreateCharVals = createCharVals.stream()
                .filter(x -> x.getCharacteristicName() != null)
                .filter(x -> !TRANSACTION_ID.equalsIgnoreCase(x.getCharacteristicName().getDefaultName()))
                .filter(x -> !TRANSACTION_TS.equalsIgnoreCase(x.getCharacteristicName().getDefaultName()))
                .collect(Collectors.toList());
        createCharVals.clear();
        createCharVals.addAll(cleanedCreateCharVals);
        bcDto.getBcUpdateList().stream()
                .forEach(bcUpdate -> {
                    List<bc.b170.cbu.objects.requpdatebc.v2.BusinessCommunicationCharValType> updateCharVals
                            = bcUpdate.getCharVals();
                    List<bc.b170.cbu.objects.requpdatebc.v2.BusinessCommunicationCharValType> cleanedUpdateCharVals =
                            updateCharVals.stream()
                                    .filter(x -> x.getCharacteristicName() != null && x.getCharacteristicName().getDefaultName() != null)
                                    .filter(x -> !TRANSACTION_ID.equalsIgnoreCase(x.getCharacteristicName().getDefaultName().getValue()))
                                    .filter(x -> !TRANSACTION_TS.equalsIgnoreCase(x.getCharacteristicName().getDefaultName().getValue()))
                                    .collect(Collectors.toList());
                    updateCharVals.clear();
                    updateCharVals.addAll(cleanedUpdateCharVals);
                });
    }

}
