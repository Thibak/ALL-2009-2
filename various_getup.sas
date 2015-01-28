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


/*proc sort data = &LN..toll;*/
/*	by i_rel descending TRF;*/
/*run;*/
/**/
/*proc print data = &LN..toll;*/
/*	var pt_id name i_rel TRF;*/
/*run;*/



proc sort data=&LN..toll_LM_xa;
	by tkm_au_al;
run;

proc means data = &LN..toll_LM_xa n median max min ;
	by tkm_au_al;
	var age;
   title '������� ������� (�������, �������)';
   	format tkm_au_al tkm_au_al_f.;
run;

/*proc freq data=&LN..toll ;*/
/*   tables age / nocum;*/
/*   title '�������, ������';*/
/*   format age age_group_f.;*/
/*run;*/

proc freq data=&LN..toll_LM_xa ;
   tables tkm_au_al*new_gendercodename / nocum;
   title '���';
   format tkm_au_al tkm_au_al_f.;
run;



proc freq data=&LN..toll_LM_xa  ; *���������� � ����������;
   tables tkm_au_al*T_class12 / nocum;
/*NOPERCENT;*/
   title '������������� (��������)';
   FORMAT T_class12 T_class12_f. tkm_au_al tkm_au_al_f.;
run;

proc means data=&LN..toll_LM_xa  n median max min ;
	by tkm_au_al;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "����� ������������ ���������� ��� ��";
	format tkm_au_al tkm_au_al_f.;
run;


proc freq data=&LN..toll_LM_xa  ; *���������� � ����������;
   tables tkm_au_al*new_citogenname / nocum;
/*NOPERCENT;*/
   title '��������� �������������';
   FORMAT  tkm_au_al tkm_au_al_f.;
run;



proc freq data=&LN..toll_LM_xa  ; *���������� � ����������;
   tables tkm_au_al*new_neyrolekname / nocum;
/*NOPERCENT;*/
   title '��������� ���';
   FORMAT  tkm_au_al tkm_au_al_f.;
run;

proc freq data=&LN..toll_LM_xa  ; *���������� � ����������;
   tables tkm_au_al*new_uvsredostenname / nocum;
/*NOPERCENT;*/
   title '���������� �����������';
   FORMAT tkm_au_al tkm_au_al_f.;
run;

proc freq data=&LN..toll_LM_xa  ;
   tables tkm_au_al*FRint/ nocum;
   title '���������� �������� (�� �����)';
   format FRint FRint_f. tkm_au_al tkm_au_al_f.;
run;

proc freq data=&LN..toll_LM_xa  ;
   tables tkm_au_al*i_ind_death/ nocum;
   title '������ �� ��������';
   format i_ind_death y_n.  tkm_au_al tkm_au_al_f.;
run;


proc freq data=&LN..toll_LM_xa  ;
   tables tkm_au_al*TR/ nocum;
   title '��������� �������';
   format TR TR_f. tkm_au_al tkm_au_al_f.;
run;

proc freq data=&LN..toll_LM_xa  ;
   tables tkm_au_al*new_group_riskname/ nocum;
   title '������ �����';
   format   tkm_au_al tkm_au_al_f.;
run;


proc freq data=&LN..toll_LM_xa  ;
   tables tkm_au_al*reg/ nocum;
   title '������';
   format   tkm_au_al tkm_au_al_f. reg reg_f.;
run;

%eventan (&LN..toll_LM_xa, TLive_LM, i_death, 0,,&y,tkm_au_al, tkm_au_al_f.,"�������� ������. ����� ������������");
%eventan (&LN..toll_LM_xa, TRF_LM, iRF, 0,,&y, tkm_au_al, tkm_au_al_f.,"�������� ������. ������������� ������������");
%eventan (&LN..toll_LM_xa, Trel_LM, i_rel, 0,F,&y,tkm_au_al, tkm_au_al_f.,"�������� ������. ����������� �������� ��������");


data ALL2009.NCH_lm_xa;
	SET ALL2009.toll_lm_xa;
	if reg = 1;
run;

proc freq data=all2009.toll_lm_xa;
	tables reg*tkm_au_al/nocum;
	format tkm_au_al tkm_au_al_f. reg reg_f.;
run;

%eventan (ALL2009.NCH_lm_xa, TLive_LM, i_death, 0,,&y,tkm_au_al, tkm_au_al_f.,"���. �������� ������. ����� ������������");
%eventan (ALL2009.NCH_lm_xa, TRF_LM, iRF, 0,,&y, tkm_au_al, tkm_au_al_f.,"���. �������� ������. ������������� ������������");
%eventan (ALL2009.NCH_lm_xa, Trel_LM, i_rel, 0,F,&y,tkm_au_al, tkm_au_al_f.,"���. �������� ������. ����������� �������� ��������");


data ALL2009.reg_lm_xa;
	SET ALL2009.toll_lm_xa;
	if reg = 0;
run;


%eventan (ALL2009.reg_lm_xa, TLive_LM, i_death, 0,,&y,tkm_au_al, tkm_au_al_f.,"�������. �������� ������. ����� ������������");
%eventan (ALL2009.reg_lm_xa, TRF_LM, iRF, 0,,&y, tkm_au_al, tkm_au_al_f.,"�������. �������� ������. ������������� ������������");
%eventan (ALL2009.reg_lm_xa, Trel_LM, i_rel, 0,F,&y,tkm_au_al, tkm_au_al_f.,"�������. �������� ������. ����������� �������� ��������");


%eventan (&LN..toll, TLive, i_death, 0,,&y,age, age_group_30_f.,"������������");
%eventan (&LN..toll, TRF, iRF, 0,,&y,age, age_group_30_f.,"������������� ������������");


%eventan (&LN..toll_LM_xa, TLive_LM, i_death, 0,,&y,age, age_group_30_f.,"�������� ������. ����� ������������");
%eventan (&LN..toll_LM_xa, TRF_LM, iRF, 0,,&y, age, age_group_30_f.,"�������� ������. ������������� ������������");
%eventan (&LN..toll_LM_xa, Trel_LM, i_rel, 0,F,&y,age, age_group_30_f.,"�������� ������. ����������� �������� ��������");



%eventan (&LN..toll, TLive, i_death, 0,,&y,reg, reg_f.,"����� ������������");
%eventan (&LN..toll, TRF, iRF, 0,,&y, reg, reg_f.,"������������� ������������");
%eventan (&LN..toll, Trel, i_rel, 0,F,&y,reg, reg_f.,"����������� �������� ��������");

%eventan (&LN..toll, TLive, i_death, 0,,&y,new_group_riskname,,"����� ������������");
%eventan (&LN..toll, TRF, iRF, 0,,&y, new_group_riskname,,"������������� ������������");
%eventan (&LN..toll, Trel, i_rel, 0,F,&y,new_group_riskname,,"����������� �������� ��������");

data tmp;
	set &LN..toll;
	if new_group_risk in (1,2);
run;

%eventan (tmp, TLive, i_death, 0,,&y,new_group_riskname,,"����� ������������");
%eventan (tmp, TRF, iRF, 0,,&y, new_group_riskname,,"������������� ������������");
%eventan (tmp, Trel, i_rel, 0,F,&y,new_group_riskname,,"����������� �������� ��������");


proc freq data=&LN..toll;
   tables T_class12*new_splenomegname/ nocum;
   title '�����������������';
   format T_class12 T_class12_f.;
run;

proc freq data=&LN..toll;
   tables T_class12*new_group_riskname/ nocum;
   title '������������� �� ������� �����';
   format T_class12 T_class12_f.;
run;


proc freq data=&LN..toll;
   tables new_blast_km/ nocum;
   title '�������� ������ � ��';
   format new_blast_km blast_km_f.;
run;