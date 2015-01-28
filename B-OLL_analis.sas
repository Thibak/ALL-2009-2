/*��������*/

/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*****************                                                                       *******************/
/****************                      ����� �� ��������� ���-2009                        ******************/
/*****************                                                                       *******************/
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

title1 "b-Oll";

proc means data = &LN..boll n median max min ;
   var age;
   title '������� ������� (�������, �������)';
run;

/*proc freq data=&LN..boll ;*/
/*   tables age / nocum;*/
/*   title '�������, ������';*/
/*   format age age_group_f.;*/
/*run;*/

proc freq data=&LN..boll ;
   tables new_gendercodename / nocum;
   title '���';
run;

proc sort data = &LN..boll;
	by new_oll_class;
run;

proc freq data=&LN..boll ; *���������� � ����������;
   tables new_oll_classname / nocum;
/*NOPERCENT;*/
   title '������������� (��������)';
/*   FORMAT T_class12 new_oll_classname.;*/
run;

proc means data=&LN..boll n median max min ;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "����� ������������ ����������";
run;
/**/
/*proc means data=&LN..boll n median max min ;*/
/*	by T_class12;*/
/*	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;*/
/*	title "����� ������������ ���������� (�� ��������������)";*/
/*	FORMAT T_class12 T_class12_f.;*/
/*run;*/

proc freq data=&LN..boll ; *���������� � ����������;
   tables new_oll_classname*new_citogenname / nocum;
/*NOPERCENT;*/
   title '��������� �������������';
/*   FORMAT T_class12 T_class12_f.;*/
run;



proc freq data = &LN..bcito;
	tables new_oll_classname*new_normkariotipname/nocum;
   title '���������� �������� (�� ����������)';
/*   FORMAT T_class12 T_class12_f.;*/
run;

proc freq data = &LN..bcito;
	tables new_oll_classname*new_mitozname/nocum;
   title '��� ������� (�� ����������)';
/*   FORMAT T_class12 T_class12_f.;*/
run;


proc freq data=&LN..boll ; *���������� � ����������;
   tables new_oll_classname*new_neyrolekname / nocum;
/*NOPERCENT;*/
   title '��������� ���';
/*   FORMAT T_class12 T_class12_f.;*/
run;

proc freq data=&LN..boll ; *���������� � ����������;
   tables new_oll_classname*new_uvsredostenname / nocum;
/*NOPERCENT;*/
   title '���������� �����������';
/*   FORMAT T_class12 T_class12_f.;*/
run;

proc freq data=&LN..boll ;
   tables new_oll_classname*FRint/ nocum;
   title '���������� �������� (�� �����)';
   format FRint FRint_f.;
run;

proc freq data=&LN..boll ;
   tables new_oll_classname*i_ind_death/ nocum;
   title '������ �� ��������';
   format i_ind_death y_n.;
run;

proc freq data=&LN..boll ;
   tables new_oll_classname*rem_death/ nocum;
   title '������ � ��������';
   format rem_death y_n.;
run;

proc freq data=&LN..boll ;
   tables new_oll_classname*i_res/ nocum;
   title '������� ��������������';
   format i_res y_n.;
run;


proc freq data=&LN..boll ;
   tables new_oll_classname*TR/ nocum;
   title '��������� �������';
   format TR TR_f.;
run;



proc freq data=&LN..boll;
   tables new_oll_classname*tkm_au_al/ nocum;
   title '����/����-���';
   format tkm_au_al tkm_au_al_f.;
run;

proc freq data=&LN..boll;
   tables new_oll_classname*new_splenomegname/ nocum;
   title '�����������������';
run;

proc freq data=&LN..boll;
   tables new_oll_classname*new_group_riskname/ nocum;
   title '������������� �� ������� �����';
run;

proc freq data=&LN..boll;
   tables new_blast_km/ nocum;
   title '�������� ������ � ��';
   format new_blast_km blast_km_f.;
run;




/* ����� � ������������� �� ��������, �������,
������� �����, ������������ (���������� � ���������� ��������), 
�������� (�1,2,3) ��� ���� �-��� ������*/

%eventan (&LN..boll, TLive, i_death, 0,,&y,,,"������������");
%eventan (&LN..boll, TRF, iRF, 0,,&y,,,"������������� ������������");

%eventan (&LN..boll, TLive, i_death, 0,,&y,new_oll_classname,,"������������");
%eventan (&LN..boll, TRF, iRF, 0,,&y,new_oll_classname,,"������������� ������������");

%eventan (&LN..boll, TLive, i_death, 0,,&y,age, age_group_f.,"����� ������������");
%eventan (&LN..boll, TRF, iRF, 0,,&y, age, age_group_f.,"������������� ������������");

%eventan (&LN..boll, TLive, i_death, 0,,&y,reg,reg_f.,"������������");
%eventan (&LN..boll, TRF, iRF, 0,,&y,reg,reg_f.,"������������� ������������");

%eventan (&LN..boll, TLive, i_death, 0,,&y,new_group_riskname,,"������������");
%eventan (&LN..boll, TRF, iRF, 0,,&y,new_group_riskname,,"������������� ������������");


data tmp;
	set all2009.boll;
	if new_t411 = 1;
run;

%eventan (tmp, TLive, i_death, 0,,&y,,,"������������");
%eventan (tmp, TRF, iRF, 0,,&y,,,"������������� ������������");
