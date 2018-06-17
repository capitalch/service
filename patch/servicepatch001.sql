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

ALTER TABLE serv_main
ALTER profit SET COMPUTE (amount-(cost_amount+transport+card_charges+job_work+cst+sales_tax+service_tax+surcharge+vat+tot+cgst+sgst+igst))
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