/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*****************                                                                       *******************/
/****************                      ����� �� ��������� ���-2009                        ******************/
/*****************                          ������ �� �-���                              *******************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*������������� �����*/ *D - sony, Z - ���;
*��� ���������� ����������� �� ��������;
%let disk = .;
%let lastname= .;
%macro what_OC;
%if &sysscpl = W32_7PRO %then 
	%do;
		%let disk = D; *sony;
	%end;
%if &sysscpl = X64_7PRO %then 
	%do;
		%let disk = Z; *������;
	%end;
%mend;


/*������������ ��*/
/*data comp;*/
/*	OC = "&sysscpl";*/
/*run;*/
/**/
/*proc print data = COMP;*/
/*run;*/
%what_OC;

%let LN = ALL2009; * ��� ����������;
Libname &LN "&disk.:\AC\OLL-2009\SAS"; * ���������� ������;
%let y = cl;
%let cens = (20,73,25);
/*��������� - ���������, ����������, ��������*/
/*25 -- �������� (�������� ��� ���� � ��������� ��� � 10-� ���� (��� ������ ��� ����� ���).)*/
/*73 -- ������� (� �������� ������ ������ ������� - ���������� �������)*/
/*266	����������� �.�. -- ������������ �� ���� ��������� - � ���� ������ ��������� �� �������� ����� ���������� ������ �������� � ���� ���. �� ���������� ������� � ������������� ������*/
/*20	��������� ��� ������ ��� ������*/
/*27 -- ������������ -- ������������ ��������, �� ������ �� �������. �� ������� ������ ����� ��������, � � ������� ������������ � ����������� ������� �� ���������.*/
*20, 27, 99, 132, 258, 264;

%macro Eventan(dat,T,C,i,s,cl,f,for, ttl);
/*
dat -��� ������ ������,
T - �����,
C - ������ �������/��������������,
i=0, ���� � ������ �������,
i=1, ���� � ������ ��������������.
s = �����,���� �������� ������ ������������
s = F, ���� �������� ������ ����������� �����������
cl = cl,���� ���������� ������������� ��������
cl = �����,���� �� ���������� ������������� ��������
s = F, ���� �������� ������ ����������� �����������
f = ������ (������) ���� ����� �� ��� ������
for = ������ (1.0 ��� ������������� ��������, ����� ��� ������������ �������)
ttl = ���������
*/

data _null_; set &dat;
   length tit1 $256 tit2 $256;
*������ ��������;
tit1=vlabel(&T);
%if &f ne %then %do; tit2=vlabel(&f);%end;
   * �������� ������� � ���������������;
   call symput('tt1',tit1);
   call symput('tt2',tit2);
output;
   stop;
   keep tit1 tit2;
run;
title1 &ttl;
title2 " ���������:  &tt1 // ������       :  &tt2";
ods graphics on;
ods exclude WilHomCov LogHomCov HomStats  Quartiles ; *ProductLimitEstimates;
proc lifetest data=&dat plots =(s( &s &cl))  method=pl ;
    %if &f ne %then %do; strata &f/test=logrank;
    id &f;format   &f &for;%end;
    time &T*&C(&i) ;
run;
ods graphics off;
%mend;


/*------------------------------------------------------------------------------------------*/

proc format;
    value oc_f  1 = "B-���������" 2 = "T-���������" 3 = "����������������" 0 = "����������" ;
    value gender_f 1 = "�������" 2 = "�������";
    value risk_f 1 = "�����������" 2 = "�������" 3 = "��� ������";
    value age_group_28_f low-28 = "�� 28-�� ���" 28-high = "����� 28-�� ���";
    value age_group_30_f low-30 = "�� 30-�� ���" 30-high = "����� 30-�� ���";
    value age_group_33_f low-33 = "�� 33-� ���" 33-high = "����� 33-� ���";
	value age_group_f low-29 = "AYA" 29-high = "Adult";
	value triple_age_f low-30 = "1" 30-40 = "2" 40-high = "3";
	value tkm_f 0="���" 1="����" 2="����";
	value it_f 1="����" 0 = "���";
	value time_error_f . = "��� ������" 
		0 = "���� ���������� ������ �� ���������" 
		1 = "���� ���������� ������� (�����) ������ ��� ���� ���������� ��������" 
		2 = "���� �������� ������ ���� ���������� ��������" 
		3 = "���� �������� ������ ���� ���������� ��������"
		4 = "date bmt > lastdate";

/*	  if date_rem > lastdate then do; time_error = 2; lastdate = date_rem; end;*/
/*    if date_rel > lastdate then do; time_error = 3; lastdate = date_rel; end;*/
	value new_group_risk_f 1 = "�����������" 2 = "�������";
	value y_n 0 = "���" 1 = "��";
	value yn_e 0 = "no" 1 = "yes";
	value au_al_f 1 = "����" 2 = "���� - �����������" ;
	value reg_f 0 = "�������" 1 = "���"; 
	value T_class12_f 0 = "T1+T2" 1 = "T3" 2 = "T4";
	value T_class124_f 0 = "T1+T2+T4" 1 = "T3";
	value TR_f 0 = "������ ��������" 1 = "������������ �����" 2 = "������ � ��������";
	value BMinv_f 0 = "��� ���������" 1 = "� ����������";
	value AAC_f 0 = "������������" 1 = "���� ���" 2 = "���� ���" 3 = "������ �������" 4 = "������ � ��������" 5 = "�� �������� (T < 5 ���)";
	value FRint_f 1 = "�� �� ��������" 2 = "�� �� 1-�� ���� ��������" 3 = "�� �� 2-�� ���� ��������" 19 = "����������� ������������";
	value BMT_f 0 = "������������" 1 = "���";
	value tkm_au_al_f 0 = "������������" 1="����-���" 2="����-���";
	value tkm_au_al_en 0 = "chemo" 1="auto-HSCT" 2="allo-HSCT";
	value new_group_riskname_f 1 = 'Standard' 2 = 'Hi';
	value blast_km_f low-5 = '<5%' 5-25 = '5%-25%' 25-high = '>25%';
run;

/*------------------------------------------*/

proc means data = &LN..all_pt N;
	var new_gendercode;
   title '����� �������';
run;

proc freq data=&LN..new_pt ; *���������� � ����������;
   tables oll_class / nocum;
/*NOPERCENT;*/
   title '�������������';
   FORMAT oll_class oc_f.;
run;

proc freq data=&LN..new_pt;
   tables new_gendercodename / nocum;
   title '��� ��� ���� ������';
run;

title1 "T-Oll";

proc means data = &LN..toll n median max min ;
   var age;
   title '������� ������� (�������, �������)';
run;

/*proc freq data=&LN..toll ;*/
/*   tables age / nocum;*/
/*   title '�������, ������';*/
/*   format age age_group_f.;*/
/*run;*/

proc freq data=&LN..toll ;
   tables new_gendercodename / nocum;
   title '���';
run;

proc sort data = &LN..toll;
	by T_class12;
run;

proc freq data=&LN..toll ; *���������� � ����������;
   tables T_class12 / nocum;
/*NOPERCENT;*/
   title '������������� (��������)';
   FORMAT T_class12 T_class12_f.;
run;

proc means data=&LN..toll n median max min ;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "����� ������������ ���������� ��� ��";
run;

proc means data=&LN..toll n median max min ;
	by T_class12;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "����� ������������ ���������� (�� ��������������)";
	FORMAT T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ; *���������� � ����������;
   tables T_class12*new_citogenname / nocum;
/*NOPERCENT;*/
   title '��������� �������������';
   FORMAT T_class12 T_class12_f.;
run;



proc freq data = &LN..tcito;
	tables T_class12*new_normkariotipname/nocum;
   title '���������� �������� (�� ����������)';
   FORMAT T_class12 T_class12_f.;
run;

proc freq data = &LN..tcito;
	tables T_class12*new_mitozname/nocum;
   title '��� ������� (�� ����������)';
   FORMAT T_class12 T_class12_f.;
run;

/*��� ��������� ���������� ���������� �������� &LN..tLMcito*/

/*proc freq data = &LN..tLMcito;*/
/*	tables T_class12*new_mitozname/nocum;*/
/*   title '��� ������� (�� ����������) ��� LM';*/
/*   FORMAT T_class12 T_class12_f.;*/
/*run;*/

proc freq data=&LN..toll ; *���������� � ����������;
   tables T_class12*new_neyrolekname / nocum;
/*NOPERCENT;*/
   title '��������� ���';
   FORMAT T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ; *���������� � ����������;
   tables T_class12*new_uvsredostenname / nocum;
/*NOPERCENT;*/
   title '���������� �����������';
   FORMAT T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*FRint/ nocum;
   title '���������� �������� (�� �����)';
   format FRint FRint_f. T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*i_ind_death/ nocum;
   title '������ �� ��������';
   format i_ind_death y_n. T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*i_res/ nocum;
   title '������� ��������������';
   format i_res y_n. T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*TR/ nocum;
   title '��������� �������';
   format TR TR_f. T_class12 T_class12_f.;
run;



proc freq data=&LN..toll;
   tables T_class12*tkm_au_al/ nocum;
   title '����/����-���';
   format tkm_au_al tkm_au_al_f. T_class12 T_class12_f.;
run;

data tmp;
	set &LN..toll;
	if tkm_au_al in (1,2) and i_death = 1;
run;

proc print data = tmp;
	title '��� + ������ (��������� ������������������ �������)';
	var pt_id name tkm_au_al i_death date_TKM date_death;
	 format date_TKM DDMMYY10. date_death DDMMYY10. tkm_au_al tkm_au_al_f.;
run; 

data tmp;
	set &LN..toll;
	if date_death - pr_b < 10 and date_death ne .;
run;

proc print data = tmp;
	title '������ ����� ��� ����� 10 ���� ����� ������ �������';
	var pt_id name pr_b date_death new_group_riskname new_oll_classname ;
	 format pr_b DDMMYY10. date_death DDMMYY10. tkm_au_al tkm_au_al_f.;
run; 

data tmp;
	set all2009.toll;
	if new_uvsredosten or new_peref_ulu or new_vnutrigrud_ulu or new_abdomi_ulu;
run;

proc sort data = tmp;
	by blast_km;
run;

proc freq data = tmp;
	tables blast_km/nocum;
	FORMAT  blast_km blast_km_f.;
	title '������ � �� ��� ��������� � ���� ���� �� �������� �������������: ���������� ����������� (����������� ����������), �������������� (���������� ���. �����),
������������� (���������� ���. �����), ������������� (���������� ���. �����), ������ (���������� ���. �����)';
run;

proc means data=tmp n median max min ;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "����� ������������ ���������� ��� ��������� � �������� � ����� � ��. ��� � ���������� �������";
	FORMAT T_class12 T_class12_f.;
run;

proc means data=tmp n median max min ;
	by blast_km;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "����� ������������ ���������� ��� ��������� � �������� � ����� � ��. ��� � ���������� �������";
	FORMAT T_class12 T_class12_f. blast_km blast_km_f.;
run;

proc sort data = tmp;
	by  T_class12 blast_km;
run;

proc means data=tmp n median max min ;
	by  T_class12 blast_km;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "����� ������������ ���������� ��� ��������� � �������� � ����� � ��. ��� � ���������� �������";
	FORMAT T_class12 T_class12_f. blast_km blast_km_f.;
run;
%eventan (&LN..toll, TLive, i_death, 0,,&y,,,"������������");
%eventan (&LN..toll, TRF, iRF, 0,,&y,,,"������������� ������������");

%eventan (&LN..toll, TLive, i_death, 0,,&y,blast_km, blast_km_f.,"������������");
%eventan (&LN..toll, TRF, iRF, 0,,&y,blast_km, blast_km_f.,"������������� ������������");

%eventan (&LN..toll, TLive, i_death, 0,,&y,age,age_group_f.,"������������");
%eventan (&LN..toll, TRF, iRF, 0,,&y,age,age_group_f.,"������������� ������������");

%eventan (&LN..toll, TLive, i_death, 0,,&y,T_class12,T_class12_f.,"������������");
%eventan (&LN..toll, TRF, iRF, 0,,&y,T_class12,T_class12_f.,"������������� ������������");

%eventan (&LN..toll_LM_xa, TLive_LM, i_death, 0,,&y,tkm_au_al, tkm_au_al_f.,"�������� ������. ����� ������������");
%eventan (&LN..toll_LM_xa, TRF_LM, iRF, 0,,&y, tkm_au_al, tkm_au_al_f.,"�������� ������. ������������� ������������");
%eventan (&LN..toll_LM_xa, Trel_LM, i_rel, 0,F,&y,tkm_au_al, tkm_au_al_f.,"�������� ������. ����������� �������� ��������");


data tmp;
	SET &LN..toll_LM;
	if tkm_au_al = 0;
run;

%eventan (tmp, TLive_LM, i_death, 0,,&y,age, age_group_f.,"������ ��: �������� ������. ����� ������������");
%eventan (tmp, TRF_LM, iRF, 0,,&y, age, age_group_f.,"������ ��: �������� ������. ������������� ������������");



proc sort data=&LN..toll_LM_xa;
	by i_tkm tkm_dur;
run;

/*proc print data=tmp;*/
/*	var pt_id name i_tkm tkm_dur tkm_au_al pr_b date_tkm ;*/
/*run;*/

proc means data=&LN..toll_LM_xa n median max min ;
	var tkm_dur;
	title '�� ������ ������� �� ��������������';
run;

proc means data=&LN..toll_LM_xa n median max min ;
	var Ttkm;
	title '�� ���������� �������� �� ��������������';
run;

/*������ �� �� 6-�� ���.*/
/*data tmp;*/
/*	set &LN..toll;*/
/*	if Tlive < 6;*/
/*	label date_death = "���� ������"*/
/*		new_group_risk = "������ �����"*/
/*		new_normkariotip = "Normal karyotype"*/
/*		pt_id = "�������������"*/
/*		name = "���"*/
/*		i_death = "������"*/
/*		i_ind_death = "������ � ��������"*/
/*		i_rel = "�������"*/
/*		i_dev = "���������� �� ���������"*/
/*		dev_t = "���������� - �����������"*/
/*		i_off = "��������������� ������ � ���������"*/
/*		off_t = "������ -- �����������"*/
/*		;*/
/*run;*/
/**/
/*proc print data=tmp;*/
/*	var pt_id name i_death i_ind_death i_rel i_dev dev_t i_off off_t; */
/**/
/*run;*/

/**/
/*proc sort data=&LN..toll;*/
/*	by i_death TLive;*/
/*run;*/
/**/
/*proc print data=all2009.toll;*/
/*	var pt_id name i_death TLive;*/
/*run;*/

/*proc means data = &LN..new_pt median max min ;*/
/*   var TD;*/
/*   title '������� ����� ����������';*/
/*run;*/
/**/
/*proc sort data = &LN..new_pt;*/
/*	by tkm_au_al;*/
/*run;*/
/**/
/*proc means data = &LN..new_pt median max min ;*/
/*	by tkm_au_al;*/
/*   var TD;*/
/*   title '������� ����� ���������� �� �������';*/
/*run;*/



/*proc sort data=&LN..all_pt;*/
/*	by new_oll_class;*/
/*run;*/
/**/
/*proc means data = &LN..new_pt median max min ;*/
/*   var Ttkm;*/
/*   title '������� ���. ���. �� ��� (�������, �������)';*/
/*run;*/
/*proc freq data=&LN..all_pt ORDER = DATA;*/
/*   tables new_oll_classname / nocum;*/
/*   title '������������� (��������)';*/
/*run;*/

proc sort data=&LN..toll_NLM;
	by i_death TLive;
run;

proc print data=&LN..toll_NLM;
	var pt_id name i_death TLive TRF i_rem i_rel onT;
	title "�� LM";
run;

data tmp;
	SET &LN..toll_LM;
	if i_tkm;
run;

proc sort data=tmp;
	by tkm_au_al;
run;

/*proc print data=tmp;*/
/*	var pt_id name Ttkm tkm_au_al;*/
/*run;*/

proc means data=tmp n median max min ;
	var Ttkm;
	title '��� ���, ������� �� �������� �� ���';
run;

proc means data=tmp n median max min ;
	by tkm_au_al;
	var Ttkm;
	format tkm_au_al tkm_f.;
run;

proc sort data=tmp;
	by reg;
run;

proc means data=tmp n median max min ;
	by reg;
	var Ttkm;
	format reg reg_f.;
run;


data tmp;
	set all2009.toll_lm_xa;
	if i_rel = 1;
run;

proc print data=tmp;
	var pt_id name new_regionname new_group_riskname new_oll_classname owneridname i_death;
	title "�������� LM";
run;

proc freq data = all2009.toll_lm_xa;
	tables blast_km*tkm_au_al/nocum;
	FORMAT  blast_km blast_km_f. tkm_au_al tkm_au_al_en.;
	title '������ � ��';
run;

proc freq data = all2009.toll_lm;
	table T_class12*new_normkariotipname/nocum;
   title '���������� �������� ��� LM';
   format T_class12 T_class12_f.;
run; 


proc ttest data=&LN..toll_LM_xa;
	class tkm_au_al;
	var new_l;
	title "�������� � ������� ���������� �� �������� ������� � �������";
	FORMAT tkm_au_al tkm_au_al_en.;
run;


data off;
	set all2009.toll_LM_xa;
	if i_dev = 1;
run;

proc print data=off;
	var pt_id name i_rel i_death;
run;