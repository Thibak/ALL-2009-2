/*���������� �������� ������*/


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

proc print data = &LN..cens split='*' N;
	var pt_id name;
	label pt_id = '����� ��������*� ���������'
          name = '���*� ���� ���������';
	title "�� ���� ������������� ��������� ��������� ������" ;
run;

proc print data = &LN..age_out;
	var  pt_id name age; 
	title  '�� �������� ���������';
run; 


data null;
	set &LN..all_pt;
	if pt_id = . then output;
run;

proc print data = null split='*' N;
	var pt_id name;
	label pt_id = '����� ��������*� ���������'
          name = '���*� ���� ���������';
	title "� ���� �� ����� ������ � ���������" ;
run;


proc print data = &LN..error_ptVSet split='*' N obs="�����*������";
	var pt_id name name_e new_etap_protokolname it1 it2;
	label pt_id = '����� ��������*� ���������'
          name = '���*� ���� ���������'
          name_e = '���*� ���� ������'
		  new_etap_protokolname = '����'
		  it1 = '������*� ���� ���������' 
		  it2 = '������* � ���� ������';
	title "������ � ���� (���� ������� - ����)" ;
	format  it1 it2 it_f. ; 
run;

proc sort data = &LN..error_timeline;
	by pt_id;
run;

proc print data = &LN..error_timeline split='*' N;
	var pt_id name time_error;
	label pt_id = '����� ��������*� ���������'
          name = '���*� ���� ���������'
		  time_error = "������";
	title "������ ���������� ���������" ;
	footnote '*���� ���������� ������ ��������� � ������������ � ��������� ����������� � �������'; 
	format  it1 it2 it_f. time_error time_error_f. ; 
run;
footnote " ";


proc sort data = &LN..no_TR;
	by pt_id;
run;


proc print data = &LN..no_TR;
	var pt_id name;
	title '��� ����������� ������� ��� ��������� ���������';
run;

proc sort data = &LN..new_pt;
	by TD;
run;

proc print data = &LN..new_pt;
	var pt_id name TD lastdate pr_b;
	title "���� ����������";
run;

proc means data = &LN..all_pt N;
	var new_birthdate;
   title '����� �������';
run;

/**/
/*-----------------------------------------------*/
/*���� �������� ���������� ������������*/
/*---------------------------------------------*/
data tmp;
	set &LN..new_pt;
	if no_cito = 1 and new_citogen = 1;
run;

proc sort  data = tmp;
	by pt_id;
run;

proc print data = tmp;
	var pt_id name;
run;

proc sort data=all2009.all_pt;
	by new_citogen;
run;


proc freq data=all2009.all_pt;
	by new_citogen;
	table new_normkariotipname*new_mitozname/nocum;
	title '��� �������, ���������������';
run;




proc freq data=all2009.all_pt;
	by new_citogen;
	table new_normkariotipname*new_t922name*new_bcrablname*new_t411name new_anomal_oth/nocum;
	title '������������';
run;


proc freq data=all2009.all_pt;
	table new_citogenname/nocum;
	title '������������';
run;

proc freq data=all2009.all_pt;
	table new_citogenname*new_normkariotipname/nocum;
	title '������������';
run;

data tmp;
	set all2009.all_pt;
	if new_citogen = 1;
run;

proc sort data=tmp;
	by new_normkariotip pt_id;
run;

proc print data=tmp;
	var pt_id name new_normkariotipname new_mitozname new_t922name new_bcrablname new_t411name new_anomal_oth ;
run;