package com.proximus.cds.provider.service;

import bc.b170.cbu.objects.reqcreatebc.v2.CodeValueType;
import com.proximus.cds.model.History;
import org.springframework.stereotype.Component;

import java.util.Objects;

import static com.proximus.cds.hotline.service.CsvConstants.CREATED_FOR;

@Component
public class RecontextService {

    public void resetCustomerId(final bc.b170.cbu.objects.reqcreatebc.v2.BusinessCommunicationType bcCreate, final History history) {
        if (bcCreate == null || history == null || history.getCustomerId() == null) {
            return;
        }
        bcCreate.getRoles().stream()
                .filter(Objects::nonNull)
                .filter(role -> role.getType() != null)
                .filter(role -> CREATED_FOR.equalsIgnoreCase(role.getType().getValue()))
                .map(role -> role.getPartyRoleIdentifier())
                .filter(Objects::nonNull)
                .map(x -> x.getCustomerIdentifier())
                .filter(Objects::nonNull)
                .forEach(x ->
                        {
                            x.setId(history.getCustomerId());
                            CodeValueType idContext = x.getIdContext();
                            if (idContext == null) {
                                idContext = new CodeValueType();
                                x.setIdContext(idContext);
                            }
                            idContext.setValue(history.getCustomerCtx());
                            CodeValueType idScope = x.getIdScope();
                            if (idScope == null) {
                                idScope = new CodeValueType();
                                x.setIdScope(idScope);
                            }
                            idScope.setValue(history.getCustomerScope());
                        }
                );
    }

}
