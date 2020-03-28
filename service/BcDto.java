package com.proximus.cds.provider.service;

import bc.b170.cbu.objects.reqcreatebc.v2.BusinessCommunicationType;
import bc.b170.cbu.services.bc.v2.ReferenceObjectsCreateRequestType;
import bc.b170.cbu.services.bc.v2.ReferenceObjectsUpdateRequestType;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by id815622 on 23/11/2017.
 */
public class BcDto {

    private Date startDate;
    private bc.b170.cbu.objects.reqcreatebc.v2.BusinessCommunicationType bcCreate;
    private List<bc.b170.cbu.objects.requpdatebc.v2.BusinessCommunicationType> bcUpdateList = new ArrayList<>();
    private ReferenceObjectsCreateRequestType roCreate = new ReferenceObjectsCreateRequestType();
    private List<ReferenceObjectsUpdateRequestType> roUpdateList = new ArrayList<>();

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public ReferenceObjectsCreateRequestType getRoCreate() {
        return roCreate;
    }

    public void setRoCreate(ReferenceObjectsCreateRequestType roCreate) {
        this.roCreate = roCreate;
    }

    public List<ReferenceObjectsUpdateRequestType> getRoUpdateList() {
        return roUpdateList;
    }

    public bc.b170.cbu.objects.reqcreatebc.v2.BusinessCommunicationType getBcCreate() {
        return bcCreate;
    }

    public void setBcCreate(BusinessCommunicationType bcCreate) {
        this.bcCreate = bcCreate;
    }

    public List<bc.b170.cbu.objects.requpdatebc.v2.BusinessCommunicationType> getBcUpdateList() {
        return bcUpdateList;
    }
}
