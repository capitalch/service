$PBExportHeader$w_sheet_sony_isis_modify.srw
forward
global type w_sheet_sony_isis_modify from w_sheet_sony
end type
type dw_1 from u_dw_linkage within w_sheet_sony_isis_modify
end type
type sle_1 from u_sle within w_sheet_sony_isis_modify
end type
type st_3 from statictext within w_sheet_sony_isis_modify
end type
type cb_1 from u_cb within w_sheet_sony_isis_modify
end type
type cb_2 from u_cb within w_sheet_sony_isis_modify
end type
type cb_3 from u_cb within w_sheet_sony_isis_modify
end type
type rb_1 from u_rb within w_sheet_sony_isis_modify
end type
type rb_2 from u_rb within w_sheet_sony_isis_modify
end type
type rb_3 from u_rb within w_sheet_sony_isis_modify
end type
type em_1 from u_em within w_sheet_sony_isis_modify
end type
type em_2 from u_em within w_sheet_sony_isis_modify
end type
type st_2 from statictext within w_sheet_sony_isis_modify
end type
end forward

global type w_sheet_sony_isis_modify from w_sheet_sony
integer x = 214
integer y = 221
integer width = 3374
integer height = 1844
windowstate windowstate = normal!
long backcolor = 15793151
dw_1 dw_1
sle_1 sle_1
st_3 st_3
cb_1 cb_1
cb_2 cb_2
cb_3 cb_3
rb_1 rb_1
rb_2 rb_2
rb_3 rb_3
em_1 em_1
em_2 em_2
st_2 st_2
end type
global w_sheet_sony_isis_modify w_sheet_sony_isis_modify

type variables
datawindowchild ldw
end variables

forward prototypes
public subroutine wf_populatesymptom ()
end prototypes

public subroutine wf_populatesymptom ();string catg_code, feature_code
long lrow
lrow = dw_1.getrow()
if lrow = 0 then return
catg_code = dw_1.object.catg_code[lrow]
feature_code = dw_1.object.feature_code[lrow]
ldw.retrieve(catg_code,feature_code)
end subroutine
on w_sheet_sony_isis_modify.create
int iCurrent
call super::create
this.dw_1=create dw_1
this.sle_1=create sle_1
this.st_3=create st_3
this.cb_1=create cb_1
this.cb_2=create cb_2
this.cb_3=create cb_3
this.rb_1=create rb_1
this.rb_2=create rb_2
this.rb_3=create rb_3
this.em_1=create em_1
this.em_2=create em_2
this.st_2=create st_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
this.Control[iCurrent+2]=this.sle_1
this.Control[iCurrent+3]=this.st_3
this.Control[iCurrent+4]=this.cb_1
this.Control[iCurrent+5]=this.cb_2
this.Control[iCurrent+6]=this.cb_3
this.Control[iCurrent+7]=this.rb_1
this.Control[iCurrent+8]=this.rb_2
this.Control[iCurrent+9]=this.rb_3
this.Control[iCurrent+10]=this.em_1
this.Control[iCurrent+11]=this.em_2
this.Control[iCurrent+12]=this.st_2
end on

on w_sheet_sony_isis_modify.destroy
call super::destroy
destroy(this.dw_1)
destroy(this.sle_1)
destroy(this.st_3)
destroy(this.cb_1)
destroy(this.cb_2)
destroy(this.cb_3)
destroy(this.rb_1)
destroy(this.rb_2)
destroy(this.rb_3)
destroy(this.em_1)
destroy(this.em_2)
destroy(this.st_2)
end on

event open;call super::open;wf_center()
dw_1.settransobject(testsql)


end event
type cb_x from w_sheet_sony`cb_x within w_sheet_sony_isis_modify
integer x = 3205
integer textsize = -9
fontcharset fontcharset = ansi!
string facename = "Arial"
end type

type p_1 from w_sheet_sony`p_1 within w_sheet_sony_isis_modify
end type

type st_1 from w_sheet_sony`st_1 within w_sheet_sony_isis_modify
integer y = 16
long backcolor = 15793151
end type

type dw_1 from u_dw_linkage within w_sheet_sony_isis_modify
integer x = 5
integer y = 232
integer width = 2971
integer height = 1492
integer taborder = 11
boolean bringtotop = true
boolean titlebar = false
string dataobject = "d_sony_isis_modify"
boolean resizable = true
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;setrowfocusindicator(off!)
end event

event itemchanged;call super::itemchanged;string ls_name,catg_code,feature_code
ls_name = upper(dwo.name)
if row = 0 then return
catg_code = object.catg_code[row] 
feature_code = object.feature_code[row]
ldw.retrieve(catg_code,feature_code)
if ls_name = 'ISIS_CODE' then
	object.isis[row] = of_getchildstring('isis_code','descr')
	object.catg_code[row] = of_getchildstring('isis_code','catg_code')
	object.feature_code[row] = of_getchildstring('isis_code','feature_code')
	object.symptom_code[row] = of_getchildstring('isis_code','symptom_code')
	object.defect_code[row] = of_getchildstring('isis_code','com_cd')
	object.cond_code[row] = of_getchildstring('isis_code','cond_code')
	object.repair_cd[row] = of_getchildstring('isis_code','repair_cd')
	object.sec_code[row] = of_getchildstring('isis_code','sec_code')
	object.category[row] = of_getchildstring('isis_code','category')
	object.feature[row] = of_getchildstring('isis_code','feature')
	object.symptom[row] = of_getchildstring('isis_code','symptom')
	object.defect[row] = of_getchildstring('isis_code','defect')
	object.condition[row] = of_getchildstring('isis_code','condition')
	object.repair[row] = of_getchildstring('isis_code','repair')
	object.section[row] = of_getchildstring('isis_code','section')
	catg_code = object.catg_code[row] 
	feature_code = object.feature_code[row]
	ldw.retrieve(catg_code,feature_code)
elseif ls_name = 'ISIS' then
	object.isis_code[row] = of_getchildstring('isis','isis_code')
	object.catg_code[row] = of_getchildstring('isis_code','catg_code')
	object.feature_code[row] = of_getchildstring('isis_code','feature_code')
	object.symptom_code[row] = of_getchildstring('isis_code','symptom_code')
	object.defect_code[row] = of_getchildstring('isis_code','com_cd')
	object.cond_code[row] = of_getchildstring('isis_code','cond_code')
	object.repair_cd[row] = of_getchildstring('isis_code','repair_cd')
	object.sec_code[row] = of_getchildstring('isis_code','sec_code')
	object.category[row] = of_getchildstring('isis_code','category')
	object.feature[row] = of_getchildstring('isis_code','feature')
	object.symptom[row] = of_getchildstring('isis_code','symptom')
	object.defect[row] = of_getchildstring('isis_code','defect')
	object.condition[row] = of_getchildstring('isis_code','condition')
	object.repair[row] = of_getchildstring('isis_code','repair')
	object.section[row] = of_getchildstring('isis_code','section')
	catg_code = object.catg_code[row] 
	feature_code = object.feature_code[row]
	ldw.retrieve(catg_code,feature_code)
elseif ls_name = 'CATEGORY' then
	object.catg_code[row] = of_getchildstring('category','catg_code')
	catg_code = object.catg_code[row] 
	ldw.retrieve(catg_code,feature_code)
elseif ls_name = 'FEATURE' then
	object.feature_code[row] = of_getchildstring('feature','feature_code')
	feature_code = object.feature_code[row]
	ldw.retrieve(catg_code,feature_code)
elseif ls_name = 'SYMPTOM' then
	object.symptom_code[row] = of_getchildstring('symptom','symptom_code')
elseif ls_name = 'DEFECT' then
	object.defect_code[row] = of_getchildstring('defect','com_cd')
elseif ls_name = 'CONDITION' then
	object.condition_code[row] = of_getchildstring('condition','condition_code')
elseif ls_name = 'REPAIR' then
	object.repair_code[row] = of_getchildstring('repair','repair_cd')
elseif ls_name = 'SECTION' then
	object.sec_code[row] = of_getchildstring('section','sec_code')
end if
	
end event

event rowfocuschanged;call super::rowfocuschanged;wf_populatesymptom()
end event
type sle_1 from u_sle within w_sheet_sony_isis_modify
integer x = 2441
integer y = 104
integer width = 535
integer height = 88
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
string facename = "Arial"
long backcolor = 15793151
end type

type st_3 from statictext within w_sheet_sony_isis_modify
integer x = 265
integer y = 16
integer width = 389
integer height = 76
boolean bringtotop = true
integer textsize = -12
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16711680
long backcolor = 15793151
string text = "Isis Modify"
boolean focusrectangle = false
end type

type cb_1 from u_cb within w_sheet_sony_isis_modify
integer x = 3026
integer y = 232
integer width = 297
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
string facename = "Arial"
string text = "Retrieve"
end type

event clicked;call super::clicked;string job_no,status
dw_1.settransobject(testsql)
dw_1.event constructor()
dw_1.getchild('symptom',ldw)
ldw.settransobject(testsql)
ldw.insertrow(0)
if rb_1.checked then
	job_no = '%'
	status = 'js_delivered'
	dw_1.retrieve(job_no,status)
elseif rb_2.checked then
	job_no = trim(sle_1.text)
	if job_no ='' or isnull(job_no) then job_no = '%'
	status = '*'
	dw_1.retrieve(job_no,status)
elseif rb_3.checked then
	date sdate,edate
	em_1.getdata(sdate);em_2.getdata(edate)
	dw_1.retrieve(sdate,edate)
end if
//populates the symptom childdatawindow as per catg_code and feature_code
wf_populatesymptom()
end event
type cb_2 from u_cb within w_sheet_sony_isis_modify
integer x = 3026
integer y = 488
integer width = 297
integer height = 108
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
string facename = "Arial"
string text = "Save"
end type

event clicked;call super::clicked;dw_1.event ue_save()
end event

type cb_3 from u_cb within w_sheet_sony_isis_modify
integer x = 3026
integer y = 348
integer width = 297
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
string facename = "Arial"
string text = "Modify"
end type

event clicked;call super::clicked;dw_1.of_readonly(false)
end event

type rb_1 from u_rb within w_sheet_sony_isis_modify
integer x = 1911
integer y = 20
integer width = 485
boolean bringtotop = true
long backcolor = 15793151
string text = "Undelivered Jobs"
end type

event clicked;call super::clicked;sle_1.enabled = false
em_1.enabled = false
em_2.enabled = false
dw_1.dataobject = 'd_sony_isis_modify'

end event

type rb_2 from u_rb within w_sheet_sony_isis_modify
integer x = 2441
integer y = 20
integer width = 347
boolean bringtotop = true
long backcolor = 15793151
string text = "Specific job"
boolean checked = true
end type

event clicked;call super::clicked;sle_1.enabled = true
em_1.enabled = false
em_2.enabled = false
dw_1.dataobject = 'd_sony_isis_modify'

end event

type rb_3 from u_rb within w_sheet_sony_isis_modify
integer x = 1367
integer y = 20
integer width = 512
boolean bringtotop = true
integer textsize = -9
fontcharset fontcharset = ansi!
string facename = "Arial"
long backcolor = 15793151
string text = "Completed jobs"
end type

event clicked;call super::clicked;sle_1.enabled = false
em_1.enabled = true
em_2.enabled = true
dw_1.dataobject = 'd_sony_isis_modify_completed'

end event

type em_1 from u_em within w_sheet_sony_isis_modify
integer x = 1367
integer y = 108
integer width = 398
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
fontcharset fontcharset = ansi!
string facename = "Arial"
long backcolor = 15793151
maskdatatype maskdatatype = datemask!
string mask = "dd/mm/yyyy"
boolean spin = true
end type

event constructor;call super::constructor;text = string(today(),'yyyy-mm-dd')
end event

type em_2 from u_em within w_sheet_sony_isis_modify
integer x = 1874
integer y = 108
integer width = 402
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
fontcharset fontcharset = ansi!
string facename = "Arial"
long backcolor = 15793151
maskdatatype maskdatatype = datemask!
string mask = "dd/mm/yyyy"
boolean spin = true
end type

event constructor;call super::constructor;text = string(today(),'yyyy-mm-dd')
end event

type st_2 from statictext within w_sheet_sony_isis_modify
integer x = 1792
integer y = 120
integer width = 55
integer height = 60
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16711680
long backcolor = 15793151
string text = "to"
boolean focusrectangle = false
end type

