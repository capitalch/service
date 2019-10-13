ALTER PROCEDURE "DBA"."remoteinsert"( @rec_no char(30) default '', @rec_amt real default 0
,@srec_date char(10) default '',@rectype char(1) default 'Y',@job_no char(10) default '',@ptype char(1) default 'I',@cgst real default 0, @sgst real default 0, @igst real default 0, @isAdvance char(1) default 'n'
, @other_info char(40) default ''
, @gstin char(20) default null
)

begin
--GST applicable in India w.e.f 1st July 2017
--Taken care of GST rates 18% and 28%
  declare @date date;
  declare @gst18 unsigned integer;

  set @date = "date"(@srec_date);

  if func_isvaliddate(@date) = 'N' then
    raiserror 17095 'Invalid date';
    return
  end if;
  if @rectype = 'Y' then
    set @rectype = 'S'
  else set @rectype = 'R'
  end if;

  if @ptype = 'I' then //insert
    select acc_id into @gst18 from acc_main where acc_code = 'SaleGST18%';
    if @gst18 is not null then
        insert into bill_memo( type,bill_memo,ref_no,"date",sale_tax_sale_id,
          total_amt,acc_id,descr,mpreserve, cgst, sgst, igst, gstin ) 
          values( @rectype,'M',@rec_no,@date,@gst18,@rec_amt,(select default_cash_id
            from acc_setup),'Job No:'+@job_no + ':Invoice:' + rtrim(@other_info),'N', @cgst, @sgst, @igst, @gstin );
    end if;
    
  else
    delete from bill_memo where ref_no = @rec_no
  end if
end