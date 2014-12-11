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
%let cens = (20);
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






proc means data = &LN..all_pt N;
	var pguid;
   title '����� �������';
run;

proc freq data=&LN..new_pt ; *���������� � ����������;
   tables oll_class / nocum;
/*NOPERCENT;*/
   title '�������������';
   FORMAT oll_class oc_f.;
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
	title "����� ������������ ���������� ��� �� (�� ��������������)";
	FORMAT T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ; *���������� � ����������;
   tables T_class12*new_citogenname / nocum;
/*NOPERCENT;*/
   title '��������� �������������';
   FORMAT T_class12 T_class12_f.;
run;



proc freq data = &LN..cito;
	tables T_class12*new_normkariotipname/nocum;
   title '���������� �������� (�� ����������)';
   FORMAT T_class12 T_class12_f.;
run;

proc freq data = &LN..cito;
	tables T_class12*new_mitozname/nocum;
   title '��� ������� (�� ����������)';
   FORMAT T_class12 T_class12_f.;
run;


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
%eventan (&LN..toll, TLive, i_death, 0,,&y,,,"������������");
%eventan (&LN..toll, TRF, iRF, 0,,&y,,,"������������� ������������");

%eventan (&LN..toll, TLive, i_death, 0,,&y,T_class12,T_class12_f.,"������������");
%eventan (&LN..toll, TRF, iRF, 0,,&y,T_class12,T_class12_f.,"������������� ������������");

%eventan (&LN..toll_LM, TLive_LM, i_death, 0,,&y,tkm_au_al, tkm_au_al_f.,"�������� ������. ����� ������������");
%eventan (&LN..toll_LM, TRF_LM, iRF, 0,,&y, tkm_au_al, tkm_au_al_f.,"�������� ������. ������������� ������������");
%eventan (&LN..toll_LM, Trel_LM, i_rel, 0,F,&y,tkm_au_al, tkm_au_al_f.,"�������� ������. ����������� �������� ��������");



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
