onePart=tab.trlTA.participant==18;

onePart_table=tab.trlTA(onePart,:);


responses=onePart_table.responseValue;

resp_ts=responses;
resp_ts(responses==225)=0;
resp_ts(responses==232)=1;
resp_ts(isnan(resp_ts))=[];


sum(isnan(resp_ts))
