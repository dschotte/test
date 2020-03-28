package com.proximus.cds.provider.service;

import bc.b170.cbu.objects.requpdatebc.v2.StatusType;
import bc.b170.cbu.objects.requpdatebc.v2.UpdateAttributeType;
import bc.b170.cbu.objects.resfindbc.v2.BusinessCommunicationType;
import bc.b170.cbu.services.bc.v2.*;
import org.dozer.Mapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Objects;

/**
 * Created by id815622 on 12/12/2017.
 */
@Component
public class FindBcUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger(FindBcUtils.class);

    @Autowired
    private Mapper mapper;

    @Autowired
    private StatusService statusService;

    /**
     * in de create neem je alles, in de update neem je roles met attribuut "add" en items met "add"
     * en statussen met "modifiy" (van de status hou je enkel de laatste).
     * RefData is added in the CodeValueType converters (see dozerBeanMapping.xml).
     */
    public ResponseDataFindBusinessCommunication buildFindResponse(final List<BcDto> bcDtoList) {
        // build responseFind
        ResponseDataFindBusinessCommunication responseDataFindBC = buildFindResponseRoot();
        ReferenceObjectsFindResponseType roFind = new ReferenceObjectsFindResponseType();
        responseDataFindBC.getServiceData().setReferenceObjects(roFind);

        for (BcDto bcDto : bcDtoList) {
            bc.b170.cbu.objects.resfindbc.v2.BusinessCommunicationType bcFind = buildFindBC(bcDto);
            responseDataFindBC.getServiceData().getBusinessCommunications().add(bcFind);
            // collect all reference objects in roFind
            mapper.map(bcDto.getRoCreate(), roFind);
            bcDto.getRoUpdateList().stream().filter(Objects::nonNull).forEach(ro -> mapper.map(ro, roFind));
        }
        return responseDataFindBC;
    }

    /**
     * in de create neem je alles, in de update neem je roles met attribuut "add" en items met "add"
     * en statussen met "modifiy" (van de status hou je enkel de laatste).
     * RefData is added in the CodeValueType converters (see dozerBeanMapping.xml).
     */
    public ResponseDataGetBusinessCommunication buildGetResponse(final List<BcDto> bcDtoList) {
        // build responseFind
        ResponseDataGetBusinessCommunication responseDataGetBC = buildGetResponseRoot();
        ReferenceObjectsGetResponseType roGet = new ReferenceObjectsGetResponseType();
        responseDataGetBC.getServiceData().setReferenceObjects(roGet);

        for (BcDto bcDto : bcDtoList) {
            bc.b170.cbu.objects.resgetbc.v2.BusinessCommunicationType bcGet = buildGetBC(bcDto);
            responseDataGetBC.getServiceData().setBusinessCommunication(bcGet);
            // collect all reference objects in roGet
            mapper.map(bcDto.getRoCreate(), roGet);
            bcDto.getRoUpdateList().stream().filter(Objects::nonNull).forEach(ro -> mapper.map(ro, roGet));
        }
        return responseDataGetBC;
    }

    private bc.b170.cbu.objects.resfindbc.v2.BusinessCommunicationType buildFindBC(final BcDto bcDto) {
        // bcFind - end result which contains mapped data from create and updates
        bc.b170.cbu.objects.resfindbc.v2.BusinessCommunicationType bcFind = new BusinessCommunicationType();

        bc.b170.cbu.objects.reqcreatebc.v2.BusinessCommunicationType bcCreate = bcDto.getBcCreate();
        // copy everything from create
        mapper.map(bcCreate, bcFind);

        // take the latest status with attribute 'modify' from update
        StatusType updateStatus = statusService.extractModifyStatus(bcDto);
        if (updateStatus != null) {
            bc.b170.cbu.objects.resfindbc.v2.StatusType findStatus = new bc.b170.cbu.objects.resfindbc.v2.StatusType();
            mapper.map(updateStatus, findStatus);
            bcFind.setStatus(findStatus);
        }

        // copy roles and items from updates, takes only the ones with attribute 'ADD'
        bcDto.getBcUpdateList().stream()
                .map(bc -> bc.getRoles())
                .flatMap(x -> x.stream())
                .filter(Objects::nonNull)
                .filter(r -> r.getUpdateAction() == UpdateAttributeType.ADD)
                .map(r -> mapper.map(r, bc.b170.cbu.objects.resfindbc.v2.BusinessCommunicationRoleType.class))
                .forEach(r -> bcFind.getRoles().add(r));
        bcDto.getBcUpdateList().stream()
                .map(bc -> bc.getItems())
                .flatMap(x -> x.stream())
                .filter(Objects::nonNull)
                .filter(item -> item.getUpdateAction() == UpdateAttributeType.ADD)
                .map(r -> mapper.map(r, bc.b170.cbu.objects.resfindbc.v2.BusinessCommunicationItemType.class))
                .forEach(item -> bcFind.getItems().add(item));

        return bcFind;
    }

    private bc.b170.cbu.objects.resgetbc.v2.BusinessCommunicationType buildGetBC(final BcDto bcDto) {
        // bcGet - end result which contains mapped data from create and updates
        bc.b170.cbu.objects.resgetbc.v2.BusinessCommunicationType bcGet = new bc.b170.cbu.objects.resgetbc.v2.BusinessCommunicationType();

        bc.b170.cbu.objects.reqcreatebc.v2.BusinessCommunicationType bcCreate = bcDto.getBcCreate();
        // copy everything from create
        mapper.map(bcCreate, bcGet);

        // take the latest status with attribute 'modify' from update
        StatusType updateStatus = statusService.extractModifyStatus(bcDto);
        if (updateStatus != null) {
            bc.b170.cbu.objects.resgetbc.v2.StatusType getStatus = new bc.b170.cbu.objects.resgetbc.v2.StatusType();
            mapper.map(updateStatus, getStatus);
            bcGet.setStatus(getStatus);
        }

        // copy roles and items from updates, takes only the ones with attribute 'ADD'
        bcDto.getBcUpdateList().stream()
                .map(bc -> bc.getRoles())
                .flatMap(x -> x.stream())
                .filter(Objects::nonNull)
                .filter(r -> r.getUpdateAction() == UpdateAttributeType.ADD)
                .map(r -> mapper.map(r, bc.b170.cbu.objects.resgetbc.v2.BusinessCommunicationRoleType.class))
                .forEach(r -> bcGet.getRoles().add(r));
        bcDto.getBcUpdateList().stream()
                .map(bc -> bc.getItems())
                .flatMap(x -> x.stream())
                .filter(Objects::nonNull)
                .filter(item -> item.getUpdateAction() == UpdateAttributeType.ADD)
                .map(r -> mapper.map(r, bc.b170.cbu.objects.resgetbc.v2.BusinessCommunicationItemType.class))
                .forEach(item -> bcGet.getItems().add(item));

        return bcGet;
    }

    private ResponseDataFindBusinessCommunication buildFindResponseRoot() {
        ResponseDataFindBusinessCommunication result = new ResponseDataFindBusinessCommunication();
        FindBusinessCommunicationServiceContextResponseType serviceContext
                = new FindBusinessCommunicationServiceContextResponseType();
        FindBusinessCommunicationServiceDataResponseType serviceData
                = new FindBusinessCommunicationServiceDataResponseType();
        result.setServiceContext(serviceContext);
        result.setServiceData(serviceData);

        return result;
    }


    private ResponseDataGetBusinessCommunication buildGetResponseRoot() {
        ResponseDataGetBusinessCommunication result = new ResponseDataGetBusinessCommunication();
        GetBusinessCommunicationServiceContextResponseType serviceContext
                = new GetBusinessCommunicationServiceContextResponseType();
        GetBusinessCommunicationServiceDataResponseType serviceData
                = new GetBusinessCommunicationServiceDataResponseType();
        result.setServiceContext(serviceContext);
        result.setServiceData(serviceData);

        return result;
    }

}
