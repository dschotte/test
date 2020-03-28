package com.proximus.cds.provider.service;

import bc.b170.cbu.services.bc.v2.ReferenceObjectsCreateRequestType;
import bc.b170.cbu.services.bc.v2.RequestDataCreateBusinessCommunication;
import bc.b170.cbu.services.bc.v2.RequestDataUpdateBusinessCommunication;
import com.proximus.cds.wrapper.JaxbWrapper;
import org.apache.commons.io.FileUtils;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Created by id815622 on 07/12/2017.
 */
@Component
public class MockService {

    private BcDto mockRequestFromFile(final String path) {
        BcDto bcDto = null;
        // try to unmarshal to bcCreate
        try {
            String sCreate = stringFromFile(path);
            RequestDataCreateBusinessCommunication requestCreate
                    = JaxbWrapper.unmarshal(sCreate, RequestDataCreateBusinessCommunication.class);
            bcDto = new BcDto();
            bcDto.setBcCreate(requestCreate.getServiceData().getBusinessCommunication());

            ReferenceObjectsCreateRequestType roCreate = requestCreate.getServiceData().getReferenceObjects();
            bcDto.setRoCreate(roCreate == null ? new ReferenceObjectsCreateRequestType() : roCreate);
        } catch (Exception e) {
            //will try requestUpdate
        }

        // we guessed right - it is bcCreate
        if (bcDto != null) {
            return bcDto;
        }

        // try to unmarshal to bcUpdate
        try {
            String sUpdate = stringFromFile(path);
            RequestDataUpdateBusinessCommunication requestUpdate
                    = JaxbWrapper.unmarshal(sUpdate, RequestDataUpdateBusinessCommunication.class);
            bcDto = new BcDto();
            bcDto.getBcUpdateList().add(requestUpdate.getServiceData().getBusinessCommunication());
            bcDto.getRoUpdateList().add(requestUpdate.getServiceData().getReferenceObjects());
        } catch (Exception e) {
            //nop, just mocking
        }

        return bcDto;
    }

    public List<BcDto> fromFiles(final String... paths) {
        return Arrays.stream(paths).map(path -> mockRequestFromFile(path)).collect(Collectors.toList());
    }

    public String stringFromFile(final String path) throws IOException {
        Resource r = new ClassPathResource(path);
        File fileUpdate = r.getFile();
        return FileUtils.readFileToString(fileUpdate, "UTF-8");
    }

    public RequestDataCreateBusinessCommunication requestCreateFromFile(final String path) throws Exception {
        String xmlCreate = stringFromFile(path);
        return JaxbWrapper.unmarshal(xmlCreate, RequestDataCreateBusinessCommunication.class);

    }
}
