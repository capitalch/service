ALTER PROCEDURE "DBA"."remoteinsert"( @rec_no char(30),@rec_amt numeric(12,2),@srec_date char(10),@rectype char(1),@job_no char(10),@ptype char(1)
    , @cgst numeric(12,2), @sgst numeric(12,2), @igst numeric(12,2), @isAdvance char(1), @other_info varchar(40), @gstin varchar(20) ) 
begin
--GST applicable in India w.e.f 1st July 2017
--Taken care of GST rates 18% and 28%
  declare @date date;
  declare @gst18 varchar(15);
  declare @gst28 varchar(15);
  declare @acc_id unsigned integer;
  declare @acc_id_cash unsigned integer;
  set @date = "date"(@srec_date);
  if func_isvaliddate(@date) = 'N' then
    raiserror 17095 'Invalid date';
    return
  end if;
  if @rectype = 'Y' then
    set @rectype = 'S'
  else set @rectype = 'R'
  end if;
  select acc_id into @acc_id from acc_main where acc_code = 'custadvance' and acc_root = 'Y';
  select default_cash_id into @acc_id_cash from acc_setup;
  if @ptype = 'I' then //insert
    select acc_id into @gst18 from acc_main where acc_code = 'SaleGST18%';
    --select acc_id into @gst28 from acc_main where acc_code = 'SaleGST28%';
    if @gst18 is not null then
        if @isAdvance = 'y' then
            insert into cash_receipt (acc_id, acc_id_cash, rec_date,ref_no, remarks)
                values (@acc_id, @acc_id_cash, @date, @rec_no, 'Job No:'+@job_no+ 'Advance receipt from service+' );
        else
            insert into bill_memo( type,bill_memo,ref_no,"date",sale_tax_sale_id,
              total_amt,acc_id,descr,mpreserve, cgst, sgst, igst, gstin ) 
              values( @rectype,'M',@rec_no,@date,@gst18,@rec_amt,(select default_cash_id
                from acc_setup),'Job No:'+@job_no+' Parent invoice:' + trim(@other_info),'N', @cgst, @sgst, @igst, @gstin );
        end if;
    end if;
//    if @gst28 is not null then
//        insert into bill_memo( type,bill_memo,ref_no,"date",sale_tax_sale_id,
//          total_amt,acc_id,descr,mpreserve ) 
//          values( @rectype,'M',@rec_no + 'A',@date,@gst28,0,(select default_cash_id
//            from acc_setup),'Job No:'+@job_no+'From Service+ package','N' ) 
//    end if
    
  else
    if @isAdvance = 'y' then
        delete from bill_memo where ref_no = @rec_no;
    else
        delete from bill_memo where ref_no = @rec_no;
    end if
  end if
end
go
