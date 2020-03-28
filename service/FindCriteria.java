package com.proximus.cds.provider.service;

import java.util.Date;
import java.util.Optional;

/**
 * Created by id815622 on 29/11/2017.
 * TODO abdul : move this class, and also uuid, to the DataRequestScope bean.
 */
public class FindCriteria {
    private Long customerId;
    private String customerCtx;
    private Date startDate;
    private Date endDate;
    private String requestId;
    private String requestCtx;

    public FindCriteria() {
    }

    public FindCriteria(
            Optional<Long> customerId,
            Optional<String> customerCtx,
            Optional<Date> startDate,
            Optional<Date> endDate,
            Optional<String> requestId,
            Optional<String> requestCtx) {
        this.customerId = customerId.orElse(null);
        this.customerCtx = customerCtx.orElse(null);
        this.startDate = startDate.orElse(null);
        this.endDate = endDate.orElse(null);
        this.requestId = requestId.orElse(null);
        this.requestCtx = requestCtx.orElse(null);
    }

    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    public String getCustomerCtx() {
        return customerCtx;
    }

    public void setCustomerCtx(String customerCtx) {
        this.customerCtx = customerCtx;
    }

    public String getRequestCtx() {
        return requestCtx;
    }

    public void setRequestCtx(String requestCtx) {
        this.requestCtx = requestCtx;
    }
}
