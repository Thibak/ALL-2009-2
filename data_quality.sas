/*���������� �������� ������*/

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


proc sort data = no_TR;
	by pt_id;
run;

proc print data = no_TR;
	var pt_id name;
	title '��� ����������� ������� ��� ��������� ���������';
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
