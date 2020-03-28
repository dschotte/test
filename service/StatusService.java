package com.proximus.cds.provider.service;

import bc.b170.cbu.objects.requpdatebc.v2.BusinessCommunicationType;
import bc.b170.cbu.objects.requpdatebc.v2.StatusType;
import bc.b170.cbu.objects.requpdatebc.v2.UpdateAttributeType;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Component;

import javax.xml.datatype.XMLGregorianCalendar;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

import static com.proximus.cds.hotline.service.CsvConstants.resolve;

@Component
public class StatusService {

    private static final String EMAIL = "EMAIL";
    private static final String CLICKED_ON_LINK = "BCST00018";
    private static final String OUTBOUND = "BCDIR002";

    //    On demand of Business the CDS should apply some logic in the read interface to only return
//    the most relevant status of an email instead of simply returning the last one as it does it now.
//            Logic :
//    For all outbound  (<v12:businessCommunication><v13:direction><v13:value>BCDIR002)
//    emails (<v13:item><v13:type><v13:value>EMAIL) stop at the first occurrence of the status code “Clicked on link”
//    (<v12:businessCommunication>
//      <v13:status updateAction="modify">
//          <v13:code updateAction="modify">
//              <v13:value updateAction="modify">BCST00018)
//    and return that one with its related date (<v13:status updateAction="modify"> <v13:validFor updateAction="modify">
//            <v13:startTimeStamp updateAction="modify">2018-09-12T03:25:22.626+02:00)
//    //StatusType xPath : businesscommunication.status.code.value
    public StatusType extractModifyStatus(final BcDto bcDto) {
        Optional<String> direction = resolve(() -> bcDto.getBcCreate().getDirection().getValue());
        boolean isOutbound = direction.isPresent() && OUTBOUND.equalsIgnoreCase(direction.get());
        Optional<String> emails = bcDto.getBcCreate().getItems().stream()
                .map(x -> x.getType())
                .filter(Objects::nonNull)
                .map(x -> x.getValue())
                .filter(x -> EMAIL.equalsIgnoreCase(x))
                .findAny();
        boolean isEmailUpdates = emails.isPresent();

        if (isOutbound && isEmailUpdates) {
            return extractStatusForEmails(bcDto.getBcUpdateList());
        } else {
            return extractLatestStatus(bcDto.getBcUpdateList());
        }
    }

    private StatusType extractLatestStatus(
            final List<BusinessCommunicationType> bcUpdateList
    ) {
        StatusType statusType = bcUpdateList.stream()
                .map(bc -> bc.getStatus())
                .filter(status -> status != null)
                .filter(status -> status.getCode() != null)
                .filter(status -> status.getCode().getValue() != null)
                .filter(status -> StringUtils.isNotBlank(status.getCode().getValue().getValue()))
                .filter(status -> status.getUpdateAction() == UpdateAttributeType.MODIFY)
                .reduce((first, second) -> second)
                .orElse(null);
        return statusType;
    }

    private StatusType extractStatusForEmails(
            final List<bc.b170.cbu.objects.requpdatebc.v2.BusinessCommunicationType> bcUpdateList) {
        // sort by date ascending
        List<bc.b170.cbu.objects.requpdatebc.v2.BusinessCommunicationType> sortedList = bcUpdateList.stream()
                .sorted((o1, o2) -> extractStatusDate(o1).compareTo(extractStatusDate(o2)))
                .collect(Collectors.toList());
        // take the first with status BCST00018
        Optional<StatusType> firstStatus = sortedList.stream()
                .map(x -> x.getStatus())
                .filter(Objects::nonNull)
                .filter(x -> x.getCode() != null && x.getCode().getValue() != null)
                .filter(x -> CLICKED_ON_LINK.equalsIgnoreCase(x.getCode().getValue().getValue()))
                .findFirst();
        if (firstStatus.isPresent()) {
            return firstStatus.get();
        } else {
            return extractLatestStatus(bcUpdateList);
        }
    }

    private java.util.Date extractStatusDate(
            final bc.b170.cbu.objects.requpdatebc.v2.BusinessCommunicationType bcUpdate
    ) {
        Optional<XMLGregorianCalendar> xmlDate
                = resolve(() -> bcUpdate.getStatus().getValidFor().getStartTimeStamp().getValue());
        if (xmlDate.isPresent()) {
            return xmlDate.get().toGregorianCalendar().getTime();
        } else {
            return new Date();
        }
    }


}
