if not exists(select column_name from syscolumn key join systable where 
    table_name =  'inv_status' and column_name = 'cgst') then
    alter table inv_status add cgst numeric(5,2) not null default 0
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'inv_status' and column_name = 'sgst') then
    alter table inv_status add sgst numeric(5,2) not null default 0
end if
go

if not exists(select column_name from syscolumn key join systable where 
    table_name =  'inv_status' and column_name = 'igst') then
    alter table inv_status add igst numeric(5,2) not null default 0
end if
go


ALTER TRIGGER "insert_inv_use_details" before insert order 1 on
DBA.inv_use_details
referencing new as new_name
for each row
begin
  declare @partcode char(20);
  declare @name varchar(20);
  declare @costprice real;
  declare @saleprice real;
  declare @database char(20);
  declare @costratio real;
  declare @qty integer;
  declare @job_pending integer;declare @lret integer;
  declare @sales_tax real;
  declare @cst real;
  declare @cgst real;
  declare @sgst real;
  declare @igst real;
  declare @service_profit real;
  declare @part_id unsigned integer;
  if new_name.job_no is null then
    raiserror 17072 'Error in job no';
    return
  else
    if not exists(select job_no from serv_main where
        job_no = new_name.job_no) then
      raiserror 17072 'Error in job No';
      return
    end if
  end if;
  select part_id,qty into @part_id,@qty from job_details where job_no = new_name.job_no and
    part_id = new_name.part_id;
  if @part_id is not null then
    if @qty <= new_name.qty then
      delete from job_details where job_no = new_name.job_no and part_id = new_name.part_id
    else //@qty > new_name.qty
      update job_details set qty = qty-new_name.qty where job_no = new_name.job_no and part_id = new_name.part_id
    end if
  end if;
  select func_insertinvmain(new_name.part_id) into @lret from dummy;
  //update inv_main
  update inv_main set cr = cr+new_name.qty where part_id = new_name.part_id;
  select part_code,name,if i.price_code is null then price else cp endif,
    if i.price_code is null then 0 else sp endif into @partcode,@name,@costprice,
    @saleprice from inv_master as i left outer join pricecode where
    part_id = new_name.part_id;
  if @@rowcount = 0 then
    raiserror 17040 'Part Id not found';
    return
  end if;
  select db_property('alias') into @database;
  select cost_ratio,sales_tax,cst,cgst,sgst,igst into @costratio,@sales_tax,
    @cst,@cgst,@sgst,@igst from inv_status;
  if @sales_tax is null then set @sales_tax = 0
  end if;
  if @cst is null then set @cst=0
  end if;
  if @cgst is null then set @cgst = 0
  end if;
  if @sgst is null then set @sgst = 0
  end if;
  if @igst is null then set @igst = 0
  end if;
  select profit into @service_profit from cust_group where group_name = 'SERVICE';
  if @service_profit is null or @service_profit = 0.0 then set
      @service_profit=20.0
  end if;
  set @costprice=@costprice*@costratio+0.0;
  if @saleprice = 0 or @saleprice is null then
    set @saleprice=@costprice*(1+@service_profit/100)
  else
    set @saleprice=@saleprice*@costratio+0.0
  end if;
  call remote_insertrow(@name,@partcode,@costprice,@saleprice,new_name.qty,
  new_name.job_no,'I',@database,@sales_tax,@cst,@cgst,@sgst,@igst) // for insert 
end
go

ALTER TRIGGER "delete_inv_use_details" before delete order 1 on
DBA.inv_use_details
referencing old as old_name
for each row
begin
  declare @partcode char(20);
  declare @name varchar(20);
  declare @costprice numeric(10,2);
  declare @saleprice numeric(10,2);
  declare @database char(20);
  declare @qty integer;
  declare @part_id unsigned integer;
  //delete from inv_tran where old_name.details_id = inv_tran.doc_id and inv_tran.tran_type = 'USE';
  select part_code into @partcode from inv_master where
    part_id = old_name.part_id;
  if @@rowcount = 0 then
    raiserror 17040 'Part Id not found in Inv_master table';
    return
  end if;
  select part_id,qty into @part_id,@qty from job_details where job_no = 
    old_name.job_no and part_id = old_name.part_id;
  if @part_id is not null then
    update job_details set qty = qty+old_name.qty where job_no = old_name.job_no and
      part_id = old_name.part_id
  end if;
  update inv_main set cr = cr-old_name.qty where part_id = old_name.part_id;
  call remote_insertrow(@name,@partcode,@costprice,@saleprice,old_name.qty,
  old_name.job_no,'D',@database,0,0,0,0,0) // for Delete
end
go

ALTER TRIGGER "update_inv_use_details" before update order 1 on
DBA.inv_use_details
referencing old as old_name new as new_name
for each row
begin
  declare @partcode char(20);
  declare @name varchar(20);
  declare @costprice real;
  declare @saleprice real;
  declare @database char(20);
  declare @sales_tax real;
  declare @cst real;
  declare @cgst real;
  declare @sgst real;
  declare @igst real;
  declare @service_profit real;
  declare @costratio real;declare @lret integer;
  declare @part_id unsigned integer;
  declare @qty integer;
  set @costprice=0.0;
  set @saleprice=0.0;
  set @costratio=0.0;
  if new_name.job_no is null then
    raiserror 17072 'Error in job no';
    return
  else
    if new_name.job_no <> old_name.job_no then
      if not exists(select job_no from serv_main where
          job_no = new_name.job_no) then
        raiserror 17072 'Error in job No';
        return
      end if
    end if
  end if;
  //delete effect for job_details table
  select part_id,qty into @part_id,@qty from job_details where job_no = 
    old_name.job_no and part_id = old_name.part_id;
  if @part_id is not null then
    update job_details set qty = qty+old_name.qty where job_no = old_name.job_no and
      part_id = old_name.part_id
  end if;
  //insert effect for job_details table
  select part_id,qty into @part_id,@qty from job_details where job_no = new_name.job_no and
    part_id = new_name.part_id;
  if @part_id is not null then
    if @qty <= new_name.qty then
      delete from job_details where job_no = new_name.job_no and part_id = new_name.part_id
    else //@qty > new_name.qty
      update job_details set qty = qty-new_name.qty where job_no = new_name.job_no and part_id = new_name.part_id
    end if
  end if;
  update inv_main set cr = cr+new_name.qty where part_id = new_name.part_id;
  update inv_main set cr = cr-old_name.qty where part_id = old_name.part_id;
  //First delete then insert effect for part code update in service database
  select part_code,name,if i.price_code is null then price else cp endif,
    if i.price_code is null then 0 else sp endif into @partcode,@name,@costprice,
    @saleprice from inv_master as i left outer join pricecode where
    part_id = old_name.part_id;
  if @partcode is null then
    raiserror 17040 'Part Id not found';
    return
  end if;
  //For delete old part code
  call remote_insertrow(@name,@partcode,@costprice,@saleprice,old_name.qty,
  old_name.job_no,'D',@database,0,0); // for Delete
  select part_code,name,if i.price_code is null then price else cp endif,
    if i.price_code is null then price else sp endif into @partcode,@name,@costprice,
    @saleprice from inv_master as i left outer join pricecode where
    part_id = new_name.part_id;
  select db_property('alias') into @database;
  select cost_ratio,sales_tax,cst, cgst,sgst,igst into @costratio,@sales_tax,
    @cst, @cgst, @sgst, @igst from inv_status;
  select profit into @service_profit from cust_group where group_name = 'SERVICE';
  if @service_profit is null or @service_profit = 0 then set
      @service_profit=20.0
  end if;
  set @costprice=@costprice*@costratio+0.0;
  if @saleprice = 0 or @saleprice is null then
    set @saleprice=@costprice*(1+@service_profit/100)
  else
    set @saleprice=@saleprice*@costratio+0.0
  end if;
  call remote_insertrow(@name,@partcode,@costprice,@saleprice,new_name.qty,
  new_name.job_no,'I',@database,@sales_tax,@cst,@cgst,@sgst,@igst) // for insert 
end
go

ALTER PROCEDURE "DBA"."remote_insertrow"( in @partname char(20),in @partcode char(20),in @costprice real,
    in @saleprice real,in @qty integer,in @jobno char(15),in @mode char(1),in @database char(20),in @sales_tax real,in @cst real, in @cgst real, in @sgst real, in @igst real ) 
at 'service..dba.proc_insertrow_partdetails'
go



