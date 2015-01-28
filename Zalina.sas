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
	value age_50_f low-49 = "�� 50-� ���" 49-high = "������ 50-� ���";
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
/*	value pr_bg_year_f = */
run;



/*------------------------------------------*/
proc sort data = &LN..new_pt;
	by age;
run;

proc means data = &LN..new_pt N median max min ;
	var age;
   title '����� �������, ������� ��������';
run;

proc means data = &LN..new_pt N median max min ;
	by age;
	var age;
   title '����� �������, ������� �������� �� �������';
	FORMAT age age_50_f.;
run;

proc freq data=&LN..new_pt;
   tables new_gendercodename / nocum;
   title '��� ��� ���� ������';
run;
proc freq data=&LN..new_pt;
   tables new_gendercodename*age / nocum;
   title '��� ��� ���� ������';
   FORMAT age age_50_f.;
run;
proc freq data=&LN..new_pt ; *���������� � ����������;
   tables oll_class / nocum;
/*NOPERCENT;*/
   title '�������������';
   FORMAT oll_class oc_f.;
run;

proc freq data=&LN..new_pt ; *���������� � ����������;
   tables oll_class*age / nocum;
/*NOPERCENT;*/
   title '�������������';
   FORMAT oll_class oc_f. age age_50_f.;
run;


proc freq data=&LN..new_pt ; *���������� � ����������;
   tables new_oll_classname / nocum;
/*NOPERCENT;*/
   title '������������� (��������)';
   FORMAT oll_class oc_f.;
run;

proc freq data=&LN..new_pt ; *���������� � ����������;
   tables new_oll_classname*age / nocum;
/*NOPERCENT;*/
   title '������������� (��������)';
   FORMAT oll_class oc_f. age age_50_f.;
run;

proc means data=&LN..new_pt n median max min;
	by age;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "�������-������������ ����������";
	FORMAT age age_50_f.;
run;

proc freq data=&LN..new_pt ; *���������� � ����������;
   tables new_group_riskname*age / nocum;
/*NOPERCENT;*/
   title '������ �����';
   FORMAT  age age_50_f.;
run;


proc freq data=&LN..new_pt ; *���������� � ����������;
   tables 
age*new_splenomegname 
age*lap
age*new_neyrolekname
age*new_uvsredostenname
/ nocum;
/*NOPERCENT;*/
   title '����������� ����������';
   FORMAT  age age_50_f. lap y_n.;
run;

proc freq data=&LN..new_pt ; *���������� � ����������;
   tables d_ch*age / nocum;
/*NOPERCENT;*/
   title '����� �� ������������';
   FORMAT  age age_50_f. d_ch y_n.;
run;

proc freq data=&LN..new_pt ; *���������� � ����������;
   tables age*d_ch*new_group_riskname / nocum;
/*NOPERCENT;*/
   title '����� �� ������������ (��� ������� �� ���������� �������)';
   FORMAT  age age_50_f. d_ch y_n.;
   label d_ch = '����� �� ������������';
run;

proc means data = &LN..new_pt N median max min ;
	by age;
	var new_blast_km;
   title '�������� ������ � ��';
   	FORMAT age age_50_f.;
run;

proc freq data=&LN..new_pt ;
   tables age*TR/ nocum;
   title '��������� �������';
   format TR TR_f. age age_50_f.;
run;

proc freq data=&LN..new_pt ; *���������� � ����������;
   tables 
age*pneumonia_i
age*NEP_i
age*sepsis_i
age*invasp_i
/ nocum;
/*NOPERCENT;*/
   title '������������ ����������';
   FORMAT  
	age age_50_f.
	pneumonia_i  y_n.
	NEP_i y_n.
	sepsis_i y_n.
	invasp_i y_n.
	;
run;


proc freq data=&LN..new_pt ; *���������� � ����������;
   tables 
age*a_vvod_i
age*a_pankr_i
age*a_gepat_i
age*a_narbelsint_i
age*a_tromb_i
/*a_occhuv_t*/
age*a_perehod_i
age*a_otmena_i
/ nocum;
/*NOPERCENT;*/
   title '����������� ���������� ������������';
   FORMAT  
	age age_50_f.
	a_pankr_i y_n.
	a_gepat_i y_n.
	a_narbelsint_i y_n.
	a_tromb_i y_n.
	a_perehod_i y_n.
	a_otmena_i y_n.
	;
run;

%eventan (&LN..new_pt, TLive, i_death, 0,,&y,,,"������������");
%eventan (&LN..new_pt, TRF, iRF, 0,,&y,,,"������������� ������������");
%eventan (&LN..new_pt, Trel, i_rel, 0,F,&y,,,"�������� ������. ����������� �������� ��������");

%eventan (&LN..new_pt, TLive, i_death, 0,,&y,age, age_50_f.,"������������");
%eventan (&LN..new_pt, TRF, iRF, 0,,&y,age, age_50_f.,"������������� ������������");
%eventan (&LN..new_pt, Trel, i_rel, 0,F,&y,age, age_50_f.,"�������� ������. ����������� �������� ��������");

%eventan (&LN..oll_reg_50, TLive, i_death, 0,,&y,,,"������������");


/**/
/*data &LN..zalina_up;*/
/*	set &LN..new_pt ;*/
/*	if  age > 55;*/
/*run;*/
/**/
/*proc print data =  &LN..zalina_up;*/
/*	var pt_id name age;*/
/*run;*/
/**/
/*proc means data = &LN..zalina_up n median max min ;*/
/*   var age;*/
/*   title '������� ������� (�������, �������) >55';*/
/*run;*/
/**/
/*data &LN..zalina;*/
/*	set &LN..new_pt ;*/
/*	if age >= 50 and age <= 55;*/
/*run;*/
/**/
/*proc means data = &LN..zalina n median max min ;*/
/*   var age;*/
/*   title '������� ������� (�������, �������) 50<=x<=55';*/
/*run;*/
/**/
/*proc sort data=&LN..zalina;*/
/*	by pt_id;*/
/*run;*/
/**/
/*proc print data=&LN..zalina;*/
/*	var pt_id name age;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina; *���������� � ����������;*/
/*   tables oll_class / nocum;*/
/*/*NOPERCENT;*/*/
/*   title '�������������';*/
/*   FORMAT oll_class oc_f.;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina;*/
/*   tables new_gendercodename / nocum;*/
/*   title '���';*/
/*run;*/
/**/
/*proc freq data=&LN..zalina ; *���������� � ����������;*/
/*   tables new_oll_classname / nocum;*/
/*/*NOPERCENT;*/*/
/*   title '������������� (��������)';*/
/*run;*/
/**/
/**/
/*proc freq data=&LN..zalina ; *���������� � ����������;*/
/*   tables new_group_riskname / nocum;*/
/*/*NOPERCENT;*/*/
/*   title '������ �����';*/
/*run;*/
/**/
/*proc means data=&LN..zalina n median max min ;*/
/*	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;*/
/*	title "����� ������������ ���������� ��� �� 50-55";*/
/*run;*/
/**/
/*proc sort data=&LN..zalina;*/
/*	by oll_class;*/
/*run;*/
/**/
/*proc means data=&LN..zalina n median max min ;*/
/*	by oll_class;*/
/*	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;*/
/*	title "����� ������������ ���������� ��� �� 50-55 (�� �������)";*/
/*    FORMAT oll_class oc_f.;*/
/*run;*/
/**/
/*proc means data=&LN..zalina_up n median max min ;*/
/*	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;*/
/*	title "����� ������������ ���������� ��� �� >55";*/
/*run;*/
/**/
/*proc sort data=&LN..zalina_up;*/
/*	by oll_class;*/
/*run;*/
/**/
/*proc means data=&LN..zalina_up n median max min ;*/
/*	by oll_class;*/
/*	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;*/
/*	title "����� ������������ ���������� ��� �� >55 (�� �������)";*/
/*    FORMAT oll_class oc_f.;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina ; *���������� � ����������;*/
/*   tables new_neyrolekname / nocum;*/
/*/*NOPERCENT;*/*/
/*   title '��������� ���';*/
/*run;*/
/**/
/*proc freq data=&LN..zalina; *���������� � ����������;*/
/*   tables new_uvsredostenname / nocum;*/
/*/*NOPERCENT;*/*/
/*   title '���������� �����������';*/
/*run;*/
/**/
/*proc freq data=&LN..zalina;*/
/*   tables FRint/ nocum;*/
/*   title '���������� �������� (�� �����)';*/
/*   format FRint FRint_f.;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina;*/
/*   tables i_ind_death/ nocum;*/
/*   title '������ �� ��������';*/
/*   format i_ind_death y_n.;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina ;*/
/*   tables i_res/ nocum;*/
/*   title '������� ��������������';*/
/*   format i_res y_n. ;*/
/*run;*/
/**/
/*proc freq data=&LN..zalina;*/
/*   tables TR/ nocum;*/
/*   title '��������� �������';*/
/*   format TR TR_f.;*/
/*run;*/
/**/
/**/
/*%eventan (&LN..zalina, TLive, i_death, 0,,&y,,,"������������");*/
/*%eventan (&LN..zalina, TRF, iRF, 0,,&y,,,"������������� ������������");*/
/*%eventan (&LN..zalina, Trel, i_rel, 0,F,&y,,,"�������� ������. ����������� �������� ��������");*/
