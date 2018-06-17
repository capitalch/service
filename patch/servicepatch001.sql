if not exists(select column_name from syscolumn key join systable where 
    table_name =  'serv_main' and column_name = 'cgst') then
    alter table serv_main add cgst numeric(12,2) not null default 0
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'serv_main' and column_name = 'sgst') then
    alter table serv_main add sgst numeric(12,2) not null default 0
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'serv_main' and column_name = 'igst') then
    alter table serv_main add igst numeric(12,2) not null default 0
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'serv_main' and column_name = 'other_info') then
    alter table serv_main add other_info varchar(40) null
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'service_status' and column_name = 'cgst') then
    alter table service_status add cgst numeric(5,2) null
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'service_status' and column_name = 'sgst') then
    alter table service_status add sgst numeric(5,2) null
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'service_status' and column_name = 'igst') then
    alter table service_status add igst numeric(5,2) null
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'service_status' and column_name = 'gstin') then
    alter table service_status add gstin varchar(20) null
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'serv_main_part_details' and column_name = 'cgst') then
    alter table serv_main_part_details add cgst numeric(5,2) not null default 0
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'serv_main_part_details' and column_name = 'sgst') then
    alter table serv_main_part_details add sgst numeric(5,2) not null default 0
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'serv_main_part_details' and column_name = 'igst') then
    alter table serv_main_part_details add igst numeric(5,2) not null default 0
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'serv_cust_details' and column_name = 'gstin') then
    alter table serv_cust_details add gstin varchar(20) null
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'service_status' and column_name = 'cgst') then
    alter table service_status add cgst numeric(5,2) not null default 0
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'service_status' and column_name = 'sgst') then
    alter table service_status add sgst numeric(5,2) not null default 0
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'service_status' and column_name = 'igst') then
    alter table service_status add igst numeric(5,2) not null default 0
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'service_status' and column_name = 'gstin') then
    alter table service_status add gstin varchar(20) null
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'service_status' and column_name = 'website') then
    alter table service_status add website varchar(30) null
end if
go


ALTER TABLE serv_main
ALTER profit SET COMPUTE (amount-(cost_amount+transport+card_charges+job_work+cst+sales_tax+service_tax+surcharge+vat+tot+discount+gst+cgst+sgst+igst))
go

ALTER TABLE serv_main
ALTER amount SET COMPUTE (sale_amount
+serv_charge+sales_tax+service_tax+cst+surcharge+other_charges
+roundoff+card_charges+transport+handling+estimate+vat+tot
+job_work+gst-discount + cgst + sgst + igst);
go

ALTER TRIGGER "delete_serv_main_part_details" before delete order 2 on
DBA.serv_main_part_details
referencing old as old_name
for each row
begin
  declare @rec_type char(10);
  declare @claim_amt decimal(12,2);
  declare @status_id unsigned integer;
  select rec_type,status_id into @rec_type,
    @status_id from serv_main key join rec_master where job_id = old_name.job_id;
  if @status_id in(9,10,11) then //if set already delivered, entry not allowed
    raiserror 17089 'error';
    return
  end if;
  update serv_main set cost_amount = cost_amount-
    (old_name.cost_price*old_name.qty),sale_amount
     = sale_amount-(old_name.sale_price*old_name.qty),sales_tax
     = sales_tax-(old_name.sale_price*old_name.qty*old_name.sales_tax/100),
    cst = cst-(old_name.sale_price*old_name.qty*old_name.cst/100) 
    , cgst = cgst - (old_name.sale_price*old_name.qty*old_name.cgst/100)
    , sgst = sgst - (old_name.sale_price*old_name.qty*old_name.sgst/100)
    , igst = igst - (old_name.sale_price*old_name.qty*old_name.igst/100)
    where
    serv_main.job_id = old_name.job_id
end
go

ALTER TRIGGER "insert_serv_main_part_details" before insert order 1 on
DBA.serv_main_part_details
referencing new as new_name
for each row
begin
  declare @status_id unsigned integer;
  declare @rec_type char(10);
  select status_id,rec_type into @status_id,
    @rec_type from serv_main key join rec_master where
    job_id = new_name.job_id;
  if @status_id in(9,10,11) then //if set already delivered, entry not allowed
    raiserror 17089 'error';
    return
  end if;
  if new_name.sales_tax is null then set new_name.sales_tax=0
  end if;
  if new_name.cst is null then set new_name.cst=0
  end if;
  if new_name.cost_price is null then //or new_name.cost_price = 0 then
    set new_name.cost_price=0
  end if;
  update serv_main set cost_amount = cost_amount+
    (new_name.cost_price*new_name.qty),sale_amount
     = sale_amount+(new_name.sale_price*new_name.qty),sales_tax
     = sales_tax+(new_name.sale_price*new_name.qty*new_name.sales_tax/100),
    cst = cst+(new_name.sale_price*new_name.qty*new_name.cst/100) 
    , cgst = cgst+(new_name.sale_price*new_name.qty*new_name.cgst/100)
    , sgst = sgst+(new_name.sale_price*new_name.qty*new_name.sgst/100)
    , igst = igst+(new_name.sale_price*new_name.qty*new_name.igst/100)
where
    serv_main.job_id = new_name.job_id
end
go

ALTER TRIGGER "update_serv_main_part_details" before update order 3 on
DBA.serv_main_part_details
referencing old as old_name new as new_name
for each row
begin
  declare @rec_type_old char(10);
  declare @rec_type_new char(10);
  declare @status_id unsigned integer;
  select rec_type,status_id into @rec_type_old,
    @status_id from serv_main key join rec_master where
    job_id = old_name.job_id;
  select rec_type into @rec_type_new from serv_main key join
    rec_master where job_id = new_name.job_id;
  if new_name.cost_price is null then
    set new_name.cost_price=0
  end if;
  if @status_id in(9,10,11) then //if set already delivered, entry not allowed
    raiserror 17089 'error';
    return
  end if;
  update serv_main set cost_amount = cost_amount+
    (new_name.cost_price*new_name.qty)-(old_name.cost_price*old_name.qty),
    sale_amount = sale_amount+(new_name.sale_price*new_name.qty)-
    (old_name.sale_price*old_name.qty),sales_tax
     = sales_tax+(new_name.sale_price*new_name.qty*new_name.sales_tax/100)-
    (old_name.sale_price*old_name.qty*old_name.sales_tax/100),
    cst = cst+(new_name.sale_price*new_name.qty*new_name.cst/100)-
    (old_name.sale_price*old_name.qty*old_name.cst/100) 
    , cgst = cgst+(new_name.sale_price*new_name.qty*new_name.cgst/100)-
            (old_name.sale_price*old_name.qty*old_name.cgst/100)
    , sgst = sgst+(new_name.sale_price*new_name.qty*new_name.sgst/100)-
            (old_name.sale_price*old_name.qty*old_name.sgst/100)
    , igst = igst+(new_name.sale_price*new_name.qty*new_name.igst/100)-
            (old_name.sale_price*old_name.qty*old_name.igst/100)

where
    serv_main.job_id = new_name.job_id
end
go

ALTER PROCEDURE "DBA"."proc_insertrow_partdetails"(in @partname char(20),in @partcode char(20),in @costprice real,in @saleprice real,in @qty integer,in @jobno char(15),
in @mode char(1),in @database char(20),in @sales_tax real,in @cst real, in @cgst real, in @sgst real, in @igst real)
begin
  declare @jobid unsigned integer;
  declare @oldqty integer;
  declare @row integer;
  declare @fvalue decimal(10,2);
  declare @lvalue decimal(10,2);
  set @jobno=trim(@jobno);
  select job_id into @jobid from serv_main where job_no = @jobno;
  if @jobid is null then
    raiserror 17003;
    return
  end if;
  select qty into @oldqty from serv_main_part_details where
    job_id = @jobid and part_code = @partcode;
  set @row=@@rowcount;
  if @mode = 'I' then
    -- Insert mode
    --for currency conversion
    select value into @fvalue from currency_table key join
      company_database_table where database_name = @database;
    if @@rowcount = 0 then
      raiserror 17004 'error';
      return
    end if;
    select value into @lvalue from currency_table join service_status on
      service_status.currency_id = currency_table.currency_id;
    if @@rowcount = 0 then
      raiserror 17004 'error'
    end if;
    set @costprice=@costprice*@lvalue/@fvalue*1.0;
    set @saleprice="truncate"(@saleprice*@lvalue/@fvalue+10.0,-1.0);
    if @row = 0 then
      insert into serv_main_part_details(part_name,part_code,cost_price,
        sale_price,qty,job_id,sales_tax,cst,cgst,sgst,igst) values(@partname,@partcode,@costprice,
        @saleprice,@qty,@jobid,@sales_tax,@cst,@cgst,@sgst,@igst)
    else
      update serv_main_part_details set
        qty = qty+@qty where job_id = @jobid and part_code = @partcode
    end if
  else
    if @mode = 'D' then --delete mode
      if @row > 0 then
        if @oldqty > @qty then
          update serv_main_part_details set
            qty = qty-@qty where job_id = @jobid and part_code = @partcode
        else
          delete from serv_main_part_details where job_id = @jobid and part_code = @partcode
        end if
      end if
    end if
  end if end
go

ALTER PROCEDURE "DBA"."sp_insert_receiving_pb"(@job_date timestamp,@job_id unsigned integer,@sl_no char(40),@serv_charge numeric(10,2),@purchase_date date,@opening char(2),@rec_condition varchar(40),@remarks varchar(40),@rec_id unsigned integer,@defect_id unsigned integer,@rec_amt decimal(12,2),@rec_no unsigned integer,@item char(10),@company char(20),@model char(20),@addr1 varchar(70),@addr2 varchar(70),@city char(15),@email char(30),@fax char(15),@name varchar(60),@phone char(30),@pin char(10),@state char(2),@status_id unsigned integer,@accessory varchar(60),@complaint varchar(150),@phone_office varchar(30),@mobile varchar(15),@prev_job_no char(10),@local char(1),@job_no char(10)
,@imei numeric(20,0), @gstin varchar(20))
begin
  declare @product_id unsigned integer;
  declare @error integer;
  declare @cust_id unsigned integer;
  //declare @job_no_numeric decimal(10);
  declare @job_no_prefix char(3);
  if trim(@prev_job_no) <> '' and @prev_job_no is not null then
    if not exists(select job_no from serv_main where job_no = @prev_job_no) then
      raiserror 17091 'Error in previous job';
      return
    end if
  end if;
  //register product
  select product_id into @product_id from serv_product_table key join
    item_master key join company_master where item = @item and
    company = @company and model = @model;
  if @product_id is null then
    insert into serv_product_table(item_id,company_id,model,sync_key) values(
      (select item_id from item_master where item = @item),
      (select company_id from company_master where company = @company),
      @model,'I');
    select @@identity,@@error into @product_id,@error from dummy;
    if @error <> 0 then
      raiserror 17018 'error';
      return
    end if
  end if;
  //register customer
/*
  select cust_id,name,addr1,addr2,phone,email,mobile into #temp from serv_cust_details where
    name = @name;
  if @@rowcount <> 0 then //records with same name
    if @addr1 is null and @addr2 is null and @phone is null and @email is null and @mobile is null then
      select max(cust_id) into @cust_id from #temp where @addr1 is null and @addr2 is null and @phone is null and @email is null and @mobile is null
    elseif @mobile is not null then
      select max(cust_id) into @cust_id from #temp where mobile = @mobile
    elseif @email is not null then
      select max(cust_id) into @cust_id from #temp where email = @email
    elseif @phone is not null then
      select max(cust_id) into @cust_id from #temp where phone = @phone
    elseif @addr1 is not null then
      select max(cust_id) into @cust_id from #temp where addr1 = @addr1
    elseif @addr2 is not null then
      select max(cust_id) into @cust_id from #temp where addr2 = @addr2
    end if
  end if;
*/
//  if @cust_id is null then
    insert into serv_cust_details(addr1,addr2,city,email,fax,name,phone,pin,state,sync_key,
      phone_office,mobile, gstin) values(
      @addr1,@addr2,@city,@email,@fax,@name,@phone,@pin,@state,'I',@phone_office,@mobile, @gstin);
    select @@identity,@@error into @cust_id,@error from dummy;
    if @error <> 0 then
      raiserror 17019 'error';
      return
    end if;
//  end if;
  //insert in serv_main
  if @job_no is null or trim(@job_no) = '' then
    select func_getnewjobno(*) into @job_no from dummy;
    if @@error <> 0 then
      raiserror 17020 'error';
      return
    end if
  end if;
  insert into serv_main(advance,purchase_date,cost_amount,
    cust_id,defect_id,discount,job_date,job_no,last_tran_id,opening,
    other_charges,product_id,rec_condition,rec_id,remarks,
    sale_amount,serv_charge,sl_no,status_id,sync_key,final,
    accessory,complaint,junk,sales_tax,cst,surcharge,roundoff,card_charges,
    transport,handling,estimate,vat,tot,service_tax,job_work,gst,prev_job_no,local,imei) values(
    0,@purchase_date,0,@cust_id,@defect_id,0,@job_date,@job_no,0,@opening,0,
    @product_id,@rec_condition,@rec_id,@remarks,0,@serv_charge,@sl_no,1,'I','N',
    @accessory,@complaint,'N',0,0,0,0,0,0,0,0,0,0,0,0,0,@prev_job_no,@local,@imei);
  select @@identity,@@error into @job_id,@error from dummy;
  if @error <> 0 then
    raiserror 17021 'error';
    return
  end if;
  //advance
  if @rec_amt is not null and @rec_amt > 0 then
    insert into serv_main_receipt(job_id,rec_amt,rec_date,rec_no,rectype) values(
      @job_id,@rec_amt,@job_date,@rec_no,'Y');
    if @error <> 0 then
      raiserror 17022 'error';
      return
    end if
  end if
end
go

ALTER PROCEDURE "DBA"."sp_update_receiving_pb"(@job_date timestamp,@job_id unsigned integer,@job_no char(10),@sl_no char(40),@serv_charge numeric(10,2)
,@purchase_date date,@cust_id unsigned integer,@opening char(2),@rec_condition varchar(40),@remarks varchar(40),@rec_id unsigned integer
,@defect_id unsigned integer,@rec_amt decimal(12,2),@rec_no unsigned integer,@item char(10),@company char(20),@model char(20)
,@addr1 varchar(70),@addr2 varchar(70),@city char(15),@email char(30),@fax char(15),@name varchar(60),@phone char(30),@pin char(10)
,@state char(2),@status_id unsigned integer,@accessory varchar(60),@complaint varchar(150),@phone_office varchar(30),@mobile varchar(15)
,@prev_job_no char(10),@local char(1),@imei numeric(20,0), @gstin varchar(20))
begin
  declare @product_id unsigned integer;
  declare @error integer;
  if trim(@prev_job_no) <> '' and @prev_job_no is not null then
    if not exists(select job_no from serv_main where job_no = @prev_job_no) then
      raiserror 17091 'Error in previous job';
      return
    end if
  end if;
  //register product
  select product_id into @product_id from serv_product_table key join
    item_master key join company_master where item = @item and
    company = @company and model = @model;
  if @product_id is null then
    insert into serv_product_table(item_id,company_id,model,sync_key) values(
      (select item_id from item_master where item = @item),
      (select company_id from company_master where company = @company),
      @model,'I');
    select @@identity,@@error into @product_id,@error from dummy;
    if @@error <> 0 then
      raiserror 17018 'error';
      return
    end if
  end if;
  //register customer
  if @cust_id is not null then
    update serv_cust_details set addr1 = @addr1,addr2 = @addr2,city = @city,
      email = @email,fax = @fax,name = @name,phone = @phone,pin = @pin,
      state = @state,sync_key = 'I',phone_office = @phone_office,mobile = @mobile, gstin = @gstin where
      cust_id = @cust_id;
    if @@error <> 0 then
      raiserror 17028 'error';
      return
    end if
  end if;
  //update in serv_main
  update serv_main set purchase_date = @purchase_date,defect_id
     = @defect_id,job_date = @job_date,job_no = @job_no,
    product_id = @product_id,rec_condition = @rec_condition,
    rec_id = @rec_id,serv_charge = @serv_charge,remarks = @remarks,
    accessory = @accessory,sl_no = @sl_no,
    sync_key = 'I',complaint = @complaint,prev_job_no = @prev_job_no,local = @local, imei = @imei where
    job_id = @job_id;
  if @@error <> 0 then
    raiserror 17029 'Error';
    return
  end if
end